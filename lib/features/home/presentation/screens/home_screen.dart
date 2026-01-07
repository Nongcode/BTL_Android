import 'package:flutter/material.dart';
import '../widgets/home_header.dart';
import '../widgets/house_info_card.dart';
import '../widgets/leaderboard_card.dart';
import '../widgets/today_progress_card.dart';
import '../widgets/monthly_fund_card.dart';

// 1. Chuyển thành StatefulWidget
class HomeScreen extends StatefulWidget {
  final Function(int) onSwitchTab;

  // Constructor có thể là const vì không chứa GlobalKey trực tiếp nữa
  const HomeScreen({super.key, required this.onSwitchTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 2. Khai báo GlobalKey ở trong State để nó được giữ nguyên khi vẽ lại
  final GlobalKey<TodayProgressCardState> _progressCardKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

            // 3. Gắn Key vào TodayProgressCard
            TodayProgressCard(
              key: _progressCardKey,
              onPressed: () {
                widget.onSwitchTab(1);
              },
            ),

            MonthlyFundCard(
              houseId: 1,
              currentMemberId: 1,
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
