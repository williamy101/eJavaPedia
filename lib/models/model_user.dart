class User {
  final String? name;
  final String? dob;
  final String email;
  final String pass;

  User({
    this.name,
    this.dob,
    required this.email,
    required this.pass,
  });

  factory User.toJson(Map<String, dynamic> json) {
    return User(
        name: json['account_nama'],
        dob: json['account_dob'],
        email: json['account_email'],
        pass: json['account_password']);
  }
}
