// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023 Christian Schärf

import 'package:flutter/material.dart';

import 'journey.dart';

class AppState with ChangeNotifier {
  final _journeys = <Journey>[];

  int get journeyCount => _journeys.length;

  void addJourney(Journey journey) {
    _journeys.add(journey);
    notifyListeners();
  }

  Journey createJourney() {
    final result = Journey();
    _journeys.add(result);
    notifyListeners();
    return result;
  }
}
