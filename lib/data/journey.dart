// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023 Christian Schärf

import 'package:flutter/widgets.dart';

import 'leg.dart';

class Journey with ChangeNotifier {
  final _legs = <Leg>[];

  Journey();

  Journey.fromLeg(Leg leg) {
    _legs.add(leg);
  }

  Iterable<Leg> get legs => _legs;

  void setInitialLeg(Leg leg) {
    assert(_legs.isEmpty);
    _legs.add(leg);
    notifyListeners();
  }
}
