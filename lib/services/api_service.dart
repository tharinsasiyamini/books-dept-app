import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_api_model.dart';
import '../models/album_api_model.dart';
import '../models/photo_api_model.dart';

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<UserApiModel>> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => UserApiModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users: \${response.statusCode}');
    }
  }

  Future<UserApiModel> getUserById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/users/\$id'));

    if (response.statusCode == 200) {
      return UserApiModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user: \${response.statusCode}');
    }
  }

  Future<List<AlbumApiModel>> getAlbums() async {
    final response = await http.get(Uri.parse('$baseUrl/albums'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => AlbumApiModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load albums: \${response.statusCode}');
    }
  }

  Future<AlbumApiModel> getAlbumById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/albums/\$id'));

    if (response.statusCode == 200) {
      return AlbumApiModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load album: \${response.statusCode}');
    }
  }

  Future<List<PhotoApiModel>> getPhotos() async {
    final response = await http.get(Uri.parse('$baseUrl/photos'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => PhotoApiModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load photos: \${response.statusCode}');
    }
  }

  Future<List<PhotoApiModel>> getPhotosByAlbumId(int albumId) async {
    final response = await http.get(Uri.parse('$baseUrl/albums/\$albumId/photos'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => PhotoApiModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load photos for album: \${response.statusCode}');
    }
  }
}
