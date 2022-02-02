import 'package:iot/util/functions.util.dart';

class Profile {
  String email;
  String name;
  String code;
  String phone;
  String temperatureUnit;
  bool is24Hours;
  List<String> devices;

  Profile({
    required this.email,
    required this.name,
    required this.code,
    required this.phone,
    required this.temperatureUnit,
    required this.is24Hours,
    required this.devices,
  });

  factory Profile.fromMap(Map<String, dynamic> data) {
    return Profile(
      email: data['email'],
      name: data['name'],
      code: data['code'],
      phone: data['phone'],
      temperatureUnit: data['temperatureUnit'],
      is24Hours: data['is24Hours'],
      devices: castList<String>(data['devices']),
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      "email": email,
      "name": name,
      "code": code,
      "phone": phone,
      "temperatureUnit": temperatureUnit,
      "is24Hours": is24Hours,
      "devices": devices,
    };
  }

  void updateProfile(String key, dynamic value) {
    final Map<String, dynamic> data = toJSON();
    data[key] = value;

    email = data['email'];
    name = data['name'];
    code = data['code'];
    phone = data['phone'];
    temperatureUnit = data['temperatureUnit'];
    is24Hours = data['is24Hours'];
    devices = data['devices'];
  }
}
