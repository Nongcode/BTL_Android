import 'package:flutter/material.dart';
import '../widgets/home_header.dart';
import '../widgets/house_info_card.dart';
import '../widgets/leaderboard_card.dart';
import '../widgets/today_progress_card.dart';
import '../widgets/monthly_fund_card.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onSwitchTab;
  
  const HomeScreen({super.key, required this.onSwitchTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 1. [THAY ĐỔI]: Dùng biến int thay cho GlobalKey
  // Mỗi khi biến này thay đổi, TodayProgressCard sẽ tự load lại
  int _refreshTrigger = 0;

  // Hàm helper để kích hoạt reload (có thể gọi khi cần thiết)
  void _triggerRefresh() {
    if (mounted) {
      setState(() {
        _refreshTrigger++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Thêm màu nền cho sạch (tùy chọn)
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 50.0),
                  child: HomeHeader(),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 280),
                  child: const HouseInfoCard(),
                ),
              ],
            ),

            const LeaderboardCard(),

            // 2. [THAY ĐỔI]: Cập nhật widget TodayProgressCard
            TodayProgressCard(
              // Bỏ dòng key: _progressCardKey
              refreshTrigger: _refreshTrigger, // Truyền trigger vào đây
              onPressed: () {
                // Chuyển sang tab Danh sách công việc
                widget.onSwitchTab(1); 
                
                // (Mẹo): Khi bấm vào xem chi tiết rồi quay lại, 
                // ta nên kích hoạt refresh để cập nhật số liệu mới nhất
                _triggerRefresh();
              },
            ),

            MonthlyFundCard(
              onPressed: () {
                widget.onSwitchTab(2);
              },
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}