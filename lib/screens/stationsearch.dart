// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023 Christian Schärf

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'dart:convert';

class StationSearchPage extends StatelessWidget {
  const StationSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Select Station'),
      ),
      body: const Center(child: _StationSearch()),
    );
  }
}

class _StationSearch extends StatefulWidget {
  const _StationSearch();

  @override
  State<_StationSearch> createState() => _StationSearchState();
}

class Station {
  const Station({required this.id, required this.name});

  final String id; // The id is a string in the API response
  final String name;
}

class _StationSearchState extends State<_StationSearch> {
  var _searchInProgress = false;
  final _searchResults = <Station>[];
  final _client = http.Client();

  void searchStation(String query) async {
    var uri = Uri(
        scheme: 'https',
        host: 'v6.db.transport.rest',
        path: 'stations',
        queryParameters: {'query': query});
    setState(() {
      _searchInProgress = true;
    });
    var response = await _client.get(uri);
    if (response.statusCode != 200) {
      print("Error: HTTP status ${response.statusCode}");
      return;
    }
    var decoded = jsonDecode(utf8.decode(response.bodyBytes));
    setState(() {
      _searchInProgress = false;
      _searchResults.clear();
      for (var currStation in decoded.values) {
        _searchResults
            .add(Station(id: currStation['id'], name: currStation['name']));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Station:'),
            const SizedBox(width: 10),
            SizedBox(
              width: 150,
              child: TextField(
                onSubmitted: (value) {
                  searchStation(value);
                },
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 15,
        ),
        if (_searchInProgress) const CircularProgressIndicator(),
        Expanded(
          child: ListView.separated(
              itemBuilder: (context, index) => ListTile(
                    title: Text(_searchResults[index].name),
                    onTap: () {
                      Navigator.pop(context, _searchResults[index]);
                    },
                  ),
              separatorBuilder: (context, index) => const Divider(),
              itemCount: _searchResults.length),
        ),
      ],
    );
  }
}