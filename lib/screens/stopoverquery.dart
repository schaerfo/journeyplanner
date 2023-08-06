// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023 Christian Schärf

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:intl/intl.dart' as intl;
import 'package:journeyplanner_fl/data/stopover.dart';

import '../backend/db_transport_rest.dart';
import '../data/modeselection.dart';
import '../data/station.dart';
import '../widgets/datetimeselection.dart';
import '../widgets/modeselection.dart';
import '../widgets/stationsearch.dart';
import '../widgets/linedisplay.dart';

class StopoverQueryPage extends StatelessWidget {
  const StopoverQueryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Departure/Arrival'),
      ),
      body: const _StopoverQuery(),
    );
  }
}

enum StopoverType { arrival, departure }

class _StopoverQuery extends StatefulWidget {
  const _StopoverQuery();

  @override
  State<_StopoverQuery> createState() => _StopoverQueryState();
}

class _StopoverQueryState extends State<_StopoverQuery> {
  Station? _selectedStation;
  StopoverType _stopoverType = StopoverType.departure;
  var _dateTime = DateTime.now();
  var _modeSelection = ModeSelection();

  final _backend = DbTransportRestBackend();
  var _inProgress = false;
  var _stopovers = <Stopover>[];
  // Using _stopovers.isEmpty is not possible since that would be true initially
  var _emptyResult = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        _selectedStation == null
            ? Text(
                "Station",
                style: TextStyle(color: theme.hintColor),
              )
            : Text(_selectedStation!.name),
        ElevatedButton(
            onPressed: () {
              _openStationSearch(context);
            },
            child: const Text('Select Station')),
        ListTile(
            title: const Text('Arrival'),
            leading: Radio<StopoverType>(
                value: StopoverType.arrival,
                groupValue: _stopoverType,
                onChanged: (StopoverType? type) {
                  _setStopoverType(type);
                })),
        ListTile(
            title: const Text('Departure'),
            leading: Radio<StopoverType>(
                value: StopoverType.departure,
                groupValue: _stopoverType,
                onChanged: (StopoverType? type) {
                  _setStopoverType(type);
                })),
        ListTile(
          title: Text(
            '${intl.DateFormat.yMEd().format(_dateTime)} ${intl.DateFormat.Hm().format(_dateTime)}',
          ),
          onTap: () async {
            var newDateTime = await showModalBottomSheet(
              context: context,
              showDragHandle: true,
              builder: (context) => DateTimeSelection(_dateTime),
            );
            if (newDateTime == null) {
              return;
            }
            setState(() {
              _dateTime = newDateTime;
            });
          },
        ),
        ListTile(
          title: Text(_modeSelection.format()),
          onTap: () async {
            final newSelection = await showModalBottomSheet(
              context: context,
              showDragHandle: true,
              builder: (context) => ModeSelectionWidget(_modeSelection),
            );
            if (newSelection == null) {
              return;
            }
            setState(() {
              _modeSelection = newSelection;
            });
          },
        ),
        ElevatedButton(
            onPressed: () {
              _fetchStopovers(context);
            },
            child: const Text('Fetch')),
        const Divider(),
        if (_inProgress) const CircularProgressIndicator(),
        Expanded(
          child: _emptyResult
              ? const Center(
                  child: Text(
                    'No departures/arrivals found',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                )
              : ListView.separated(
                  itemCount: _stopovers.length,
                  itemBuilder: (context, index) {
                    return StopoverDisplay(
                      stopover: _stopovers[index],
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(),
                ),
        ),
      ],
    );
  }

  void _openStationSearch(BuildContext context) async {
    final station = await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => const StationSearch(),
    );
    setState(() {
      _selectedStation = station;
    });
  }

  void _setStopoverType(StopoverType? type) {
    // When can this happen?
    if (type == null) {
      return;
    }
    setState(() {
      _stopovers.clear();
      _stopoverType = type;
    });
  }

  void _fetchStopovers(BuildContext context) async {
    if (_selectedStation == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No station selected')));
      return;
    }

    setState(() {
      _inProgress = true;
    });
    List<Stopover> response;
    try {
      response = await _backend.findStopovers(
          _selectedStation!, _dateTime, _modeSelection,
          departure: _stopoverType == StopoverType.departure);
    } on HttpException catch (e) {
      print(e.message);
      setState(() {
        _inProgress = false;
        _stopovers.clear();
      });
      return;
    }
    setState(() {
      _inProgress = false;
      _stopovers = response;
      _emptyResult = _stopovers.isEmpty;
    });
  }
}
