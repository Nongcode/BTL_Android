import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class HouseInfoCard extends StatelessWidget {
  const HouseInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Tên nhóm và địa chỉ
          const Text(
            "Nhóm phòng trọ 502: Số 12b, Ngách 354/127/21, Đường Trường Chinh, Hà Nội",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          
          // 2. Thống kê nhanh
          Text(
            "3 thành viên - 12 công việc hôm nay",
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const SizedBox(height: 15),
          
          // 3. Avatar thành viên + Nút thêm
          Row(
            children: [
              // Avatar Stack (Giả lập bằng CircleAvatar)
              _buildAvatar("L", Colors.purple),
              const SizedBox(width: 5), // Chồng lên nhau thì dùng Align/Stack, ở đây để rời cho đơn giản
              _buildAvatar("M", Colors.blue),
              const SizedBox(width: 5),
              _buildAvatar("T", Colors.orange),
              
              const Spacer(),
              
              // Nút thêm thành viên
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.person_add_alt_1, color: Colors.black54),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAvatar(String label, Color color) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: color.withOpacity(0.2),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }
}