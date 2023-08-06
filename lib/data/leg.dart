// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023 Christian Schärf

import 'package:flutter/material.dart';
import 'package:journeyplanner_fl/data/product.dart';

import 'layover.dart';

class Leg with ChangeNotifier {
  final _layovers = <Layover>[];
  var _completed = false;

  get isCompleted => _completed;
  Iterable<Layover> get layovers => _layovers;

  String id;
  String lineName;
  Product product;

  Leg(this.id, this.lineName, this.product);

  Leg.fromEndpoints(this.id, this.lineName, this.product, Layover origin,
      Layover destination) {
    _layovers.addAll([origin, destination]);
  }

  void complete(Iterable<Layover> layovers) {
    _layovers.clear();
    _layovers.addAll(layovers);
    _completed = true;
    notifyListeners();
  }
}
