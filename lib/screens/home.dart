// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023 Christian Schärf

import 'package:flutter/material.dart';
import 'package:journeyplanner_fl/data/journey.dart';
import 'package:journeyplanner_fl/screens/journeybuilder.dart';
import 'package:provider/provider.dart';

import '../data/appstate.dart';

class HomeScreenPage extends StatelessWidget {
  const HomeScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Journey Planner'),
      ),
      body: _HomeScreen(),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Create new journey',
        onPressed: () async {
          var state = Provider.of<AppState>(context, listen: false);
          final journey = Journey();
          final success = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider<Journey>.value(
                      value: journey, child: const JourneyBuilderPage())));
          if (success == null || !success) {
            return;
          }
          state.addJourney(journey);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AppState>(context);
    if (state.journeyCount == 0) {
      return const Center(
        child: Text(
          'No journeys added yet',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      );
    } else {
      return const Placeholder();
    }
  }
}
