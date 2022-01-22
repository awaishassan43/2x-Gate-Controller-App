import 'package:firebase_database/firebase_database.dart';
import 'package:iot/models/relay.model.dart';

class Device {
  String id;
  String name;
  double? temperature;
  double? humidity;
  Map<String, Relay> relays;
  bool onOpenAlert;
  bool onCloseAlert;
  int? remainedOpenAlert;
  bool nightAlert;
  double? temperatureAlert;
  String? firmware;
  String? networkStrength;
  String? macID;
  String? ipAddress;
  final Stream<DatabaseEvent>? stream;

  Device({
    required this.id,
    required this.name,
    required this.temperature,
    required this.humidity,
    required this.relays,
    required this.onOpenAlert,
    required this.onCloseAlert,
    required this.remainedOpenAlert,
    required this.nightAlert,
    this.temperatureAlert,
    this.firmware,
    this.networkStrength,
    this.macID,
    this.ipAddress,
    this.stream,
  });

  /// It is important to note that we could have accessed the temperature and humidity as doubles
  /// however, the conversion of data object to map sometimes convers the whole values to integers
  /// and can cause the app to crash cause direct type casting from int to double doesn't work
  /// so changing based on the runtime type
  factory Device.fromMap(Map<String, dynamic> data, {Stream<DatabaseEvent>? stream}) {
    dynamic temperature = data['temperature'];
    dynamic temperatureAlert = data['temperatureAlert'];
    dynamic humidity = data['humidity'];

    return Device(
      id: data['id'],
      name: data['name'],
      temperature: temperature.runtimeType.toString() == "int" ? (temperature as int).toDouble() : temperature,
      humidity: humidity.runtimeType.toString() == "int" ? (humidity as int).toDouble() : humidity,
      onOpenAlert: data['onOpenAlert'],
      onCloseAlert: data['onCloseAlert'],
      remainedOpenAlert: data['remainedOpenAlert'],
      nightAlert: data['nightAlert'],
      temperatureAlert: temperatureAlert.runtimeType.toString() == "int" ? (temperatureAlert as int).toDouble() : temperatureAlert,
      firmware: data['firmware'],
      networkStrength: data['networkStrength'],
      macID: data['macID'],
      ipAddress: data['ipAddress'],
      stream: stream,
      relays: (data['relays'] as Map<Object?, Object?>).map((key, value) {
        final String relayID = key as String;
        final Map<String, dynamic> relayData = (value as Map<Object?, Object?>).cast<String, dynamic>();

        relayData['id'] = relayID;
        return MapEntry(relayID, Relay.fromJSON(relayData));
      }),
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      "id": id,
      "name": name,
      "temperature": temperature,
      "humidity": humidity,
      "relays": relays.map((key, value) {
        return MapEntry(key, value.toJSON());
      }),
      "onOpenAlert": onOpenAlert,
      "onCloseAlert": onCloseAlert,
      "remainedOpenAlert": remainedOpenAlert,
      "nightAlert": nightAlert,
      "temperatureAlert": temperatureAlert,
      "firmware": firmware,
      "networkStrength": networkStrength,
      "macID": macID,
      "ipAddress": ipAddress,
    };
  }

  void updateUsingMap(Map<String, dynamic> mappedData) {
    dynamic _temperature = mappedData['temperature'];
    dynamic _temperatureAlert = mappedData['temperatureAlert'];
    dynamic _humidity = mappedData['humidity'];

    id = mappedData['id'];
    name = mappedData['name'];
    temperature = _temperature.runtimeType.toString() == "int" ? (_temperature as int).toDouble() : _temperature;
    humidity = _humidity.runtimeType.toString() == "int" ? (_humidity as int).toDouble() : _humidity;
    onOpenAlert = mappedData['onOpenAlert'];
    onCloseAlert = mappedData['onCloseAlert'];
    remainedOpenAlert = mappedData['remainedOpenAlert'];
    nightAlert = mappedData['nightAlert'];
    temperatureAlert = _temperatureAlert.runtimeType.toString() == "int" ? (_temperatureAlert as int).toDouble() : _temperatureAlert;
    firmware = mappedData['firmware'];
    networkStrength = mappedData['networkStrength'];
    macID = mappedData['macID'];
    ipAddress = mappedData['ipAddress'];
    relays = (mappedData['relays'] as Map<Object?, Object?>).map((key, value) {
      final String relayID = key as String;
      final Map<String, dynamic> relayData = (value as Map<Object?, Object?>).cast<String, dynamic>();

      relayData['id'] = relayID;
      return MapEntry(relayID, Relay.fromJSON(relayData));
    });
  }

  void update(String key, dynamic value, {String? relayID}) {
    final Map<String, dynamic> mappedData = toJSON();
    relayID != null && (mappedData['relays'] as Map<String, Map<String, dynamic>>).containsKey(relayID)
        ? (mappedData['relays'] as Map<String, Map<String, dynamic>>)[relayID]![key] = value
        : mappedData[key] = value;

    updateUsingMap(mappedData);
  }
}
