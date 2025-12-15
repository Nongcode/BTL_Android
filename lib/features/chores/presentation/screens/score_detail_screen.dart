import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart'; // Import file màu của bạn
import '../../data/models/score_history_model.dart';

class ScoreDetailScreen extends StatelessWidget {
  final String userName;
  const ScoreDetailScreen({super.key, this.userName = "Long"});

  @override
  Widget build(BuildContext context) {
    // Dữ liệu giả lập
    final List<ScoreHistoryItem> historyList = [
      ScoreHistoryItem(title: "Rửa bát (Làm hộ Tuân)", time: "Hôm nay, 19:30", points: 2, isBonus: true, icon: Icons.clean_hands_rounded),
      ScoreHistoryItem(title: "Đổ rác đúng giờ", time: "Hôm nay, 07:00", points: 1, isBonus: true, icon: Icons.delete_outline),
      ScoreHistoryItem(title: "Quên tắt điện nhà tắm", time: "Hôm qua, 22:15", points: -2, isBonus: false, icon: Icons.lightbulb_outline),
      ScoreHistoryItem(title: "Lau nhà sạch sẽ", time: "Hôm qua, 18:00", points: 5, isBonus: true, icon: Icons.cleaning_services),
      ScoreHistoryItem(title: "Đi chợ mua thức ăn", time: "10/12/2025", points: 3, isBonus: true, icon: Icons.shopping_cart_outlined),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Lịch sử điểm của $userName", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. Header Tổng điểm
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Tổng điểm tháng 12", style: TextStyle(color: Colors.white, fontSize: 16)),
                    SizedBox(height: 5),
                    Text("32 Điểm", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 40),
                ),
              ],
            ),
          ),

          // 2. Tiêu đề danh sách
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: const [
                Icon(Icons.history, color: Colors.grey),
                SizedBox(width: 8),
                Text("Hoạt động gần đây", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
          ),

          // 3. Danh sách lịch sử
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: historyList.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = historyList[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: item.isBonus ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item.icon,
                          color: item.isBonus ? Colors.green : Colors.red,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 15),
                      
                      // Nội dung
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.time,
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                      ),

                      // Điểm số
                      Text(
                        "${item.isBonus ? '+' : ''}${item.points}",
                        style: TextStyle(
                          color: item.isBonus ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}