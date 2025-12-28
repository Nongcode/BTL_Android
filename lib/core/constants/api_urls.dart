// lib/core/constants/api_urls.dart
import 'package:flutter/foundation.dart';

class ApiUrls {
  // Base: http://<host>:4000/api
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:4000/api';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      // Android emulator
      return 'http://10.0.2.2:4000/api';
    } else {
      // iOS simulator / desktop
      // Nếu chạy trên điện thoại thật: đổi sang IP LAN của máy tính, ví dụ: http://192.168.1.10:4000/api
      return 'http://localhost:4000/api';
    }
  }

  // ===== Other modules (giữ lại nếu bạn đang dùng) =====
  static String get chores => '$baseUrl/chores';
  static String get generateDaily => '$baseUrl/chores/generate-daily';
  static String get todayChores => '$baseUrl/chores/today';
  static String get templates => '$baseUrl/chores/templates';
  static String get staticIcons => '$baseUrl/chores/static/icons';

  static String get users => '$baseUrl/users';
  static String get auth => '$baseUrl/auth';
  static String get houses => '$baseUrl/houses';
  static String get finance => '$baseUrl/finance';

  // ===== Bulletin =====
  static String get bulletinBase => '$baseUrl/bulletin';

  // Upload image (POST multipart/form-data, key = "file")
  static String get bulletinUploadImage => '$bulletinBase/upload/image';

  // Notes
  static String bulletinNotesByHouse(int houseId) => '$bulletinBase/houses/$houseId/notes';
  static String bulletinNoteById(String id) => '$bulletinBase/notes/$id';

  // Items
  static String bulletinItemsByHouse(int houseId) => '$bulletinBase/houses/$houseId/items';
  static String bulletinItemById(String id) => '$bulletinBase/items/$id';

  // Comments
  static String bulletinCommentsByTarget(int houseId, String targetType, String targetId) =>
      '$bulletinBase/houses/$houseId/comments/$targetType/$targetId';
  static String bulletinCommentById(String id) => '$bulletinBase/comments/$id';
}
