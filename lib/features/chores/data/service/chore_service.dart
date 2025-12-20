import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_urls.dart';
import '../models/chore_model.dart';

class ChoreService {
  
  // 1. Lấy danh sách việc hôm nay (GET)
  // Logic: API trả về JSON -> Model convert thành Object
  Future<List<Chore>> getTodayChores() async {
    try {
      final response = await http.get(Uri.parse(ApiUrls.todayChores));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        
        if (body['success'] == true) {
          final List<dynamic> data = body['data'];
          // Model Chore.fromJson sẽ tự lo phần map snake_case sang camelCase
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
  // SỬA ĐỔI LỚN: Thay vì truyền title, points... ta truyền thẳng object Chore
  Future<bool> createChoreTemplate(Chore newChore) async {
    try {
      // Gọi hàm toJson() của Model để đóng gói dữ liệu
      // Hàm này đã tự xử lý việc map sang snake_case (base_points, icon_type...)
      final Map<String, dynamic> bodyData = newChore.toJson();

      // LOGIC XỬ LÝ ID USER (Tạm thời):
      // Vì UI đang trả về tên "Minh", "Tuân"... nhưng Backend cần ID (1, 2, 3)
      // Ta xử lý nhanh ở đây (Sau này nên làm chuẩn từ Dropdown)
      int mapUserToId(String name) {
        if (name.contains('Long')) return 1;
        if (name.contains('Minh')) return 2;
        if (name.contains('Tuân')) return 3;
        return 1; // Mặc định
      }

      // Backend cần rotation_order là mảng ID [1, 2, 3]
      // Ta tạo logic giả: Luôn xoay vòng qua 3 người này
      bodyData['rotation_order'] = [1, 2, 3]; 
      
      // Override lại assignee_id dựa trên tên người dùng chọn
      // (Lưu ý: Với Template xoay vòng, assignee_id ban đầu không quá quan trọng, nhưng cứ gửi cho đủ)
      bodyData['assignee_id'] = mapUserToId(newChore.assigneeName); 

      print("Body gửi đi: ${jsonEncode(bodyData)}"); // Log để debug

      final response = await http.post(
        Uri.parse(ApiUrls.templates),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bodyData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print("Lỗi tạo mới: ${response.body}");
        return false;
      }
    } catch (e) {
      print('Error createChore: $e');
      return false;
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
}