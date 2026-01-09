import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Cần import thư viện này
import '../../../../core/constants/app_colors.dart';
import '../../data/service/chore_service.dart';

class ScoreDetailScreen extends StatefulWidget {
  // Bỏ tham số cứng nhắc userName đi, chỉ cần tháng/năm
  final int? targetUserId;    // Nếu null -> Lấy ID người đang đăng nhập
  final String? targetUserName; // Tên hiển thị
  
  final int? initialMonth;
  final int? initialYear;

  const ScoreDetailScreen({
    super.key, 
    this.targetUserId,       // <--- Mới thêm
    this.targetUserName,     // <--- Mới thêm
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
  int _totalScore = 0;
  
  // Biến lưu thông tin người dùng hiện tại
  String _currentUserName = ""; 
  int? _currentUserId;

  late int _currentMonth;
  late int _currentYear;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = widget.initialMonth ?? now.month;
    _currentYear = widget.initialYear ?? now.year;
    
    // Bước 1: Load thông tin người dùng trước
    _loadUserData();
  }

  // Hàm lấy thông tin từ bộ nhớ máy (SharedPreferences)
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Lấy dữ liệu đã lưu khi Đăng nhập
    // Lưu ý: Key 'fullName' và 'userId' phải khớp với lúc bạn lưu ở LoginScreen
    final savedName = prefs.getString('fullName') ?? "Bạn";
    
    // Xử lý lấy ID (có thể lưu dạng int hoặc string tùy code cũ của bạn)
    int? savedId;
    if (prefs.containsKey('userId')) {
       final idValue = prefs.get('userId');
       if (idValue is int) {
         savedId = idValue;
       } else if (idValue is String) {
         savedId = int.tryParse(idValue);
       }
    }

    if (mounted) {
      setState(() {
        _currentUserName = savedName;
        _currentUserId = savedId;
      });

      // Bước 2: Sau khi có ID thì mới gọi API lấy lịch sử
      if (_currentUserId != null) {
        _fetchHistory();
      } else {
        print("Lỗi: Không tìm thấy User ID. Vui lòng đăng nhập lại.");
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchHistory() async {
    if (_currentUserId == null) return;

    setState(() => _isLoading = true);
    try {
      // Gọi API với ID thực tế của người dùng
      final data = await _choreService.getScoreHistory(_currentUserId!, _currentMonth, _currentYear);
      
      // Tính tổng điểm
      int total = 0;
      for (var item in data) {
        // Đảm bảo ép kiểu an toàn
        total += (item['points_change'] ?? 0) as int;
      }

      if (mounted) {
        setState(() {
          _historyList = List<Map<String, dynamic>>.from(data);
          _totalScore = total;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Lỗi fetch history: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Helper: Format thời gian
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

  // Helper: Chọn icon
  IconData _getIcon(String? iconType) {
    switch (iconType) {
      case 'water': return Icons.water_drop;
      case 'trash': return Icons.delete_outline;
      case 'shopping': return Icons.shopping_cart_outlined;
      case 'clean': return Icons.cleaning_services;
      case 'cooking': return Icons.soup_kitchen;
      default: return Icons.star_outline;
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
        // Hiển thị tên người dùng động
        title: Text(
          "Lịch sử điểm của $_currentUserName", 
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)
        ),
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
                colors: [const Color(0xFF40C4C6), const Color(0xFF40C4C6).withOpacity(0.8)],
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.history, color: Colors.grey),
                SizedBox(width: 8),
                Text("Hoạt động chi tiết", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
          ),

          // 3. Danh sách
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF40C4C6)))
              : _historyList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history_toggle_off, size: 60, color: Colors.grey[300]),
                          const SizedBox(height: 10),
                          Text("Chưa có lịch sử điểm tháng $_currentMonth", style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _historyList.length,
                      separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.black12),
                      itemBuilder: (context, index) {
                        final item = _historyList[index];
                        final points = (item['points_change'] ?? 0) as int;
                        final isBonus = points > 0;
                        // Ưu tiên lấy title từ việc nhà, nếu không có lấy lý do
                        final title = item['chore_title'] ?? item['reason'] ?? "Thay đổi điểm";
                        final timeStr = _formatTime(item['created_at']);
                        final iconData = _getIcon(item['icon_type']);

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              // Icon nền màu
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
                              
                              // Nội dung text
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

                              // Số điểm (+10 hoặc -5)
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