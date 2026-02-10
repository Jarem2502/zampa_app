class DigiModel {
  final int id;
  final String name;
  final String href;
  final String image;

  DigiModel({
    required this.id,
    required this.name,
    required this.href,
    required this.image,
  });

  factory DigiModel.fromJson(Map<String, dynamic> json) {
    return DigiModel(
      id: json["id"],
      name: json["name"],
      href: json["href"],
      image: json["image"],
    );
  }
}