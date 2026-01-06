import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Để format tháng
import '../screens/score_detail_screen.dart';
import '../../data/service/chore_service.dart';

class ScoreCard extends StatefulWidget {
  const ScoreCard({super.key});

  @override
  State<ScoreCard> createState() => _ScoreCardState();
}

class _ScoreCardState extends State<ScoreCard> {
  final ChoreService _choreService = ChoreService();
  
  // Biến lưu dữ liệu
  int _bonus = 0;
  int _penalty = 0;
  int _total = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final data = await _choreService.getMyScoreStats();
      if (mounted && data != null) {
        setState(() {
          _bonus = data['bonus_points'] ?? 0;
          _penalty = data['penalty_points'] ?? 0;
          _total = data['total_points'] ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentMonth = DateFormat('MM / yyyy').format(DateTime.now());

    return Container(
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
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ScoreDetailScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 1. Header
                Row(
                  children: [
                    const Icon(Icons.bar_chart_rounded, color: Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      "Điểm tích lũy",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                    ),
                    const Spacer(),
                    Text(
                      "Tháng $currentMonth",
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 2. Nội dung (Loading hoặc Data)
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  Column(
                    children: [
                      _buildScoreRow("Điểm thưởng", "+ $_bonus điểm", Colors.green), // Màu xanh cho điểm thưởng
                      const SizedBox(height: 12),

                      _buildScoreRow("Điểm xấu", "$_penalty điểm", Colors.red), // Màu đỏ cho điểm phạt
                      const SizedBox(height: 12),

                      const Divider(height: 1, color: Colors.black12),
                      const SizedBox(height: 12),

                      // Tổng điểm: Nếu dương màu xanh, âm màu đỏ
                      _buildScoreRow(
                        "Tổng điểm tích lũy", 
                        "${_total > 0 ? '+' : ''} $_total điểm", 
                        _total >= 0 ? Colors.red : Colors.red, // Design của bạn đang dùng màu đỏ cho tổng điểm
                        isTotal: true
                      ),
                    ],
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreRow(String label, String score, Color color, {bool isTotal = false}) {
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
            color: color,
          ),
        ),
      ],
    );
  }
}