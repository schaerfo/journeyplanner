// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023 Christian Schärf

import 'package:flutter/material.dart';

import 'package:intl/intl.dart' as intl;

import '../data/connection.dart';

class DateTimeSelection extends StatefulWidget {
  final DateTime dateTime;
  final Connection? connection;

  const DateTimeSelection(this.dateTime, {super.key, this.connection});

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
        // TODO: Show time of connection if there is any
        ListTile(
          leading: const Icon(Icons.calendar_month),
          title: Text(intl.DateFormat.yMEd().format(dateTime)),
          onTap: () async {
            final newDate = await showDatePicker(
              context: context,
              initialDate: dateTime,
              firstDate: _periodStart(),
              lastDate: _periodEnd(),
            );
            if (newDate == null) {
              return;
            }
            setState(() {
              dateTime = dateTime.copyWith(
                year: newDate.year,
                month: newDate.month,
                day: newDate.day,
              );
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
            final newDateTime = dateTime.copyWith(
              hour: newTime.hour,
              minute: newTime.minute,
            );
            if (_isSelectedDateTimeValid(newDateTime)) {
              setState(() {
                dateTime = newDateTime;
              });
            } else if (context.mounted) {
              // FIXME snack bar is displayed under bottom sheet
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  // TODO more precise message: select a time before/after ...
                  content: Text("invalid time"),
                ),
              );
            }
          },
        ),
        Wrap(
          spacing: 5,
          children: [
            // TODO: Display chips with a transfer time instead when we add a connection
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

  DateTime _periodStart() {
    if (widget.connection != null &&
        widget.connection!.type == ConnectionType.fromHere) {
      return widget.connection!.when;
    } else {
      return DateTime.parse('2020-01-01');
    }
  }

  DateTime _periodEnd() {
    if (widget.connection != null &&
        widget.connection!.type == ConnectionType.toHere) {
      return widget.connection!.when;
    } else {
      return DateTime.parse('2029-12-31');
    }
  }

  bool _isSelectedDateTimeValid(DateTime dateTime) {
    final equalOrAfterPeriodStart = dateTime.compareTo(_periodStart()) >= 0;
    final equalOrBeforePeriodEnd = dateTime.compareTo(_periodEnd()) <= 0;
    return equalOrAfterPeriodStart && equalOrBeforePeriodEnd;
  }
}
