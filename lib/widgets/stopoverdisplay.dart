// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023 Christian Schärf

import 'package:flutter/material.dart';

import 'package:intl/intl.dart' as intl;

enum StopoverType { arrival, departure }

class StopoverDisplay extends StatelessWidget {
  const StopoverDisplay(
      {super.key, required this.stopoverData, required this.type});

  final StopoverType type;
  final Map stopoverData;

  IconData getIconForProduct() {
    switch (stopoverData['line']['product']) {
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
    final lineName = stopoverData['line']['name'];
    final text = type == StopoverType.arrival
        ? stopoverData['provenance']
        : stopoverData['direction'];
    final time = DateTime.parse(stopoverData['plannedWhen']);

    return Row(
      children: [
        icon,
        Text('${intl.DateFormat.Hm().format(time)} $lineName $text'),
      ],
    );
  }
}
