import 'package:flutter/material.dart';
import '../widgets/home_header.dart';
import '../widgets/house_info_card.dart';
import '../widgets/leaderboard_card.dart';
import '../widgets/today_progress_card.dart';
import '../widgets/monthly_fund_card.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onSwitchTab;
  const HomeScreen({super.key, required this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        // Cho phép cuộn nếu màn hình nhỏ
        child: Column(
          children: [
            Stack(
              children: [
                // 1. Header cong làm nền
                const Padding(
                  padding: EdgeInsets.only(
                    bottom: 50.0,
                  ), // Chừa chỗ cho Card đè lên
                  child: HomeHeader(),
                ),

                // 2. Card thông tin đè lên phần dưới của Header
                // Dùng Positioned hoặc đơn giản là Margin âm (thủ thuật hay dùng)
                Container(
                  margin: const EdgeInsets.only(
                    top: 280,
                  ), // Đẩy xuống đè lên Header
                  child: const HouseInfoCard(),
                ),
              ],
            ),

            // 3. Bảng xếp hạng
            const LeaderboardCard(),

            TodayProgressCard(
              onPressed: () {
                // Khi bấm nút, ta gọi hàm onSwitchTab và truyền số 1 (Tab Việc nhà)
                onSwitchTab(1);
              },
            ),

            // Quỹ chung tháng này
            MonthlyFundCard(
              onPressed: () {
                // Chuyển sang tab Quỹ chung (index 2)
                onSwitchTab(2);
              },
            ),

            // 4. Các phần khác (Tiến độ)... để sau
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
