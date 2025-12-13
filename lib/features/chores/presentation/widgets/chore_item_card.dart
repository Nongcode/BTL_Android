import 'package:flutter/material.dart';

class ChoreItemCard extends StatelessWidget {
  final String title;
  final String assignee;
  final bool isDone;
  final String iconAsset;
  final VoidCallback? onTapButton; // Hàm xử lý khi bấm nút
  final VoidCallback? onTapCard;

  const ChoreItemCard({
    super.key,
    required this.title,
    required this.assignee,
    required this.isDone,
    required this.iconAsset,
    this.onTapButton,
    this.onTapCard,
  });

 @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      // --- SỬA LỖI: Bọc InkWell trong Material ---
      child: Material(
        color: Colors.transparent, // Để màu nền trong suốt, không che mất background
        child: InkWell(
          onTap: onTapCard,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(8.0), 
            child: Row(
              children: [
                // 1. Ảnh minh họa
                Container(
                  padding: const EdgeInsets.all(10),
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    iconAsset,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 15),

                // 2. Thông tin chữ
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 12, color: Colors.black87),
                          children: [
                            const TextSpan(text: "Phân công: "),
                            TextSpan(text: assignee, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. Nút bấm trạng thái (Lồng InkWell con)
                // Cần bọc Material ở đây nữa để đảm bảo an toàn tuyệt đối
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isDone ? null : onTapButton,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDone ? const Color(0xFF66CC33) : const Color(0xFFFFC107),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isDone ? "Hoàn thành" : "Chưa làm",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}