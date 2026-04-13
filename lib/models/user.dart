class User {
  final String firstName;
  final String lastName;
  final String email;
  final String birthDate;
  final String phone;

  User({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.birthDate,
    required this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'birth_date': birthDate,
      'phone': phone,
    };
  }
}
