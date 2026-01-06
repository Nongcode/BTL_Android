import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_urls.dart';
import '../models/chore_model.dart';

class ChoreService {
  
  // 1. Lấy danh sách việc hôm nay (GET)
  Future<List<Chore>> getTodayChores() async {
    try {
      final response = await http.get(Uri.parse(ApiUrls.todayChores));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        
        if (body['success'] == true) {
          final List<dynamic> data = body['data'];
          return data.map((item) => Chore.fromJson(item)).toList();
        }
      }
      throw Exception('Lỗi server: ${response.statusCode}');
    } catch (e) {
      print('Error getTodayChores: $e');
      return []; 
    }
  }

  // 2. Tạo công việc mẫu mới (POST)
  // [CẬP NHẬT] Đổi tên thành createTemplate và xóa logic hardcode
  Future<bool> createTemplate(Chore newChore) async {
    try {
      // Vì AddChoreScreen đã xử lý logic ID và Rotation rất chuẩn rồi
      // Nên ở đây ta chỉ cần đóng gói và gửi đi thôi.
      final Map<String, dynamic> bodyData = newChore.toJson();

      // [QUAN TRỌNG] Kiểm tra lại assignee_id lần cuối
      // Nếu UI chưa gửi ID (null), ta có thể fallback về 0 hoặc xử lý tùy ý
      if (bodyData['assignee_id'] == null) {
         bodyData['assignee_id'] = 1; // ID mặc định nếu lỡ null
      }

      print("Body gửi đi: ${jsonEncode(bodyData)}"); // Log để kiểm tra

      final response = await http.post(
        Uri.parse(ApiUrls.templates), // Đảm bảo URL này đúng: .../api/chores/templates
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bodyData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print("Lỗi tạo mới từ Server: ${response.body}");
        return false;
      }
    } catch (e) {
      print('Error createTemplate: $e');
      throw e; // Ném lỗi để UI hiển thị SnackBar đỏ
    }
  }

  // 3. Hoàn thành công việc (PATCH)
  Future<bool> completeChore(String choreId, int userId) async {
    try {
      final url = '${ApiUrls.chores}/$choreId/complete';
      final response = await http.patch(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"userId": userId}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error completeChore: $e');
      return false;
    }
  }

  Future<bool> updateTemplate(String id, Chore updatedChore) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiUrls.templates}/$id'), // Đảm bảo URL đúng: .../api/chores/templates/:id
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedChore.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error updateTemplate: $e');
      return false;
    }
  }

  // 5. Xóa Template (DELETE)
  Future<bool> deleteTemplate(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiUrls.templates}/$id'),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleteTemplate: $e');
      return false;
    }
  }

  // 6. Thống kê tiến độ hôm nay (GET)
  Future<List<Map<String, dynamic>>> getTodayStats() async {
    try {
      final url = '${ApiUrls.chores}/stats/today';
      
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Backend trả về trực tiếp một mảng JSON: [{...}, {...}]
        final List<dynamic> data = jsonDecode(response.body);
        
        // Ép kiểu sang List<Map> để code UI gợi ý code tốt hơn
        return data.cast<Map<String, dynamic>>();
      } else {
        print("Lỗi tải thống kê: ${response.statusCode} - ${response.body}");
        return []; // Trả về rỗng nếu lỗi
      }
    } catch (e) {
      print('Error getTodayStats: $e');
      return []; // Trả về rỗng để UI không bị crash
    }
  }

  Future<List<Map<String, dynamic>>> getTopLeaderboard() async {
    try {
      final url = '${ApiUrls.chores}/leaderboard/top'; // URL: .../api/chores/leaderboard/top
      
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      print('Error getTopLeaderboard: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getMonthlyLeaderboard(int month, int year) async {
    try {
      // URL ví dụ: .../api/chores/leaderboard/monthly?month=12&year=2025
      final url = '${ApiUrls.chores}/leaderboard/monthly?month=$month&year=$year';
      
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      print('Error getMonthlyLeaderboard: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getScoreHistory(String username, int month, int year) async {
    try {
      // URL ví dụ: .../api/chores/scores/history?username=Long&month=12&year=2025
      final url = '${ApiUrls.chores}/scores/history?username=$username&month=$month&year=$year';
      
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      print('Error getScoreHistory: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getMyScoreStats() async {
    try {
      final url = '${ApiUrls.chores}/scores/my-stats';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getMyScoreStats: $e');
      return null;
    }
  }
}