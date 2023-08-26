import 'package:journeyplanner_fl/data/station.dart';

import 'layover.dart';

enum ConnectionType { fromHere, toHere }

class Connection {
  final Layover _layover;
  final ConnectionType _type;

  Connection.from(layover)
      : _layover = layover,
        _type = ConnectionType.fromHere;
  Connection.to(layover)
      : _layover = layover,
        _type = ConnectionType.toHere;

  Station get where => _layover.station;
  DateTime get when => _type == ConnectionType.fromHere
      ? _layover.scheduledArrival!
      : _layover.scheduledDeparture!;
  ConnectionType get type => _type;
}
