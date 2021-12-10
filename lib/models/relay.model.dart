class Relay {
  String id;
  String name;
  bool isOpen;
  int outputTime;
  int autoCloseTime;
  bool scheduled;
  bool isEnabled;

  Relay({
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

  updateRelay(String key, dynamic value) {
    final Map<String, dynamic> data = toJSON();
    data[key] = value;

    id = data['id'];
    name = data['name'];
    isOpen = data['isOpen'];
    isOpen = data['isOpen'];
    scheduled = data['scheduled'];
    outputTime = data['outputTime'];
    autoCloseTime = data['autoClose'];
    isEnabled = data['isEnabled'];
  }
}
