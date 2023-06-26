// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023 Christian Schärf

import 'package:flutter/material.dart';

import '../data/modeselection.dart';

class ModeSelectionWidget extends StatefulWidget {
  const ModeSelectionWidget(this.selection, {super.key});
  final ModeSelection selection;

  @override
  State<ModeSelectionWidget> createState() => _ModeSelectionWidgetState();
}

class _ModeSelectionWidgetState extends State<ModeSelectionWidget> {
  late ModeSelection selection;

  @override
  void initState() {
    super.initState();
    selection = widget.selection;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        CheckboxListTile(
          value: selection.highSpeed,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selection.highSpeed = value;
              });
            }
          },
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text('High-speed trains'),
        ),
        CheckboxListTile(
          value: selection.longDistance,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selection.longDistance = value;
              });
            }
          },
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text('Long-distance trains'),
        ),
        CheckboxListTile(
          value: selection.regional,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selection.regional = value;
              });
            }
          },
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text('Regional trains'),
        ),
        CheckboxListTile(
          value: selection.local,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selection.local = value;
              });
            }
          },
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text('Local trains'),
        ),
        CheckboxListTile(
          value: selection.suburban,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selection.suburban = value;
              });
            }
          },
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text('Suburban trains'),
        ),
        CheckboxListTile(
          value: selection.metro,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selection.metro = value;
              });
            }
          },
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text('Metro'),
        ),
        CheckboxListTile(
          value: selection.tram,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selection.tram = value;
              });
            }
          },
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text('Tram'),
        ),
        CheckboxListTile(
          value: selection.bus,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selection.bus = value;
              });
            }
          },
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text('Bus'),
        ),
        CheckboxListTile(
          value: selection.groupTaxi,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selection.groupTaxi = value;
              });
            }
          },
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text('Group taxi'),
        ),
        CheckboxListTile(
          value: selection.ferry,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selection.ferry = value;
              });
            }
          },
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text('Ferry'),
        ),
        TextButton(
            onPressed: () {
              Navigator.pop(context, selection);
            },
            child: const Text('OK')),
      ],
    );
  }
}
