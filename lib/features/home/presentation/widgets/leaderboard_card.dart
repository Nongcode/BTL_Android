import 'package:flutter/material.dart';

class LeaderboardCard extends StatelessWidget {
  const LeaderboardCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
        children: [
          // Header của Card
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Bảng xếp hạng chăm chỉ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text("Tháng 12 / 2025", style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 15),
          
          // Danh sách xếp hạng
          _buildRankItem(rank: "#1", name: "Long", tasks: 15, score: 32, rankColor: Colors.green),
          _buildRankItem(rank: "#2", name: "Minh", tasks: 13, score: 28, rankColor: Colors.amber),
          _buildRankItem(rank: "#3", name: "Tuân", tasks: 10, score: 25, rankColor: Colors.redAccent),
        ],
      ),
    );
  }

  Widget _buildRankItem({
    required String rank, 
    required String name, 
    required int tasks, 
    required int score, 
    required Color rankColor
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Text(rank, style: TextStyle(color: rankColor, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text("$tasks công việc đã xong", style: TextStyle(color: Colors.red[400], fontSize: 12)),
            ],
          ),
          const Spacer(),
          Text("+ $score điểm", style: TextStyle(color: Colors.red[500], fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}