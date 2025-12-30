import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Cần import intl để format ngày tháng
import '../screens/leaderboard_detail_screen.dart';
import '../../../chores/data/service/chore_service.dart';
import '../../../../core/constants/app_colors.dart'; // Import màu nếu có

class LeaderboardCard extends StatefulWidget {
  const LeaderboardCard({super.key});

  @override
  State<LeaderboardCard> createState() => _LeaderboardCardState();
}

class _LeaderboardCardState extends State<LeaderboardCard> {
  final ChoreService _choreService = ChoreService();
  List<Map<String, dynamic>> _leaderboard = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    try {
      final data = await _choreService.getTopLeaderboard();
      if (mounted) {
        setState(() {
          _leaderboard = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy tháng hiện tại (Ví dụ: Tháng 12 / 2025)
    String currentMonth = DateFormat('MM / yyyy').format(DateTime.now());

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
              MaterialPageRoute(builder: (context) => const LeaderboardDetailScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Bảng xếp hạng chăm chỉ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("Tháng $currentMonth", style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 15),

                // Danh sách (Loading hoặc Data)
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_leaderboard.isEmpty)
                   const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Text("Chưa có dữ liệu tháng này", style: TextStyle(color: Colors.grey)),
                  )
                else
                  ..._leaderboard.asMap().entries.map((entry) {
                    int idx = entry.key;
                    var item = entry.value;
                    
                    // Logic màu sắc cho Top 1, 2, 3
                    Color rankColor;
                    if (idx == 0) rankColor = const Color(0xFFFFD700); // Vàng (Gold)
                    else if (idx == 1) rankColor = const Color(0xFFC0C0C0); // Bạc (Silver)
                    else rankColor = const Color(0xFFCD7F32); // Đồng (Bronze)

                    return _buildRankItem(
                      rank: "#${idx + 1}",
                      name: item['username'] ?? 'Unknown',
                      tasks: item['tasks_done'] ?? 0,
                      score: item['total_score'] ?? 0,
                      rankColor: rankColor,
                    );
                  }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRankItem({
    required String rank,
    required String name,
    required int tasks,
    required int score,
    required Color rankColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          SizedBox(
            width: 30, // Cố định chiều rộng rank để thẳng hàng
            child: Text(rank, style: TextStyle(color: rankColor, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          const SizedBox(width: 10),
          Expanded( // Dùng Expanded để tên dài không bị lỗi overflow
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
          ),
          Text(" $score điểm", style: TextStyle(color: Colors.red[500], fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}