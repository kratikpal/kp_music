class UserModel {
  final String name;
  final String email;

  UserModel({required this.name, required this.email});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['firstName'],
      email: json['email'],
    );
  }
}
