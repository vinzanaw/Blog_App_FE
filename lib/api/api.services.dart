import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000/api/v1';

  static Future<List<dynamic>> getPosts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts'),
    );

    print('GET POSTS STATUS: ${response.statusCode}');
    print('GET POSTS RESPONSE: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data['data']['posts'];
    } else {
      throw Exception(
        'Gagal mengambil data post: ${response.statusCode}',
      );
    }
  }

  static Future<dynamic> getPostById(int postId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts/$postId'),
    );

    print('GET DETAIL STATUS: ${response.statusCode}');
    print('GET DETAIL RESPONSE: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data['data']['post'];
    } else {
      throw Exception(
        'Gagal mengambil detail post: ${response.statusCode}',
      );
    }
  }
  

  static Future<void> deletePost(int postId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/posts/$postId'),
    );

    print('DELETE STATUS: ${response.statusCode}');
    print('DELETE RESPONSE: ${response.body}');

    if (response.statusCode != 200 &&
        response.statusCode != 204) {
      throw Exception(
        'Gagal menghapus post: ${response.statusCode}',
      );
    }
  }


  static Future<void> createPost({
    required int authorId,
    required int categoriesId,
    required String title,
    required String description,
    required String content,
    File? image,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/posts'),
    );

    request.fields['userId'] = authorId.toString();
    request.fields['categoriesId'] = categoriesId.toString();
    request.fields['title'] = title;
    request.fields['description'] = description;

    if (image != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          image.path,
        ),
      );
    }
    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(
      streamedResponse,
    );

    print('CREATE STATUS: ${response.statusCode}');
    print('CREATE RESPONSE: ${response.body}');

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception(
        'Gagal membuat post: ${response.statusCode}',
      );
    }
  }


  static Future<void> updatePost({
    required int id,
    required String title,
    required int categoriesId,
    required String description,
    required String content,
    File? image,
  }) async {
    final request = http.MultipartRequest(
      'PATCH',
      Uri.parse('$baseUrl/posts/$id'),
    );

    request.fields['title'] = title;
    request.fields['categoriesId'] = categoriesId.toString();
    request.fields['description'] = description;
    request.fields['content'] = content;

    if (image != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          image.path,
        ),
      );
    }
    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(
      streamedResponse,
    );

    print('UPDATE STATUS: ${response.statusCode}');
    print('UPDATE RESPONSE: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mengupdate post: ${response.statusCode}',
      );
    }
  }
}