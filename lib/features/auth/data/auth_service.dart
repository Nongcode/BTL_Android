import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_urls.dart'; // Đảm bảo bạn có file này chứa baseUrl

class AuthService {
  
  // 1. Hàm Đăng nhập
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final url = '${ApiUrls.baseUrl}/auth/login';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "username": username,
          "password": password
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Đăng nhập thành công -> Trả về data (chứa token & user info)
        return {'success': true, 'data': data};
      } else {
        // Lỗi từ server (vd: Sai pass)
        return {'success': false, 'message': data['message'] ?? 'Đăng nhập thất bại'};
      }
    } catch (e) {
      print("Lỗi login: $e");
      return {'success': false, 'message': 'Lỗi kết nối server'};
    }
  }

  // 2. Hàm Đăng ký
  Future<Map<String, dynamic>> register(String username, String password, String email, String fullName) async {
    try {
      final url = '${ApiUrls.baseUrl}/auth/register';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "username": username,
          "password": password,
          "email": email,      // <--- Thêm dòng này
          "fullName": fullName
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'message': 'Đăng ký thành công'};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Đăng ký thất bại'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối server: $e'};
    }
  }
}