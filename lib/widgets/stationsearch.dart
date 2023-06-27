// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023 Christian Schärf

import 'package:flutter/material.dart';

import 'package:async/async.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

import '../data/station.dart';

class StationSearch extends StatefulWidget {
  const StationSearch({super.key});

  @override
  State<StationSearch> createState() => _StationSearchState();
}

class _StationSearchState extends State<StationSearch> {
  var _searchInProgress = false;
  var _emptyResult = false;
  final _searchResults = <Station>[];

  final _client = http.Client();
  var _query = "";
  late RestartableTimer _timer;

  _StationSearchState() {
    _timer = RestartableTimer(const Duration(milliseconds: 500), () {
      if (_query.isNotEmpty) {
        searchStation(_query);
      }
    });
  }

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
      _emptyResult = _searchResults.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          width: 150,
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Station',
            ),
            onChanged: (value) {
              _query = value;
              _timer.reset();
            },
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        if (_searchInProgress) const CircularProgressIndicator(),
        Expanded(
          child: _emptyResult
              ? const Center(
                  child: Text(
                    'No stations found',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                )
              : ListView.separated(
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
