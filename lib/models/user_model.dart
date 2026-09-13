class UserModel {
  final int id;
  final String name;
  final String email;
  final String username;
  final String? avatarUrl;
  final String? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    String? username,
    this.avatarUrl,
    this.createdAt,
  }) : username = (username == null || username.isEmpty)
            ? email.split('@').first
            : username;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String email = json['email']?.toString() ?? '';
    String uname = json['username']?.toString() ?? '';
    if (uname.isEmpty && email.contains('@')) {
      uname = email.split('@').first;
    }

    int id = 0;
    if (json['id'] is int) {
      id = json['id'];
    } else {
      id = int.tryParse(json['id']?.toString() ?? '') ?? 0;
    }

    return UserModel(
      id: id,
      name: json['name']?.toString() ?? '',
      email: email,
      username: uname,
      avatarUrl: json['avatar_url']?.toString() ??
          json['avatarUrl']?.toString() ??
          json['avatar']?.toString(),
      createdAt:
          json['created_at']?.toString() ?? json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'avatar_url': avatarUrl,
      'created_at': createdAt,
    };
  }
}
