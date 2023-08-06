// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023 Christian Schärf

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:journeyplanner_fl/data/layover.dart';
import 'package:journeyplanner_fl/data/station.dart';
import 'package:journeyplanner_fl/data/stopover.dart';

import '../data/leg.dart';
import '../data/modeselection.dart';
import '../data/product.dart';

class DbTransportRestBackend {
  /// Backend for v6.db.transport.rest (https://v6.db.transport.rest/)

  final _client = Client();

  Future<List<Leg>> findLines(String query) async {
    final now = DateTime.now();
    var uri = Uri(
      scheme: 'https',
      host: 'v6.db.transport.rest',
      path: 'trips',
      queryParameters: {
        'query': query,
        'onlyCurrentlyRunning': false.toString(),
        'fromWhen': DateTime(now.year, now.month, now.day).toIso8601String(),
        'untilWhen': DateTime(now.year, now.month, now.day, 23, 59, 59)
            .toIso8601String(),
      },
    );
    var response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw HttpException('Error: HTTP status ${response.statusCode}');
    }
    var decoded = jsonDecode(utf8.decode(response.bodyBytes));
    return (decoded['trips'] as List).map((e) => _convertLine(e)).toList();
  }

  Future<List<Stopover>> findStopovers(
      Station station, DateTime when, ModeSelection modeSelection,
      {bool departure = true}) async {
    final keyword = departure ? 'departures' : 'arrivals';
    final uri = Uri(
      scheme: 'https',
      host: 'v6.db.transport.rest',
      path: 'stops/${station.id}/$keyword',
      queryParameters: {
        'when': when.toIso8601String(),
        'nationalExpress': modeSelection.highSpeed.toString(),
        'national': modeSelection.longDistance.toString(),
        'regionalExpress': modeSelection.regional.toString(),
        'regional': modeSelection.local.toString(),
        'suburban': modeSelection.suburban.toString(),
        'bus': modeSelection.bus.toString(),
        'ferry': modeSelection.ferry.toString(),
        'subway': modeSelection.metro.toString(),
        'tram': modeSelection.tram.toString(),
        'taxi': modeSelection.groupTaxi.toString(),
      },
    );
    var response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw HttpException('Error: HTTP status ${response.statusCode}');
    }
    var decoded = jsonDecode(utf8.decode(response.bodyBytes));
    return (decoded[departure ? 'departures' : 'arrivals'] as List)
        .map((e) => _convertStopover(e, departure))
        .toList();
  }

  Leg _convertLine(Map trip) {
    final id = trip['id'];
    final name = trip['line']['name'];
    final product = _convertProduct(trip['line']['product']);
    final origin = Layover(
      station: _convertStation(trip['origin']),
      scheduledDeparture: DateTime.parse(trip['plannedDeparture']),
    );
    final destination = Layover(
      station: _convertStation(trip['destination']),
      scheduledDeparture: DateTime.parse(trip['plannedArrival']),
    );
    return Leg.fromEndpoints(id, name, product, origin, destination);
  }

  Stopover _convertStopover(Map stopover, bool departure) {
    final tripId = stopover['tripId'];
    final leg = _convertLeg(tripId, stopover['line']);
    final station = _convertStation(stopover['stop']);

    if (departure) {
      return Departure(leg, station, DateTime.parse(stopover['plannedWhen']),
          stopover['direction']);
    } else {
      return Arrival(leg, station, DateTime.parse(stopover['plannedWhen']),
          stopover['provenance']);
    }
  }

  Leg _convertLeg(String id, Map line) {
    final name = line['name'];
    final product = _convertProduct(line['product']);
    return Leg(id, name, product);
  }

  Product _convertProduct(String product) {
    switch (product) {
      case 'taxi':
        return Product.groupTaxi;
      case 'ferry':
        return Product.ferry;
      case 'bus':
        return Product.bus;
      case 'tram':
        return Product.tram;
      case 'subway':
        return Product.metro;
      case 'suburban':
        return Product.suburban;
      case 'regional':
        return Product.local;
      case 'regionalExpress':
        return Product.regional;
      case 'national':
        return Product.longDistance;
      case 'nationalExpress':
        return Product.highSpeed;
      default:
        throw FormatException('Unknown product: $product');
    }
  }

  Station _convertStation(Map station) {
    return Station(id: station['id'], name: station['name']);
  }
}
