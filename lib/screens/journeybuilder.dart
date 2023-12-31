// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023 Christian Schärf

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:journeyplanner_fl/data/journey.dart';
import 'package:journeyplanner_fl/screens/stopoverquery.dart';
import 'package:journeyplanner_fl/screens/linequery.dart';
import 'package:provider/provider.dart';

import '../data/leg.dart';
import '../widgets/linedisplay.dart';

class JourneyBuilderPage extends StatelessWidget {
  const JourneyBuilderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              icon: const Icon(Icons.check))
        ],
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Edit Journey'),
      ),
      body: _JourneyBuilder(),
    );
  }
}

enum QueryType { line, journey, stopover }

class _JourneyBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final journey = Provider.of<Journey>(context);
    if (journey.legs.isEmpty) {
      return _AddLegTile(
        onLegSelected: (Leg leg) {
          journey.setInitialLeg(leg);
        },
      );
    } else {
      return ListView(
        children: [
          for (final currLeg in journey.legs)
            LegDisplay(
              line: currLeg,
            ),
        ],
      );
    }
  }
}

class _AddLegTile extends StatelessWidget {
  final Function(Leg) onLegSelected;

  const _AddLegTile({required this.onLegSelected});

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).iconTheme.color!;

    return ListTile(
      title: const Icon(Icons.add),
      onTap: () async {
        final queryType = await showModalBottomSheet(
          context: context,
          showDragHandle: true,
          builder: (context) => ListView(
            children: [
              ListTile(
                leading: SvgPicture.asset(
                  'assets/icons/line.svg',
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                ),
                title: const Text('Line'),
                onTap: () {
                  Navigator.pop(context, QueryType.line);
                },
              ),
              ListTile(
                leading: SvgPicture.asset(
                  'assets/icons/journey.svg',
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                ),
                title: const Text('Journey'),
                onTap: () {
                  Navigator.pop(context, QueryType.journey);
                },
              ),
              ListTile(
                leading: SvgPicture.asset(
                  'assets/icons/stopover.svg',
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                ),
                title: const Text('Departure/Arrival'),
                onTap: () {
                  Navigator.pop(context, QueryType.stopover);
                },
              ),
            ],
          ),
        );
        // Querying context.mounted after an async gap is recommended practice:
        // https://api.flutter.dev/flutter/widgets/BuildContext/mounted.html
        // ignore: use_build_context_synchronously
        if (!context.mounted) {
          return;
        }
        Leg? newLeg;
        if (queryType == null) {
          return;
        } else if (queryType == QueryType.stopover) {
          newLeg = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StopoverQueryPage(),
              ));
        } else if (queryType == QueryType.line) {
          newLeg = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LineQueryPage()),
          );
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Coming soon')));
        }
        if (newLeg != null) {
          onLegSelected(newLeg);
        }
      },
    );
  }
}
