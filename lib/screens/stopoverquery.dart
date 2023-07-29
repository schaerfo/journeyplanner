// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023 Christian Schärf

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;

import 'dart:convert';

import '../data/modeselection.dart';
import '../data/product.dart';
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

  final _client = http.Client();
  var _inProgress = false;
  var _stopovers = [];
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
                    final lineName = _stopovers[index]['line']['name'];
                    final text = _stopoverType == StopoverType.arrival
                        ? _stopovers[index]['provenance']
                        : _stopovers[index]['direction'];
                    final time =
                        DateTime.parse(_stopovers[index]['plannedWhen']);
                    return LineDisplay.fromId(
                      id: _stopovers[index]['tripId'],
                      product:
                          _convertProduct(_stopovers[index]['line']['product']),
                      title: Text(
                          '${intl.DateFormat.Hm().format(time)} $lineName $text'),
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(),
                ),
        ),
      ],
    );
  }

  Product _convertProduct(String product) {
    switch (product) {
      case 'taxi':
        return Product.groupTaxi;
      case 'ferry':
        return Product.ferry;
      case 'bus':
        return Product.bus;
      case 'tram':
        return Product.tram;
      case 'subway':
        return Product.metro;
      case 'suburban':
        return Product.suburban;
      case 'regional':
        return Product.local;
      case 'regionalExpress':
        return Product.regional;
      case 'national':
        return Product.longDistance;
      case 'nationalExpress':
        return Product.highSpeed;
      default:
        throw FormatException('Unknown product: $product');
    }
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

    final keyword =
        _stopoverType == StopoverType.arrival ? 'arrivals' : 'departures';
    final uri = Uri(
      scheme: 'https',
      host: 'v6.db.transport.rest',
      path: 'stops/${_selectedStation!.id}/$keyword',
      queryParameters: {
        'when': _dateTime.toIso8601String(),
        'nationalExpress': _modeSelection.highSpeed.toString(),
        'national': _modeSelection.longDistance.toString(),
        'regionalExpress': _modeSelection.regional.toString(),
        'regional': _modeSelection.local.toString(),
        'suburban': _modeSelection.suburban.toString(),
        'bus': _modeSelection.bus.toString(),
        'ferry': _modeSelection.ferry.toString(),
        'subway': _modeSelection.metro.toString(),
        'tram': _modeSelection.tram.toString(),
        'taxi': _modeSelection.groupTaxi.toString(),
      },
    );
    setState(() {
      _inProgress = true;
    });
    var response = await _client.get(uri);
    if (response.statusCode != 200) {
      print("Error: HTTP status ${response.statusCode}");
      return;
    }
    var decoded = jsonDecode(utf8.decode(response.bodyBytes));
    setState(() {
      _inProgress = false;
      _stopovers = decoded[keyword];
      _emptyResult = _stopovers.isEmpty;
    });
  }
}
