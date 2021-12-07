class Profile {
  final String email;
  final String name;
  final String code;
  final String phone;
  final List<String> devices;
  final String temperatureUnit;
  final bool is24Hours;

  Profile({
    required this.email,
    required this.name,
    required this.code,
    required this.phone,
    required this.devices,
    required this.temperatureUnit,
    required this.is24Hours,
  });

  factory Profile.fromMap(Map<String, dynamic> data) {
    return Profile(
      email: data['email'],
      name: data['name'],
      code: data['code'],
      phone: data['phone'],
      devices: (data['devices'] as List<dynamic>).cast<String>(),
      temperatureUnit: data['temperatureUnit'],
      is24Hours: data['is24Hours'],
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      "email": email,
      "name": name,
      "code": code,
      "phone": phone,
      "devices": devices,
      "temperatureUnit": temperatureUnit,
      "is24Hours": is24Hours,
    };
  }
}
