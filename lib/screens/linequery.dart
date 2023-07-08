// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023 Christian Schärf

import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../widgets/linedisplay.dart';

class LineQueryPage extends StatelessWidget {
  const LineQueryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Search Line'),
      ),
      body: _LineQuery(),
    );
  }
}

class _LineQuery extends StatefulWidget {
  @override
  State<_LineQuery> createState() => _LineQueryState();
}

class _LineQueryState extends State<_LineQuery> {
  var _searchInProgress = false;
  var _emptyResult = false;
  var _lines = [];

  final _client = http.Client();
  var _query = "";
  late RestartableTimer _timer;

  _LineQueryState() {
    _timer = RestartableTimer(const Duration(milliseconds: 500), () {
      if (_query.isNotEmpty) {
        _queryLines(_query);
      }
    });
  }

  void _queryLines(String query) async {
    final now = DateTime.now();
    var uri = Uri(
      scheme: 'https',
      host: 'v6.db.transport.rest',
      path: 'trips',
      queryParameters: {
        'query': query,
        'onlyCurrentlyRunning': false.toString(),
        'fromWhen': DateTime(now.year, now.month, now.day).toIso8601String(),
        'untilWhen': DateTime(now.year, now.month, now.day, 23, 59, 59)
            .toIso8601String(),
      },
    );
    setState(() {
      _searchInProgress = true;
      _lines.clear();
    });
    var response = await _client.get(uri);
    if (response.statusCode != 200) {
      print("Error: HTTP status ${response.statusCode}");
      setState(() {
        _searchInProgress = false;
        _lines.clear();
      });
      return;
    }
    var decoded = jsonDecode(utf8.decode(response.bodyBytes));
    setState(() {
      _searchInProgress = false;
      _lines = decoded['trips'];
      _emptyResult = _lines.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Center(
          child: SizedBox(
            width: 150,
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Line',
              ),
              onChanged: (value) {
                _query = value;
                _timer.reset();
              },
            ),
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
                    'No lines found',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                )
              : ListView.separated(
                  itemCount: _lines.length,
                  itemBuilder: (context, index) => LineDisplay(
                    id: _lines[index]['id'],
                    product: _lines[index]['line']['product'],
                    title: Text(_lines[index]['line']['name']),
                  ),
                  separatorBuilder: (context, _) => const Divider(),
                ),
        )
      ],
    );
  }
}
