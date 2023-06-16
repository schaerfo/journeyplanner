// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023 Christian Schärf

import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:journeyplanner_fl/screens/stopoverquery.dart';

class HomeScreenPage extends StatelessWidget {
  HomeScreenPage({super.key});

  final _key = GlobalKey<ExpandableFabState>();

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).iconTheme.color!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Journey Planner'),
      ),
      body: _HomeScreen(),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        key: _key,
        child: const Icon(Icons.add),
        type: ExpandableFabType.up,
        distance: 80,
        children: [
          FloatingActionButton.extended(
            heroTag: 'journeyButton',
            onPressed: () {
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Coming soon!')));
            },
            icon: SvgPicture.asset(
              'assets/icons/journey.svg',
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
            label: const Text('Journey'),
            tooltip: 'Search for journeys between two locations',
          ),
          FloatingActionButton.extended(
            heroTag: 'stopoverButton',
            onPressed: () {
              _key.currentState?.toggle();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StopoverQueryPage(),
                  ));
            },
            icon: SvgPicture.asset(
              'assets/icons/stopover.svg',
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
            label: const Text('Departure/Arrival'),
            tooltip: 'Search for departures or arrivals at a location',
          ),
          FloatingActionButton.extended(
            heroTag: 'lineButton',
            onPressed: () {
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Coming soon!')));
            },
            icon: SvgPicture.asset(
              'assets/icons/line.svg',
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
            label: const Text('Line'),
            tooltip: 'Search for train runs',
          ),
        ],
      ),
    );
  }
}

class _HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
