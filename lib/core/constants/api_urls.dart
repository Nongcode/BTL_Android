// lib/core/constants/api_urls.dart
import 'package:flutter/foundation.dart';

class ApiUrls {
  // Base: http://<host>:4000/api
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:4000/api';
    } 
    // 2. Nếu chạy trên Android (Máy ảo) -> Dùng 10.0.2.2
    // (Lưu ý: defaultTargetPlatform an toàn hơn Platform.isAndroid khi build đa nền tảng)
    else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:4000/api';
    } 
    // 3. Các trường hợp khác (iOS, Máy thật...) -> Dùng localhost hoặc IP LAN
    else {
      return 'http://localhost:4000/api'; // Hoặc IP LAN của bạn: 192.168.1.x
    }
  }

  // ===== Other modules (giữ lại nếu bạn đang dùng) =====
  static String get chores => '$baseUrl/chores';
  static String get generateDaily => '$baseUrl/chores/generate-daily';
  static String get todayChores => '$baseUrl/chores/today';
  static String get templates => '$baseUrl/chores/templates';
  
  // URL lấy resources (ảnh, icon)
  static String get staticIcons => '$baseUrl/chores/static/icons';

  static String get users => '$baseUrl/users';
}