// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023 Christian Schärf

import 'package:flutter/material.dart';

import 'package:intl/intl.dart' as intl;
import 'package:journeyplanner_fl/data/product.dart';
import 'package:journeyplanner_fl/data/stopover.dart';

import '../backend/db_transport_rest.dart';
import '../data/layover.dart';
import '../data/leg.dart';
import '../data/station.dart';

class LineDisplay extends StatefulWidget {
  const LineDisplay(
      {super.key,
      required this.line,
      this.start,
      this.end,
      this.onSectionSelected});

  final Leg line;
  final Station? start;
  final Station? end;
  final Function(Leg)? onSectionSelected;

  @override
  State<LineDisplay> createState() => _LineDisplayState();

  Widget title() {
    return Text(line.lineName);
  }
}

class _LineDisplayState extends State<LineDisplay> {
  final _backend = DbTransportRestBackend();
  Station? _entry;

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
            ? _layoverListTiles(context)
            : <Widget>[const CircularProgressIndicator()],
      ),
    );
  }

  List<Widget> _layoverListTiles(BuildContext context) {
    final result = <Widget>[];

    bool active = widget.start == null && _entry == null;
    for (final currStopover in widget.line.layovers) {
      if (currStopover.station.id == widget.start?.id ||
          currStopover.station == _entry) {
        active = true;
      }
      Widget? entryExitButton;
      if (widget.onSectionSelected != null && active) {
        if (currStopover.station.id == widget.start?.id) {
          entryExitButton = const Icon(Icons.login);
        } else if (currStopover.station.id == widget.end?.id) {
          entryExitButton = const Icon(Icons.logout);
        } else if (widget.start == null && _entry == null ||
            currStopover.station == _entry) {
          entryExitButton = IconButton(
            onPressed: () {
              _setEntry(currStopover.station);
            },
            icon: const Icon(Icons.login),
          );
        } else {
          entryExitButton = IconButton(
            onPressed: () {
              _setExit(currStopover.station);
            },
            icon: const Icon(Icons.logout),
          );
        }
      }
      result.add(ListTile(
        leading: currStopover.scheduledDeparture == null
            ? null
            : Text(
                intl.DateFormat.Hm().format(currStopover.scheduledDeparture!),
              ),
        title: Text(
          currStopover.station.name,
          style: active ? null : const TextStyle(color: Colors.black45),
        ),
        trailing: entryExitButton,
      ));
      if (currStopover.station.id == widget.end?.id && active) {
        active = false;
      }
    }
    return result;
  }

  void _setEntry(Station entry) {
    if (widget.end != null) {
      widget.onSectionSelected!(widget.line.between(entry, widget.end!));
    } else {
      setState(() {
        if (_entry == null) {
          _entry = entry;
        } else {
          _entry = null;
        }
      });
    }
  }

  void _setExit(Station exit) {
    if (widget.start != null) {
      widget.onSectionSelected!(widget.line.between(widget.start!, exit));
    } else {
      widget.onSectionSelected!(widget.line.between(_entry!, exit));
    }
  }
}

class StopoverDisplay extends LineDisplay {
  final Stopover stopover;

  StopoverDisplay(
      {super.key,
      required this.stopover,
      super.start,
      super.end,
      super.onSectionSelected})
      : super(line: stopover.leg);

  @override
  Widget title() {
    final lineName = stopover.leg.lineName;
    final text = stopover.where();
    final time = stopover.scheduledWhen();
    return Text('${intl.DateFormat.Hm().format(time)} $lineName $text');
  }
}

class LegDisplay extends LineDisplay {
  final Layover origin;
  final Layover destination;

  LegDisplay({super.key, required Leg line})
      : origin = line.origin,
        destination = line.destination,
        super(
          line: line,
          start: line.origin.station,
          end: line.destination.station,
        );

  @override
  Widget title() {
    final departureTime =
        intl.DateFormat.Hm().format(origin.scheduledDeparture!);
    final departureStation = origin.station.name;
    final arrivalTime =
        intl.DateFormat.Hm().format(destination.scheduledArrival!);
    final arrivalStation = destination.station.name;
    return Text(
      '${line.lineName} $departureTime $departureStation - $arrivalTime $arrivalStation',
    );
  }
}
