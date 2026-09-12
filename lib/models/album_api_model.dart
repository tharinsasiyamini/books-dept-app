class AlbumApiModel {
  final int userId;
  final int id;
  final String title;

  AlbumApiModel({
    required this.userId,
    required this.id,
    required this.title,
  });

  factory AlbumApiModel.fromJson(Map<String, dynamic> json) {
    return AlbumApiModel(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
    );
  }
}
