class UserModel {
  final int id;
  final String name;
  final String email;
  final int? roleId;
  final String? token;
  final String? avatar;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.roleId,
    this.token,
    this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? authToken}) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['username'] ?? json['name'] ?? 'Usuario',
      email: json['email'] ?? '',
      roleId: json['role_id'],
      token: authToken,
      avatar: json['avatar'] != null
          ? 'https://zampa.pro-cafes.com/storage/${json['avatar']}'
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': name,
      'email': email,
      'role_id': roleId,
      'avatar': avatar,
    };
  }
}
