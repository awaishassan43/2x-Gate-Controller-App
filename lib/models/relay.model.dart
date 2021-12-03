class Relay {
  final String id;
  final String name;
  final bool isOpen;
  final int outputTime;
  final int autoCloseTime;
  final bool scheduled;
  final bool isEnabled;

  const Relay({
    required this.id,
    required this.name,
    required this.isOpen,
    required this.outputTime,
    required this.autoCloseTime,
    required this.scheduled,
    required this.isEnabled,
  });

  Map<String, dynamic> toJSON() {
    return {
      "id": id,
      "name": name,
      "isOpen": isOpen,
      "outputTime": outputTime,
      "autoClose": autoCloseTime,
      "scheduled": scheduled,
      "isEnabled": isEnabled,
    };
  }

  factory Relay.fromJSON(Map<String, dynamic> data) {
    return Relay(
      id: data['id'],
      name: data['name'],
      isOpen: data['isOpen'],
      scheduled: data['scheduled'],
      outputTime: data['outputTime'],
      autoCloseTime: data['autoClose'],
      isEnabled: data['isEnabled'],
    );
  }
}
