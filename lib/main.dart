// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023 Christian Schärf

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/appstate.dart';
import 'screens/home.dart';

void main() {
  runApp(const JourneyPlannerApp());
}

class JourneyPlannerApp extends StatelessWidget {
  const JourneyPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'Journey Planner',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomeScreenPage(),
      ),
    );
  }
}
