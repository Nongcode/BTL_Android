import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:btl_android_flutter/features/chores/presentation/screens/score_detail_screen.dart';
// Import service và model
import '../../../chores/data/service/chore_service.dart';
// Nếu bạn chưa có file model riêng, có thể dùng class MemberRank định nghĩa ở dưới cùng file này

class LeaderboardDetailScreen extends StatefulWidget {
  const LeaderboardDetailScreen({super.key});

  @override
  State<LeaderboardDetailScreen> createState() => _LeaderboardDetailScreenState();
}

class _LeaderboardDetailScreenState extends State<LeaderboardDetailScreen> {
  final ChoreService _choreService = ChoreService();
  
  // Quản lý thời gian đang chọn
  DateTime _selectedDate = DateTime.now();
  
  // Dữ liệu và trạng thái loading
  List<MemberRank> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Hàm gọi API
  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    
    try {
      final rawData = await _choreService.getMonthlyLeaderboard(
        _selectedDate.month, 
        _selectedDate.year
      );

      // Map dữ liệu từ API sang Model MemberRank
      List<MemberRank> mappedMembers = [];
      for (int i = 0; i < rawData.length; i++) {
        final item = rawData[i];
        
        // Xử lý màu sắc
        Color rankColor = Colors.blueGrey;
        if (i == 0) rankColor = Colors.green; // Top 1 (hoặc Vàng)
        else if (i == 1) rankColor = Colors.amber; // Top 2
        else if (i == 2) rankColor = Colors.redAccent; // Top 3

        mappedMembers.add(MemberRank(
          rank: i + 1,
          name: item['username'] ?? 'Unknown',
          avatar: (item['username'] != null && item['username'].isNotEmpty) 
              ? item['username'][0].toUpperCase() 
              : "?",
          score: item['total_score'] ?? 0,
          tasksDone: item['tasks_done'] ?? 0,
          color: rankColor,
        ));
      }

      if (mounted) {
        setState(() {
          _members = mappedMembers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Hàm đổi tháng
  void _changeMonth(int offset) {
    setState(() {
      // Cộng/Trừ tháng
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + offset);
    });
    _fetchData(); // Gọi lại API
  }

  @override
  Widget build(BuildContext context) {
    String monthLabel = DateFormat('MM / yyyy').format(_selectedDate);

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
          // 1. Header chọn tháng (Đã nâng cấp)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            color: Colors.white,
            width: double.infinity,
            child: Column(
              children: [
                // Hàng điều hướng tháng
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_left, size: 30, color: Colors.grey),
                      onPressed: () => _changeMonth(-1), // Lùi 1 tháng
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Tháng $monthLabel",
                        style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_right, size: 30, color: Colors.grey),
                      onPressed: () {
                        // Logic chặn không cho chọn tháng tương lai (nếu muốn)
                        if (_selectedDate.isBefore(DateTime(DateTime.now().year, DateTime.now().month))) {
                             _changeMonth(1); // Tiến 1 tháng
                        }
                      }, 
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                const Text("Cuộc đua chăm chỉ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
          ),
          
          const SizedBox(height: 10),

          // 2. Danh sách xếp hạng
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _members.isEmpty 
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bar_chart, size: 60, color: Colors.grey[300]),
                          const SizedBox(height: 10),
                          Text("Tháng này chưa có dữ liệu!", style: TextStyle(color: Colors.grey[500])),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _members.length,
                      itemBuilder: (context, index) {
                        final member = _members[index];
                        return _buildFullRankCard(context, member);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullRankCard(BuildContext context, MemberRank member) {
    // Top 1 sẽ có viền
    final isTop1 = member.rank == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isTop1 ? Border.all(color: member.color, width: 2) : null,
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
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: member.color),
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
                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          value: (member.score / 100).clamp(0.0, 1.0), // Giả sử max là 100
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

                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Column(
                    children: [
                      Text(
                        "${member.score}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 24, 
                          // [LOGIC MỚI] Nếu điểm âm thì màu đỏ, dương thì màu xanh
                          color: member.score < 0 ? Colors.red : const Color(0xFF40C4C6), 
                        ),
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

// Nếu bạn chưa có file model riêng, dùng tạm class này
class MemberRank {
  final int rank;
  final String name;
  final String avatar;
  final int score;
  final int tasksDone;
  final Color color;

  MemberRank({
    required this.rank,
    required this.name,
    required this.avatar,
    required this.score,
    required this.tasksDone,
    required this.color,
  });
}