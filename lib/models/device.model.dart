class Device {
  final String name;
  final double temperature;
  final double humidity;
  final List<Relay> relays;

  const Device({
    required this.name,
    required this.temperature,
    required this.humidity,
    required this.relays,
  });
}

class Relay {
  final String name;
  final bool isOpen;

  const Relay({
    required this.name,
    required this.isOpen,
  });
}
