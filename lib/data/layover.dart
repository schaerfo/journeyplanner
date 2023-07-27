// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023 Christian Schärf

import 'package:journeyplanner_fl/data/station.dart';

class Layover {
  final Station station;
  final DateTime? scheduledArrival;
  final DateTime? scheduledDeparture;

  const Layover(
      {required this.station, this.scheduledDeparture, this.scheduledArrival});
}
