import 'package:firebase_database/firebase_database.dart';
import 'package:iot/models/relay.model.dart';

class Device {
  String id;
  String name;
  double? temperature;
  double? humidity;
  List<Relay> relays;
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
      relays: (data['relays'] as List<dynamic>).cast<Map<String, dynamic>>().map((relay) => Relay.fromJSON(relay)).toList(),
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
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      "id": id,
      "name": name,
      "temperature": temperature,
      "humidity": humidity,
      "relays": relays.map((relay) => relay.toJSON()).toList(),
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

  void updateDeviceUsingMap(Map<String, dynamic> mappedData) {
    id = mappedData['id'];
    name = mappedData['name'];
    temperature = mappedData['temperature'];
    humidity = mappedData['humidity'];
    relays = (mappedData['relays'] as List<dynamic>).cast<Map<String, dynamic>>().map((relay) => Relay.fromJSON(relay)).toList();
    onOpenAlert = mappedData['onOpenAlert'];
    onCloseAlert = mappedData['onCloseAlert'];
    remainedOpenAlert = mappedData['remainedOpenAlert'];
    nightAlert = mappedData['nightAlert'];
    temperatureAlert = mappedData['temperatureAlert'];
    firmware = mappedData['firmware'];
    networkStrength = mappedData['networkStrength'];
    macID = mappedData['macID'];
    ipAddress = mappedData['ipAddress'];
  }

  void updateDevice(String key, dynamic value, {String? relayID}) {
    final Map<String, dynamic> mappedData = toJSON();
    relayID != null
        ? (mappedData['relays'] as List<Map<String, dynamic>>).firstWhere((relay) => relay['id'] == relayID)[key] = value
        : mappedData[key] = value;

    updateDeviceUsingMap(mappedData);
  }
}
