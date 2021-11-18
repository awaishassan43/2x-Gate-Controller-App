class Profile {
  final String email;
  final String firstName;
  final String lastName;
  final String code;
  final String phone;

  Profile({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.code,
    required this.phone,
  });

  factory Profile.fromMap(Map<String, dynamic> data) {
    return Profile(
      email: data['email'],
      firstName: data['firstName'],
      lastName: data['lastName'],
      code: data['code'],
      phone: data['phone'],
    );
  }
}
