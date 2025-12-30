import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
// Import Service
import '../../data/service/chore_service.dart';

class ScoreDetailScreen extends StatefulWidget {
  final String userName;
  // Nhận thêm tháng/năm để biết đang xem lịch sử của tháng nào (Mặc định là hiện tại)
  final int? initialMonth;
  final int? initialYear;

  const ScoreDetailScreen({
    super.key, 
    this.userName = "Long",
    this.initialMonth,
    this.initialYear
  });

  @override
  State<ScoreDetailScreen> createState() => _ScoreDetailScreenState();
}

class _ScoreDetailScreenState extends State<ScoreDetailScreen> {
  final ChoreService _choreService = ChoreService();
  
  List<Map<String, dynamic>> _historyList = [];
  bool _isLoading = true;
  int _totalScore = 0; // Tính tổng điểm để hiển thị trên header

  late int _currentMonth;
  late int _currentYear;

  @override
  void initState() {
    super.initState();
    // Khởi tạo tháng năm (nếu không truyền thì lấy hiện tại)
    final now = DateTime.now();
    _currentMonth = widget.initialMonth ?? now.month;
    _currentYear = widget.initialYear ?? now.year;
    
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);
    try {
      final data = await _choreService.getScoreHistory(widget.userName, _currentMonth, _currentYear);
      
      // Tính tổng điểm từ danh sách trả về
      int total = 0;
      for (var item in data) {
        total += (item['points_change'] as int);
      }

      if (mounted) {
        setState(() {
          _historyList = data;
          _totalScore = total;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Hàm helper để format thời gian (Hôm nay, Hôm qua...)
  String _formatTime(String? dateString) {
    if (dateString == null) return "";
    DateTime date = DateTime.parse(dateString).toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    String timePart = DateFormat('HH:mm').format(date);

    if (checkDate == today) {
      return "Hôm nay, $timePart";
    } else if (checkDate == yesterday) {
      return "Hôm qua, $timePart";
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  // Hàm helper để lấy Icon (Bạn có thể map string từ DB sang IconData ở đây)
  IconData _getIcon(String? iconType) {
    // Ví dụ đơn giản, bạn có thể mở rộng map này
    switch (iconType) {
      case 'water': return Icons.water_drop;
      case 'trash': return Icons.delete_outline;
      case 'shopping': return Icons.shopping_cart_outlined;
      case 'clean': return Icons.cleaning_services;
      default: return Icons.star_outline; // Icon mặc định
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Lịch sử điểm của ${widget.userName}", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
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
                colors: [const Color(0xFF40C4C6), const Color(0xFF40C4C6).withOpacity(0.8)], // AppColors.primary
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF40C4C6).withOpacity(0.3),
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
                  children: [
                    Text("Tổng điểm tháng $_currentMonth", style: const TextStyle(color: Colors.white, fontSize: 16)),
                    const SizedBox(height: 5),
                    Text(
                      "$_totalScore Điểm", 
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)
                    ),
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
                Text("Hoạt động chi tiết", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
          ),

          // 3. Danh sách lịch sử (Dynamic)
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _historyList.isEmpty
                  ? Center(child: Text("Chưa có lịch sử điểm tháng $_currentMonth", style: const TextStyle(color: Colors.grey)))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _historyList.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = _historyList[index];
                        final points = item['points_change'] as int;
                        final isBonus = points > 0;
                        final title = item['chore_title'] ?? item['reason'] ?? "Điểm thưởng/phạt";
                        final timeStr = _formatTime(item['created_at']);
                        final iconData = _getIcon(item['icon_type']);

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              // Icon
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isBonus ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  iconData,
                                  color: isBonus ? Colors.green : Colors.red,
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
                                      title,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      timeStr,
                                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),

                              // Điểm số
                              Text(
                                "${isBonus ? '+' : ''}$points",
                                style: TextStyle(
                                  color: isBonus ? Colors.green : Colors.red,
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