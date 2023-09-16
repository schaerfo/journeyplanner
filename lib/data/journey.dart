// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023 Christian Schärf

import 'package:flutter/widgets.dart';

import 'layover.dart';
import 'leg.dart';

class Journey with ChangeNotifier {
  final _legs = <Leg>[];

  Journey();

  Journey.fromLeg(Leg leg) {
    _legs.add(leg);
  }

  Iterable<Leg> get legs => _legs;
  Layover get origin => _legs.first.origin;
  Layover get destination => _legs.last.destination;

  void setInitialLeg(Leg leg) {
    assert(_legs.isEmpty);
    _legs.add(leg);
    notifyListeners();
  }

  void appendLeg(Leg leg) {
    assert(isConnectionValid(destination, leg.origin));
    _legs.add(leg);
    notifyListeners();
  }

  void prependLeg(Leg leg) {
    assert(isConnectionValid(leg.destination, origin));
    _legs.insert(0, leg);
    notifyListeners();
  }

  bool isConnectionValid(Layover arrival, Layover departure) {
    final isSameStation = arrival.station.id == departure.station.id;
    final isAfterOrEqual =
        arrival.scheduledArrival!.compareTo(departure.scheduledDeparture!) <= 0;
    return isSameStation && isAfterOrEqual;
  }
}
