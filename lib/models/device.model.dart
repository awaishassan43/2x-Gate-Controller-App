class Device {
  final String id;
  final String name;
  final double? temperature;
  final double? humidity;
  final List<Relay> relays;

  const Device({
    required this.id,
    required this.name,
    this.temperature,
    this.humidity,
    required this.relays,
  });

  /// It is important to note that we could have accessed the temperature and humidity as integers
  /// however, the conversion of data object to map sometimes convers the whole values to integers
  /// so changing based on the runtime type
  factory Device.fromMap(Map<String, dynamic> data) {
    final dynamic temperature = data['temperature'];
    final dynamic humidity = data['humidity'];

    return Device(
      id: data['id'],
      name: data['name'],
      temperature: temperature.runtimeType.toString() == "int" ? (temperature as int).toDouble() : temperature,
      humidity: humidity.runtimeType.toString() == "int" ? (humidity as int).toDouble() : humidity,
      relays: (data['relays'] as List<dynamic>).cast<Map<String, dynamic>>().map((relay) => Relay.fromJSON(relay)).toList(),
    );
  }

  Map<String, dynamic> toJSON() {
    return {"id": id, "name": name, "temperature": temperature, "humidity": humidity, "relays": relays.map((relay) => relay.toJSON()).toList()};
  }
}

class Relay {
  final String id;
  final String name;
  final bool isOpen;

  const Relay({
    required this.id,
    required this.name,
    required this.isOpen,
  });

  Map<String, dynamic> toJSON() {
    return {
      "id": id,
      "name": name,
      "isOpen": isOpen,
    };
  }

  factory Relay.fromJSON(Map<String, dynamic> data) {
    return Relay(id: data['id'], name: data['name'], isOpen: data['isOpen']);
  }
}
