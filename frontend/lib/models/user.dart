class User {
  final String id;
  final String username;
  final String email;

  User({required this.id, required this.username, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    final userJson = json.containsKey('userFound') ? json['userFound'] : json;
    return User(
      id: userJson['_id'] as String,
      username: userJson['username'] as String,
      email: userJson['email'] as String,
    );
  }
}
