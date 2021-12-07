import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iot/models/relay.model.dart';

class Device {
  final String id;
  final String name;
  final double? temperature;
  final double? humidity;
  final List<Relay> relays;
  final int onOpenAlert;
  final int onCloseAlert;
  final int remainedOpenAlert;
  final bool nightAlert;
  final int? temperatureAlert;
  final String? firmware;
  final String? networkStrength;
  final String? macID;
  final String? ipAddress;
  final DocumentReference<Map<String, dynamic>>? deviceRef;

  const Device({
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
    this.deviceRef,
  });

  /// It is important to note that we could have accessed the temperature and humidity as doubles
  /// however, the conversion of data object to map sometimes convers the whole values to integers
  /// and can cause the app to crash cause direct type casting from int to double doesn't work
  /// so changing based on the runtime type
  factory Device.fromMap(Map<String, dynamic> data, {DocumentReference<Map<String, dynamic>>? ref}) {
    final dynamic temperature = data['temperature'];
    final dynamic humidity = data['humidity'];

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
      temperatureAlert: data['temperatureAlert'],
      firmware: data['firmware'],
      networkStrength: data['networkStrength'],
      macID: data['macID'],
      ipAddress: data['ipAddress'],
      deviceRef: ref,
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
}
