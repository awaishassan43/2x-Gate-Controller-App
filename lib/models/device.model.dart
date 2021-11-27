class Device {
  final String id;
  final String name;
  final double temperature;
  final double humidity;
  final List<Relay> relays;

  const Device({
    required this.id,
    required this.name,
    required this.temperature,
    required this.humidity,
    required this.relays,
  });

  factory Device.fromMap(Map<String, dynamic> data) {
    return Device(
      id: data['id'],
      name: data['name'],
      temperature: data['temperature'],
      humidity: data['humidity'],
      relays: data['relays'],
    );
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
}
