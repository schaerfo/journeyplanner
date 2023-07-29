// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023 Christian Schärf

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:journeyplanner_fl/data/layover.dart';
import 'package:journeyplanner_fl/data/station.dart';

import '../data/leg.dart';
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
    return Leg(id, name, product, origin, destination);
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
