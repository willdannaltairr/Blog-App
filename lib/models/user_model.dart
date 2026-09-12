// Model user login. Password tidak pernah disimpan di sisi klien.
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
    final email = json['email']?.toString() ?? '';
    return UserModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      username: json['username']?.toString().isNotEmpty == true
          ? json['username'].toString()
          : email.split('@').first,
      email: email,
      avatarUrl: json['avatar_url']?.toString() ??
          json['avatarUrl']?.toString() ??
          json['avatar']?.toString(),
      createdAt:
          json['created_at']?.toString() ?? json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'username': username,
        'email': email,
        'avatar_url': avatarUrl,
        'created_at': createdAt,
      };
}
