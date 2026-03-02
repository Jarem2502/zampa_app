class ReviewModel {
  final int id;
  final String userName;
  final String? userAvatar;
  final int rating;
  final String comment;
  final String date;

  ReviewModel({
    required this.id,
    required this.userName,
    this.userAvatar,
    required this.rating,
    required this.comment,
    required this.date,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    const String baseUrl = 'https://zampa.pro-cafes.com/storage/';

    return ReviewModel(
      id: json['id'] ?? 0,
      userName: json['user_name'] ?? 'Usuario Zampa',
      userAvatar: json['user_avatar'] != null
          ? baseUrl + json['user_avatar']
          : null,
      rating: json['rating'] ?? 5,
      comment: json['comment'] ?? '',
      date: json['created_at']?.toString().substring(0, 10) ?? 'Reciente',
    );
  }
}
