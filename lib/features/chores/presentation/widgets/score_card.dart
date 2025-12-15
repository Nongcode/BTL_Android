import 'package:flutter/material.dart';
import '../screens/score_detail_screen.dart'; // Nhớ import màn hình chi tiết

class ScoreCard extends StatelessWidget {
  const ScoreCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Bỏ padding ở đây để hiệu ứng bấm tràn ra sát viền
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
      child: Material(
        color: Colors.transparent, // Để lộ màu trắng của Container
        child: InkWell(
          borderRadius: BorderRadius.circular(20), // Bo tròn hiệu ứng bấm
          onTap: () {
            // --- SỰ KIỆN CLICK Ở ĐÂY ---
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ScoreDetailScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20), // Padding nằm bên trong vùng bấm
            child: Column(
              children: [
                // 1. Header: Icon + Tiêu đề + Tháng
                Row(
                  children: [
                    const Icon(Icons.bar_chart_rounded, color: Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      "Điểm tích lũy",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      "Tháng 12 / 2025",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 13
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 2. Các dòng chi tiết điểm
                _buildScoreRow("Điểm thưởng", "+ 10 điểm"),
                const SizedBox(height: 12),

                _buildScoreRow("Điểm xấu", "- 6 điểm"),
                const SizedBox(height: 12),

                // Đường kẻ mờ phân cách
                const Divider(height: 1, color: Colors.black12),
                const SizedBox(height: 12),

                // 3. Tổng điểm (In đậm)
                _buildScoreRow("Tổng điểm tích lũy", "+ 32 điểm", isTotal: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Hàm hỗ trợ vẽ từng dòng điểm
  Widget _buildScoreRow(String label, String score, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        Text(
          score,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.red, // Màu đỏ theo thiết kế
          ),
        ),
      ],
    );
  }
}