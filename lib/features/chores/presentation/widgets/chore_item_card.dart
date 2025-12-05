import 'package:flutter/material.dart';

class ChoreItemCard extends StatelessWidget {
  final String title;
  final String assignee;
  final bool isDone;
  final VoidCallback? onTapButton; // Hàm xử lý khi bấm nút

  const ChoreItemCard({
    super.key,
    required this.title,
    required this.assignee,
    required this.isDone,
    this.onTapButton,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // Icon minh họa bên trái
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            // Đổi icon tùy trạng thái
            child: Icon(
              isDone ? Icons.check_circle_outline : Icons.cleaning_services_outlined,
              color: Colors.black54,
              size: 24,
            ),
          ),
          const SizedBox(width: 15),

          // Tên việc + Người làm
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                    children: [
                      const TextSpan(text: "Phân công: "),
                      TextSpan(text: assignee, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Nút bấm trạng thái (Quan trọng)
          InkWell(
            onTap: isDone ? null : onTapButton, // Nếu xong rồi thì không bấm được nữa
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDone ? const Color(0xFF66CC33) : const Color(0xFFFFC107), // Xanh lá hoặc Vàng
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isDone ? "Hoàn thành" : "Chưa làm",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          )
        ],
      ),
    );
  }
}