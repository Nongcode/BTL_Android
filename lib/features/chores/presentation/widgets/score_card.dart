import 'package:flutter/material.dart';

class ScoreCard extends StatelessWidget {
  const ScoreCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. Header: Icon + Tiêu đề + Tháng
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded, color: Colors.grey, size: 20),
              const SizedBox(width: 8),
              const Text(
                "Điểm tích lũy tháng của bạn",
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
    );
  }

  // Hàm hỗ trợ vẽ từng dòng điểm cho gọn code
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