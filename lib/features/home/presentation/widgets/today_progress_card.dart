import 'dart:math'; // Để random màu avatar
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../chores/data/service/chore_service.dart';

class TodayProgressCard extends StatefulWidget {
  final VoidCallback? onPressed;
  const TodayProgressCard({super.key, this.onPressed});

  @override
  State<TodayProgressCard> createState() => _TodayProgressCardState();
}

class _TodayProgressCardState extends State<TodayProgressCard> {
  final ChoreService _choreService = ChoreService();
  
  // Biến lưu dữ liệu thống kê
  List<Map<String, dynamic>> _statsList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  // Hàm gọi API
  Future<void> _fetchStats() async {
    try {
      // Giả sử bạn đã thêm hàm getTodayStats vào ChoreService
      // Nếu chưa, hãy xem phần ghi chú bên dưới code này
      final data = await _choreService.getTodayStats(); 
      if (mounted) {
        setState(() {
          _statsList = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Lỗi tải thống kê: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Tiêu đề
          const Text(
            "Tiến độ hoàn thành công việc hôm nay",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 20),

          // 2. Danh sách thành viên (Dynamic)
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_statsList.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text("Hôm nay chưa có công việc nào!", style: TextStyle(color: Colors.grey))),
            )
          else
            ListView.separated(
              shrinkWrap: true, // Quan trọng để nằm trong Column
              physics: const NeverScrollableScrollPhysics(), // Không cuộn riêng
              itemCount: _statsList.length,
              separatorBuilder: (context, index) => const Divider(height: 25, color: Colors.black12),
              itemBuilder: (context, index) {
                final item = _statsList[index];
                final name = item['assignee_name'] ?? 'Ẩn danh';
                final total = item['total_chores'] ?? 0;
                final completed = item['completed_chores'] ?? 0;

                // Tạo màu ngẫu nhiên hoặc cố định dựa trên tên
                final colors = _getAvatarColors(index);

                return _buildProgressItem(
                  avatarLabel: name.isNotEmpty ? name[0].toUpperCase() : "?",
                  avatarColor: colors['bg']!,
                  textColor: colors['text']!,
                  name: name,
                  progressText: "$completed/$total công việc",
                );
              },
            ),
          // 3. Nút bấm
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: widget.onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF40C4C6), // AppColors.primary
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text(
                "Xem chi tiết công việc hôm nay",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem({
    required String avatarLabel,
    required Color avatarColor,
    required Color textColor,
    required String name,
    required String progressText,
  }) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: avatarColor,
          radius: 22,
          child: Text(
            avatarLabel,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor),
          ),
        ),
        const SizedBox(width: 15),
        Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text("Đã hoàn thành", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            Text(
              progressText,
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  // Hàm phụ trợ để lấy màu sắc đẹp cho avatar
  Map<String, Color> _getAvatarColors(int index) {
    final List<Map<String, Color>> palette = [
      {'bg': Colors.pink.shade100, 'text': Colors.pink},
      {'bg': Colors.lightGreen.shade100, 'text': Colors.green},
      {'bg': Colors.cyan.shade100, 'text': Colors.cyan.shade800},
      {'bg': Colors.orange.shade100, 'text': Colors.deepOrange},
      {'bg': Colors.purple.shade100, 'text': Colors.purple},
    ];
    return palette[index % palette.length];
  }
}