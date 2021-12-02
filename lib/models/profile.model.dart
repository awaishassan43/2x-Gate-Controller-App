class Profile {
  final String email;
  final String firstName;
  final String lastName;
  final String code;
  final String phone;
  final List<String> devices;

  Profile({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.code,
    required this.phone,
    this.devices = const [],
  });

  factory Profile.fromMap(Map<String, dynamic> data) {
    return Profile(
      email: data['email'],
      firstName: data['firstName'],
      lastName: data['lastName'],
      code: data['code'],
      phone: data['phone'],
      devices: (data['devices'] as List<dynamic>).cast<String>(),
    );
  }
}
