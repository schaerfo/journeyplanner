// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023 Christian Schärf

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;

import 'dart:convert';

class LineDisplay extends StatefulWidget {
  const LineDisplay(
      {super.key,
      required this.id,
      required this.product,
      required this.title});

  final String id;
  final String product;
  final Widget title;

  @override
  State<LineDisplay> createState() => _LineDisplayState();
}

class _LineDisplayState extends State<LineDisplay> {
  final _client = http.Client();
  List? _lineRun;

  void _fetchLineRun() async {
    final uri = Uri(
      scheme: 'https',
      host: 'v6.db.transport.rest',
      path: 'trips/${widget.id}',
    );
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      print("Error: HTTP status ${response.statusCode}");
      return;
    }
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    setState(() {
      _lineRun = decoded['trip']['stopovers'];
    });
  }

  IconData getIconForProduct() {
    switch (widget.product) {
      case "bus":
        return Icons.directions_bus;
      case "tram":
        return Icons.tram;
      case "subway":
        return Icons.subway;
      case "suburban":
        return Icons.directions_transit;
      case "national":
      case "nationalExpress":
        return Icons.directions_train;
      default:
        return Icons.train;
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = Icon(getIconForProduct());

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: icon,
        title: widget.title,
        onExpansionChanged: (value) {
          if (value) {
            _fetchLineRun();
          }
        },
        children: _lineRun == null
            ? <Widget>[const CircularProgressIndicator()]
            : <Widget>[
                for (final currStopover in _lineRun!)
                  ListTile(
                    leading: currStopover['plannedDeparture'] == null
                        ? null
                        : Text(intl.DateFormat.Hm().format(
                            DateTime.parse(currStopover['plannedDeparture']))),
                    title: Text(currStopover['stop']['name']),
                  )
              ],
      ),
    );
  }
}