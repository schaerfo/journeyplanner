// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023 Christian Schärf

import 'package:flutter/material.dart';

import 'package:intl/intl.dart' as intl;
import 'package:journeyplanner_fl/data/product.dart';
import 'package:journeyplanner_fl/data/stopover.dart';

import '../backend/db_transport_rest.dart';
import '../data/leg.dart';

class LineDisplay extends StatefulWidget {
  const LineDisplay({super.key, required this.line});

  final Leg line;

  @override
  State<LineDisplay> createState() => _LineDisplayState();

  Widget title() {
    return Text(line.lineName);
  }
}

class _LineDisplayState extends State<LineDisplay> {
  final _backend = DbTransportRestBackend();

  void _fetchLineRun() async {
    await _backend.fetchLineRun(widget.line);
    setState(() {});
  }

  IconData getIconForProduct() {
    switch (widget.line.product) {
      case Product.bus:
        return Icons.directions_bus;
      case Product.tram:
        return Icons.tram;
      case Product.metro:
        return Icons.subway;
      case Product.suburban:
        return Icons.directions_transit;
      case Product.longDistance:
      case Product.highSpeed:
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
        title: widget.title(),
        onExpansionChanged: (value) {
          if (value) {
            _fetchLineRun();
          }
        },
        children: widget.line.isCompleted
            ? <Widget>[
                for (final currStopover in widget.line.layovers)
                  ListTile(
                    leading: currStopover.scheduledDeparture == null
                        ? null
                        : Text(intl.DateFormat.Hm()
                            .format(currStopover.scheduledDeparture!)),
                    title: Text(currStopover.station.name),
                  )
              ]
            : <Widget>[const CircularProgressIndicator()],
      ),
    );
  }
}

class StopoverDisplay extends LineDisplay {
  final Stopover stopover;

  StopoverDisplay({super.key, required this.stopover})
      : super(line: stopover.leg);

  @override
  Widget title() {
    final lineName = stopover.leg.lineName;
    final text = stopover.where();
    final time = stopover.scheduledWhen();
    return Text('${intl.DateFormat.Hm().format(time)} $lineName $text');
  }
}
