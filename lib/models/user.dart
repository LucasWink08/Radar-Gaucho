

class User {
  final int? id; 
  final String name;
  final String email;
  final String password;

  const User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'email': email,
      'password': password,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  User copyWith({int? id, String? name, String? email, String? password}) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}
