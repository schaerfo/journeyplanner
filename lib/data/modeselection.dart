// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023 Christian Schärf

import 'package:quiver/iterables.dart';

class ModeSelection {
  bool highSpeed = true;
  bool longDistance = true;
  bool regional = true;
  bool local = true;
  bool suburban = true;
  bool metro = true;
  bool tram = true;
  bool bus = true;
  bool groupTaxi = true;
  bool ferry = true;

  String format() {
    const allModes = <String>[
      'High speed',
      'Long distance',
      'Regional',
      'Local',
      'Suburban',
      'Metro',
      'Tram',
      'Bus',
      'Group taxi',
      'Ferry',
    ];
    final selected = <bool>[
      highSpeed,
      longDistance,
      regional,
      local,
      suburban,
      metro,
      tram,
      bus,
      groupTaxi,
      ferry,
    ];
    if (count() == allModes.length) {
      return 'All';
    } else if (count() > 5) {
      return 'All except ${zip([
            allModes,
            selected
          ]).where((element) => !(element[1] as bool)).map((e) => e[0] as String).join(', ')}';
    } else {
      return 'Only ${zip([
            allModes,
            selected
          ]).where((element) => element[1] as bool).map((e) => e[0] as String).join(', ')}';
    }
  }

  int count() {
    int result = 0;
    result += highSpeed ? 1 : 0;
    result += longDistance ? 1 : 0;
    result += regional ? 1 : 0;
    result += local ? 1 : 0;
    result += suburban ? 1 : 0;
    result += metro ? 1 : 0;
    result += tram ? 1 : 0;
    result += bus ? 1 : 0;
    result += groupTaxi ? 1 : 0;
    result += ferry ? 1 : 0;
    return result;
  }
}
