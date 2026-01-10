import 'dart:math';
import 'package:flutter/material.dart';
// import '../../../../core/constants/app_colors.dart'; // Đảm bảo import đúng đường dẫn của bạn
import '../../../chores/data/service/chore_service.dart';

class TodayProgressCard extends StatefulWidget {
  final VoidCallback? onPressed;
  
  // [MỚI] Biến này dùng để báo hiệu cần load lại dữ liệu
  // Bạn có thể truyền DateTime.now().millisecondsSinceEpoch hoặc một biến đếm tăng dần từ cha
  final int refreshTrigger; 

  const TodayProgressCard({
    super.key, 
    this.onPressed, 
    this.refreshTrigger = 0 // Mặc định là 0
  });

  @override
  State<TodayProgressCard> createState() => TodayProgressCardState();
}

class TodayProgressCardState extends State<TodayProgressCard> {
  final ChoreService _choreService = ChoreService();
  
  List<Map<String, dynamic>> _statsList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData(); // Gọi hàm tải dữ liệu lần đầu
  }

  // [QUAN TRỌNG] Hàm này chạy khi Widget cha truyền tham số mới vào
  @override
  void didUpdateWidget(covariant TodayProgressCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Nếu refreshTrigger thay đổi -> Gọi lại API
    if (oldWidget.refreshTrigger != widget.refreshTrigger) {
      _fetchData(isSilent: true); // isSilent = true để không hiện xoay vòng loading gây nháy
    }
  }

  // Tách hàm fetch data và thêm chế độ tải ngầm (silent)
  Future<void> _fetchData({bool isSilent = false}) async {
    if (!mounted) return;

    // Chỉ hiện loading xoay vòng nếu không phải tải ngầm và chưa có dữ liệu
    if (!isSilent && _statsList.isEmpty) {
       setState(() => _isLoading = true);
    }

    try {
      final data = await _choreService.getTodayStats();
      if (mounted) {
        setState(() {
          _statsList = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Lỗi tải thống kê: $e");
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
          const Text(
            "Tiến độ hoàn thành công việc hôm nay",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 20),

          // Logic hiển thị Loading / Empty / List
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(color: Color(0xFF40C4C6)),
              ),
            )
          else if (_statsList.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  "Hôm nay chưa có công việc nào!", 
                  style: TextStyle(color: Colors.grey)
                )
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _statsList.length,
              separatorBuilder: (context, index) => const Divider(height: 25, color: Colors.black12),
              itemBuilder: (context, index) {
                final item = _statsList[index];
                final name = item['assignee_name'] ?? 'Ẩn danh';
                final total = item['total_chores'] ?? 0;
                final completed = item['completed_chores'] ?? 0;
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

          const SizedBox(height: 20), // Thêm khoảng cách trước nút bấm
          
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: widget.onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF40C4C6),
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
            const Text("Đã hoàn thành", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(
              progressText,
              style: const TextStyle(color: Color(0xFF40C4C6), fontWeight: FontWeight.bold, fontSize: 14), // Sửa màu đỏ thành màu chủ đạo hoặc giữ nguyên tùy bạn
            ),
          ],
        ),
      ],
    );
  }

  Map<String, Color> _getAvatarColors(int index) {
    final List<Map<String, Color>> palette = [
      {'bg': Colors.pink.shade50, 'text': Colors.pink},
      {'bg': Colors.lightGreen.shade50, 'text': Colors.green},
      {'bg': Colors.cyan.shade50, 'text': Colors.cyan.shade800},
      {'bg': Colors.orange.shade50, 'text': Colors.deepOrange},
      {'bg': Colors.purple.shade50, 'text': Colors.purple},
    ];
    return palette[index % palette.length];
  }
}