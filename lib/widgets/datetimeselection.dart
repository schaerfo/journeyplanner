// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023 Christian Schärf

import 'package:flutter/material.dart';

import 'package:intl/intl.dart' as intl;

class DateTimeSelection extends StatefulWidget {
  final DateTime dateTime;

  const DateTimeSelection(this.dateTime, {super.key});

  @override
  State<DateTimeSelection> createState() => _DateTimeSelectionState();
}

class _DateTimeSelectionState extends State<DateTimeSelection> {
  late DateTime dateTime;

  @override
  void initState() {
    super.initState();
    dateTime = widget.dateTime;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.calendar_month),
          title: Text(intl.DateFormat.yMEd().format(dateTime)),
          onTap: () async {
            final newDate = await showDatePicker(
                context: context,
                initialDate: dateTime,
                firstDate: DateTime.parse('2020-01-01'),
                lastDate: DateTime.parse('2029-12-31'));
            if (newDate == null) {
              return;
            }
            setState(() {
              dateTime = DateTime(newDate.year, newDate.month, newDate.day,
                  dateTime.hour, dateTime.minute);
            });
          },
        ),
        ListTile(
          leading: const Icon(Icons.access_time),
          title: Text(intl.DateFormat.Hm().format(dateTime)),
          onTap: () async {
            final newTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(dateTime));
            if (newTime == null) {
              return;
            }
            setState(() {
              dateTime = DateTime(dateTime.year, dateTime.month, dateTime.day,
                  newTime.hour, newTime.minute);
            });
          },
        ),
        Wrap(
          spacing: 5,
          children: [
            ActionChip(
              label: const Text('Now'),
              onPressed: () {
                Navigator.pop(context, DateTime.now());
              },
            ),
            ActionChip(
              label: const Text('In 15 Minutes'),
              onPressed: () {
                Navigator.pop(
                    context, DateTime.now().add(const Duration(minutes: 15)));
              },
            ),
            ActionChip(
              label: const Text('In 1 Hour'),
              onPressed: () {
                Navigator.pop(
                    context, DateTime.now().add(const Duration(hours: 1)));
              },
            ),
            ActionChip(
              label: const Text('Tomorrow'),
              onPressed: () {
                Navigator.pop(
                    context, DateTime.now().add(const Duration(days: 1)));
              },
            ),
          ],
        ),
        TextButton(
            onPressed: () {
              Navigator.pop(context, dateTime);
            },
            child: const Text('OK')),
      ],
    );
  }
}
