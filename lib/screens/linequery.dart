// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023 Christian Schärf

import 'dart:io';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:journeyplanner_fl/backend/db_transport_rest.dart';

import '../data/leg.dart';
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
  var _lines = <Leg>[];

  final _backend = DbTransportRestBackend();
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
    setState(() {
      _searchInProgress = true;
      _lines.clear();
    });
    List<Leg> response;
    try {
      response = await _backend.findLines(query);
    } on HttpException catch (e) {
      print(e.message);
      setState(() {
        _searchInProgress = false;
        _lines.clear();
      });
      return;
    }
    setState(() {
      _searchInProgress = false;
      _lines = response;
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
                    line: _lines[index],
                    title: Text(_lines[index].lineName),
                  ),
                  separatorBuilder: (context, _) => const Divider(),
                ),
        )
      ],
    );
  }
}
