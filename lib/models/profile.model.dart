import 'package:iot/util/functions.util.dart';

import '../enum/access.enum.dart';

class Profile {
  String email;
  String name;
  String code;
  String phone;
  String temperatureUnit;
  bool is24Hours;
  List<ConnectedDevice> devices;
  String fcmToken;

  Profile({
    required this.email,
    required this.name,
    required this.code,
    required this.phone,
    required this.temperatureUnit,
    required this.is24Hours,
    required this.devices,
    required this.fcmToken,
  });

  factory Profile.fromMap(Map<String, dynamic> data) {
    return Profile(
      email: data['email'],
      name: data['name'],
      code: data['code'],
      phone: data['phone'],
      temperatureUnit: data['temperatureUnit'],
      is24Hours: data['is24Hours'],
      devices: mapToList(data['devices']).map((item) => ConnectedDevice.fromMap(item as Map<String, dynamic>)).toList(),
      fcmToken: data['fcmToken'],
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
      "devices": devices.map((e) => e.toJSON()).toList(),
      "fcmToken": fcmToken,
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
    devices = mapToList(data['devices']).map((item) => ConnectedDevice.fromMap(item as Map<String, dynamic>)).toList();
    fcmToken = data['fcmToken'];
  }
}

class ConnectedDevice {
  String id;
  String? accessProvidedBy;
  AccessType? accessType;

  ConnectedDevice({
    required this.id,
    this.accessProvidedBy,
    this.accessType,
  });

  factory ConnectedDevice.fromMap(Map<String, dynamic> data) {
    return ConnectedDevice(
      id: data['id'],
      accessProvidedBy: data['accessProvidedBy'],
      accessType: data['accessType'] ? AccessTypeExtension.getAccessType(data['accessType']) : null,
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      "id": id,
      "accessProvidedBy": accessProvidedBy,
      "accessType": accessType,
    };
  }
}
