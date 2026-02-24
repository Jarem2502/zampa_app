class UserModel {
  final int id;
  final String name;
  final String email;
  final String? token; // Opcional, solo lo llenamos al hacer login

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.token,
  });

  // Factory constructor para mapear desde el JSON de Laravel
  factory UserModel.fromJson(Map<String, dynamic> json, {String? authToken}) {
    return UserModel(
      id: json['id'],
      name: json['username'] ?? json['name'] ?? 'Usuario',
      email: json['email'] ?? '',
      token: authToken,
    );
  }

  // Para enviar datos a la API si es necesario
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}