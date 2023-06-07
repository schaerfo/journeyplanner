// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023 Christian Schärf

import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Journey Planner',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Journey Planner'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(title),
      ),
      body: const Center(child: StopoverQuery()),
    );
  }
}

class StopoverQuery extends StatefulWidget {
  const StopoverQuery({super.key});

  @override
  State<StopoverQuery> createState() => _StopoverQueryState();
}

class _StopoverQueryState extends State<StopoverQuery> {
  Station? _selectedStation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        _selectedStation == null
            ? Text(
                "Station",
                style: TextStyle(color: theme.hintColor),
              )
            : Text(_selectedStation!.name),
        ElevatedButton(
            onPressed: () {
              _openStationSearch(context);
            },
            child: const Text('Select Station')),
      ],
    );
  }

  void _openStationSearch(BuildContext context) async {
    final station = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const StationSearchPage()));
    setState(() {
      _selectedStation = station;
    });
  }
}

class StationSearchPage extends StatelessWidget {
  const StationSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Select Station'),
      ),
      body: const Center(child: StationSearch()),
    );
  }
}

class StationSearch extends StatefulWidget {
  const StationSearch({
    super.key,
  });

  @override
  State<StationSearch> createState() => _StationSearchState();
}

class Station {
  const Station({required this.id, required this.name});

  final String id; // The id is a string in the API response
  final String name;
}

class _StationSearchState extends State<StationSearch> {
  var _searchInProgress = false;
  final _searchResults = <Station>[];
  final _client = http.Client();

  void searchStation(String query) async {
    var uri = Uri(
        scheme: 'https',
        host: 'v6.db.transport.rest',
        path: 'stations',
        queryParameters: {'query': query});
    setState(() {
      _searchInProgress = true;
    });
    var response = await _client.get(uri);
    if (response.statusCode != 200) {
      print("Error: HTTP status ${response.statusCode}");
      return;
    }
    var decoded = jsonDecode(utf8.decode(response.bodyBytes));
    setState(() {
      _searchInProgress = false;
      _searchResults.clear();
      for (var currStation in decoded.values) {
        _searchResults
            .add(Station(id: currStation['id'], name: currStation['name']));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Station:'),
            const SizedBox(width: 10),
            SizedBox(
              width: 150,
              child: TextField(
                onSubmitted: (value) {
                  searchStation(value);
                },
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 15,
        ),
        if (_searchInProgress) const CircularProgressIndicator(),
        for (var currResult in _searchResults)
          Column(
            children: [
              const SizedBox(
                height: 5,
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, currResult);
                  },
                  child: Text(currResult.name)),
            ],
          ),
      ],
    );
  }
}
