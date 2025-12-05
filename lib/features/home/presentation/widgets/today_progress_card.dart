import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class TodayProgressCard extends StatelessWidget {
  final VoidCallback? onPressed;
  const TodayProgressCard({super.key, this.onPressed});
  

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20), // Cách lề và cách đáy
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Tiêu đề
          const Text(
            "Tiến độ hoàn thành công việc hôm nay",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 20),

          // 2. Danh sách thành viên (Giả lập dữ liệu)
          _buildProgressItem(
            avatarLabel: "M", 
            avatarColor: Colors.pink.shade100, 
            textColor: Colors.pink,
            name: "Minh", 
            progressText: "5/6 công việc"
          ),
          const Divider(height: 25, color: Colors.black12),
          
          _buildProgressItem(
            avatarLabel: "L", 
            avatarColor: Colors.lightGreen.shade100, 
            textColor: Colors.green,
            name: "Long", 
            progressText: "5/6 công việc"
          ),
          const Divider(height: 25, color: Colors.black12),

          _buildProgressItem(
            avatarLabel: "T", 
            avatarColor: Colors.cyan.shade100, 
            textColor: Colors.cyan.shade800,
            name: "Tuân", 
            progressText: "5/6 công việc"
          ),
          
          const SizedBox(height: 20),

          // 3. Nút bấm "Xem chi tiết"
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              // 4. Gọi hàm được truyền vào
              onPressed: onPressed, 
              
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Xem chi tiết công việc hôm nay",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Hàm vẽ từng dòng thành viên
  Widget _buildProgressItem({
    required String avatarLabel,
    required Color avatarColor,
    required Color textColor,
    required String name,
    required String progressText,
  }) {
    return Row(
      children: [
        // Avatar tròn
        CircleAvatar(
          backgroundColor: avatarColor,
          radius: 22,
          child: Text(
            avatarLabel,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
          ),
        ),
        const SizedBox(width: 15),
        
        // Tên
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        
        const Spacer(), // Đẩy phần sau sang phải cùng
        
        // Trạng thái text
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text("Đã hoàn thành", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            Text(
              progressText,
              style: const TextStyle(
                color: Colors.red, // Màu đỏ giống thiết kế
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        )
      ],
    );
  }
}