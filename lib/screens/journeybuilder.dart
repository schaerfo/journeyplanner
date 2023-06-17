// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023 Christian Schärf

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:journeyplanner_fl/screens/stopoverquery.dart';

class JourneyBuilderPage extends StatelessWidget {
  const JourneyBuilderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
    return const _AddLegTile();
  }
}

class _AddLegTile extends StatelessWidget {
  const _AddLegTile();

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
        if (!context.mounted) {
          return;
        }
        if (queryType == QueryType.stopover) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StopoverQueryPage(),
              ));
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Coming soon')));
        }
      },
    );
  }
}
