class Profile {
  final String email;
  final String firstName;
  final String lastName;
  final String code;
  final String phone;
  final String id;
  final List<String> devices;
  final String temperatureUnit;
  final bool is24Hours;

  Profile({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.code,
    required this.phone,
    required this.devices,
    required this.temperatureUnit,
    required this.is24Hours,
  });

  factory Profile.fromMap(Map<String, dynamic> data) {
    return Profile(
      id: data['userID'],
      email: data['email'],
      firstName: data['firstName'],
      lastName: data['lastName'],
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
      "firstName": firstName,
      "lastName": lastName,
      "code": code,
      "phone": phone,
      "devices": devices,
      "userID": id,
      "temperatureUnit": temperatureUnit,
      "is24Hours": is24Hours,
    };
  }
}
