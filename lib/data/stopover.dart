// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023 Christian Schärf

import 'package:journeyplanner_fl/data/station.dart';

import 'leg.dart';

abstract class Stopover {
  // A stopover is when you are at a station and a train stops near you.
  Leg leg;
  Station station;

  Stopover(this.leg, this.station);

  String where();
  DateTime scheduledWhen();
}

class Departure extends Stopover {
  final DateTime scheduledDeparture;
  final String destination;

  Departure(Leg leg, Station station, this.scheduledDeparture, this.destination)
      : super(leg, station);

  @override
  DateTime scheduledWhen() {
    return scheduledDeparture;
  }

  @override
  String where() {
    return destination;
  }
}

class Arrival extends Stopover {
  final DateTime scheduledArrival;
  final String origin;

  Arrival(Leg leg, Station station, this.scheduledArrival, this.origin)
      : super(leg, station);

  @override
  DateTime scheduledWhen() {
    return scheduledArrival;
  }

  @override
  String where() {
    return origin;
  }
}
