// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023 Christian Schärf

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;

import 'dart:convert';

enum StopoverType { arrival, departure }

class StopoverDisplay extends StatefulWidget {
  const StopoverDisplay(
      {super.key, required this.stopoverData, required this.type});

  final StopoverType type;
  final Map stopoverData;

  @override
  State<StopoverDisplay> createState() => _StopoverDisplayState();
}

class _StopoverDisplayState extends State<StopoverDisplay> {
  final _client = http.Client();
  List? _lineRun;

  IconData getIconForProduct() {
    switch (widget.stopoverData['line']['product']) {
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

  void _fetchLineRun() async {
    final uri = Uri(
      scheme: 'https',
      host: 'v6.db.transport.rest',
      path: 'trips/${widget.stopoverData['tripId']}',
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

  @override
  Widget build(BuildContext context) {
    final icon = Icon(getIconForProduct());
    final lineName = widget.stopoverData['line']['name'];
    final text = widget.type == StopoverType.arrival
        ? widget.stopoverData['provenance']
        : widget.stopoverData['direction'];
    final time = DateTime.parse(widget.stopoverData['plannedWhen']);

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: icon,
        title: Text('${intl.DateFormat.Hm().format(time)} $lineName $text'),
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
