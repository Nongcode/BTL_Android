// lib/features/bulletin/service/bulletin_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../../core/constants/api_urls.dart';
import 'package:btl_android_flutter/features/bulletin/data/models/bulletin_model.dart';
import 'package:btl_android_flutter/features/bulletin/data/models/bulletin_item_model.dart';
import 'package:btl_android_flutter/features/bulletin/data/models/bulletin_comment_model.dart';

class BulletinService {
  String get _bulletinBase => '${ApiUrls.baseUrl}/bulletin';

  String _notesByHouse(int houseId) => '$_bulletinBase/houses/$houseId/notes';
  String _noteById(String id) => '$_bulletinBase/notes/$id';

  String _itemsByHouse(int houseId) => '$_bulletinBase/houses/$houseId/items';
  String _itemById(String id) => '$_bulletinBase/items/$id';

  String _commentsByTarget(int houseId, String targetType, String targetId) =>
      '$_bulletinBase/houses/$houseId/comments/$targetType/$targetId';
  String _commentById(String id) => '$_bulletinBase/comments/$id';

  String get _uploadImageUrl => '$_bulletinBase/upload/image';

  Map<String, String> _headers({String? token}) {
    final h = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null && token.trim().isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  // ==============================
  // UPLOAD IMAGE
  // ==============================
  /// Upload ảnh lên backend: POST /api/bulletin/upload/image (multipart, key="file")
  /// Trả về url dạng: http://localhost:4000/uploads/xxx.jpg
  Future<String?> uploadImage({
    required File file,
    String? token,
  }) async {
    try {
      final req = http.MultipartRequest('POST', Uri.parse(_uploadImageUrl));

      // Nếu backend cần auth cho upload thì bật token
      if (token != null && token.trim().isNotEmpty) {
        req.headers['Authorization'] = 'Bearer $token';
      }

      req.files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamed = await req.send();
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode == 200 || res.statusCode == 201) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        return body['url']?.toString();
      }

      print('uploadImage failed: ${res.statusCode} - ${res.body}');
      return null;
    } catch (e) {
      print('Error uploadImage: $e');
      return null;
    }
  }

  // ==============================
  // NOTES
  // ==============================
  Future<List<Bulletin>> getNotes({int houseId = 1, String? token}) async {
    try {
      final res = await http.get(
        Uri.parse(_notesByHouse(houseId)),
        headers: _headers(token: token),
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        if (body['success'] == true) {
          final List<dynamic> data = body['data'] as List<dynamic>;
          return data
              .map((e) => Bulletin.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }

      print('getNotes failed: ${res.statusCode} - ${res.body}');
      return [];
    } catch (e) {
      print('Error getNotes: $e');
      return [];
    }
  }

  Future<bool> createNote({
    int houseId = 1,
    required String title,
    required String content,
    required String category,
    String? imageUrl,
    bool hasReminder = false,
    bool isPinned = false,
    String? token,
  }) async {
    try {
      final payload = <String, dynamic>{
        "title": title,
        "content": content,
        "category": category,
        "imageUrl": imageUrl,
        "hasReminder": hasReminder,
        "isPinned": isPinned,
      };

      final res = await http.post(
        Uri.parse(_notesByHouse(houseId)),
        headers: _headers(token: token),
        body: jsonEncode(payload),
      );

      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      print('Error createNote: $e');
      return false;
    }
  }

  Future<bool> updateNote({
    required String id,
    required String title,
    required String content,
    required String category,
    String? imageUrl,
    bool hasReminder = false,
    bool isPinned = false,
    String? token,
  }) async {
    try {
      final payload = <String, dynamic>{
        "title": title,
        "content": content,
        "category": category,
        "imageUrl": imageUrl,
        "hasReminder": hasReminder,
        "isPinned": isPinned,
      };

      final res = await http.put(
        Uri.parse(_noteById(id)),
        headers: _headers(token: token),
        body: jsonEncode(payload),
      );

      return res.statusCode == 200;
    } catch (e) {
      print('Error updateNote: $e');
      return false;
    }
  }

  Future<bool> deleteNote({required String id, String? token}) async {
    try {
      final res = await http.delete(
        Uri.parse(_noteById(id)),
        headers: _headers(token: token),
      );
      return res.statusCode == 200;
    } catch (e) {
      print('Error deleteNote: $e');
      return false;
    }
  }

  // ==============================
  // ITEMS
  // ==============================
  Future<List<BulletinItem>> getItems({int houseId = 1, String? token}) async {
    try {
      final res = await http.get(
        Uri.parse(_itemsByHouse(houseId)),
        headers: _headers(token: token),
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        if (body['success'] == true) {
          final List<dynamic> data = body['data'] as List<dynamic>;
          return data
              .map((e) => BulletinItem.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }

      print('getItems failed: ${res.statusCode} - ${res.body}');
      return [];
    } catch (e) {
      print('Error getItems: $e');
      return [];
    }
  }

  Future<bool> createItem({
    int houseId = 1,
    required String itemName,
    String? itemNote,
    int? quantity,
    String? imageUrl,
    bool isChecked = false,
    String? token,
  }) async {
    try {
      final payload = <String, dynamic>{
        "itemName": itemName,
        "itemNote": itemNote,
        "quantity": quantity,
        "imageUrl": imageUrl,
        "isChecked": isChecked,
      };

      final res = await http.post(
        Uri.parse(_itemsByHouse(houseId)),
        headers: _headers(token: token),
        body: jsonEncode(payload),
      );

      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      print('Error createItem: $e');
      return false;
    }
  }

  Future<bool> updateItem({
    required String id,
    required String itemName,
    String? itemNote,
    int? quantity,
    String? imageUrl,
    bool isChecked = false,
    String? token,
  }) async {
    try {
      final payload = <String, dynamic>{
        "itemName": itemName,
        "itemNote": itemNote,
        "quantity": quantity,
        "imageUrl": imageUrl,
        "isChecked": isChecked,
      };

      final res = await http.put(
        Uri.parse(_itemById(id)),
        headers: _headers(token: token),
        body: jsonEncode(payload),
      );

      return res.statusCode == 200;
    } catch (e) {
      print('Error updateItem: $e');
      return false;
    }
  }

  Future<bool> deleteItem({required String id, String? token}) async {
    try {
      final res = await http.delete(
        Uri.parse(_itemById(id)),
        headers: _headers(token: token),
      );
      return res.statusCode == 200;
    } catch (e) {
      print('Error deleteItem: $e');
      return false;
    }
  }

  // ==============================
  // COMMENTS
  // ==============================
  Future<List<BulletinComment>> getComments({
    required int houseId,
    required String targetType, // "note" | "item"
    required String targetId,
    String? token,
  }) async {
    try {
      final res = await http.get(
        Uri.parse(_commentsByTarget(houseId, targetType, targetId)),
        headers: _headers(token: token),
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        if (body['success'] == true) {
          final List<dynamic> data = body['data'] as List<dynamic>;
          return data
              .map((e) => BulletinComment.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }

      print('getComments failed: ${res.statusCode} - ${res.body}');
      return [];
    } catch (e) {
      print('Error getComments: $e');
      return [];
    }
  }

  /// createComment thường cần JWT vì backend dùng req.user.id
  Future<bool> createComment({
    required int houseId,
    required String targetType,
    required String targetId,
    required String content,
    String? parentId,
    required String token,
  }) async {
    try {
      final payload = <String, dynamic>{
        "content": content,
        "parentId": parentId,
      };

      final res = await http.post(
        Uri.parse(_commentsByTarget(houseId, targetType, targetId)),
        headers: _headers(token: token),
        body: jsonEncode(payload),
      );

      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      print('Error createComment: $e');
      return false;
    }
  }

  Future<bool> deleteComment({required String id, String? token}) async {
    try {
      final res = await http.delete(
        Uri.parse(_commentById(id)),
        headers: _headers(token: token),
      );
      return res.statusCode == 200;
    } catch (e) {
      print('Error deleteComment: $e');
      return false;
    }
  }
}
