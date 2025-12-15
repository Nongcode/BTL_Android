import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/leaderboard_model.dart';
import 'package:btl_android_flutter/features/chores/presentation/screens/score_detail_screen.dart';

class LeaderboardDetailScreen extends StatelessWidget {
  const LeaderboardDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dữ liệu giả lập 3 người
    final List<MemberRank> members = [
      MemberRank(rank: 1, name: "Long", avatar: "L", score: 32, tasksDone: 15, color: Colors.green), // Vàng
      MemberRank(rank: 2, name: "Minh", avatar: "M", score: 28, tasksDone: 13, color: Colors.amber), // Bạc
      MemberRank(rank: 3, name: "Tuân", avatar: "T", score: 25, tasksDone: 10, color: Colors.redAccent), // Đồng
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Bảng xếp hạng chi tiết", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. Header (Có thể thêm Tab chọn tháng ở đây)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            color: Colors.white,
            width: double.infinity,
            child: Column(
              children: [
                Text("Tháng 12 / 2025", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                const Text("Cuộc đua chăm chỉ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
          ),
          
          const SizedBox(height: 10),

          // 2. Danh sách xếp hạng
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                return _buildFullRankCard(context, member); // Truyền context vào đây
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullRankCard(BuildContext context,MemberRank member) {
    // Top 1 sẽ to hơn và đẹp hơn
    final isTop1 = member.rank == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isTop1 ? Border.all(color: member.color, width: 2) : null, // Viền vàng cho Top 1
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
            // Điều hướng sang màn hình chi tiết và TRUYỀN TÊN NGƯỜI ĐÓ SANG
            Navigator.push(
              context, // <--- Lưu ý: Hàm _buildFullRankCard cần có context. Xem hướng dẫn bên dưới để fix lỗi này.
              MaterialPageRoute(
                builder: (context) => ScoreDetailScreen(userName: member.name),
              ),
            );
          },

          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Cột Hạng & Avatar
                Column(
                  children: [
                    if (isTop1) const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD700), size: 30),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: member.color.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        member.avatar,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: member.color), // Màu chữ theo màu hạng
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text("#${member.rank}", style: TextStyle(fontWeight: FontWeight.bold, color: member.color)),
                  ],
                ),
                const SizedBox(width: 20),

                // Cột Thông tin chi tiết
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 5),
                      // Progress Bar nhỏ mô phỏng độ chăm chỉ
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          value: member.score / 50, // Giả sử max là 50 điểm
                          backgroundColor: Colors.grey[200],
                          color: member.color,
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text("${member.tasksDone} công việc hoàn thành", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),

                // Cột Điểm số
                Padding(
                  padding: const EdgeInsets.only(left: 20.0), // <-- Thêm khoảng cách 15px bên trái
                  child: Column(
                    children: [
                      Text(
                        "${member.score}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: AppColors.primary),
                      ),
                      const Text("Điểm", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
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