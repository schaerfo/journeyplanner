// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023 Christian Schärf

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'dart:convert';

import '../data/station.dart';
import 'stationsearch.dart';

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

class _StopoverQuery extends StatefulWidget {
  const _StopoverQuery();

  @override
  State<_StopoverQuery> createState() => _StopoverQueryState();
}

enum StopoverType { arrival, departure }

class _StopoverQueryState extends State<_StopoverQuery> {
  Station? _selectedStation;
  StopoverType _stopoverType = StopoverType.departure;

  final _client = http.Client();
  var _inProgress = false;
  var _stopovers = [];

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
        ElevatedButton(
            onPressed: () {
              _fetchStopovers(context);
            },
            child: const Text('Fetch')),
        const Divider(),
        if (_inProgress) const CircularProgressIndicator(),
        Expanded(
          child: ListView.separated(
            itemCount: _stopovers.length,
            itemBuilder: (context, index) => _StopoverDisplay(
                stopoverData: _stopovers[index], type: _stopoverType),
            separatorBuilder: (context, index) => const Divider(),
          ),
        ),
      ],
    );
  }

  void _openStationSearch(BuildContext context) async {
    final station = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const StationSearchPage()));
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
        path: 'stops/${_selectedStation!.id}/$keyword');
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
    });
  }
}

class _StopoverDisplay extends StatelessWidget {
  const _StopoverDisplay(
      {super.key, required this.stopoverData, required this.type});

  final StopoverType type;
  final Map stopoverData;

  @override
  Widget build(BuildContext context) {
    const icon = Icon(Icons.train);
    final lineName = stopoverData['line']['name'];
    final text = type == StopoverType.arrival
        ? stopoverData['provenance']
        : stopoverData['direction'];

    return Row(
      children: [icon, Text('$lineName $text')],
    );
  }
}