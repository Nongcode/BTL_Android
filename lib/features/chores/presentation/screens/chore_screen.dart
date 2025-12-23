import 'package:btl_android_flutter/features/chores/data/service/chore_service.dart';
import 'package:flutter/material.dart';
import '../../data/models/chore_model.dart';
import '../widgets/chore_stat_card.dart';
import '../widgets/chore_item_card.dart';
import '../widgets/score_card.dart';
import 'add_chore_screen.dart'; // <--- Import màn hình thêm mới
import 'chore_detail_screen.dart';

class ChoreScreen extends StatefulWidget {
  const ChoreScreen({super.key});

  @override
  State<ChoreScreen> createState() => _ChoreScreenState();
}

class _ChoreScreenState extends State<ChoreScreen> {
  // 1. Khởi tạo Service
  final ChoreService _choreService = ChoreService();
  
  // 2. Biến trạng thái
  int _selectedTabIndex = 0;
  List<Chore> allChores = []; // List rỗng, sẽ được lấp đầy bởi API
  bool _isLoading = true;     // Trạng thái đang tải

  @override
  void initState() {
    super.initState();
    _fetchTodayChores();
  }

  // --- HÀM GỌI API LẤY DANH SÁCH ---
  Future<void> _fetchTodayChores() async {
    setState(() => _isLoading = true); // Hiện loading
    try {
      final chores = await _choreService.getTodayChores(); // Gọi Service lấy việc hôm nay
      setState(() {
        allChores = chores;
        _isLoading = false;
      });
    } catch (e) {
      print("Lỗi tải dữ liệu: $e");
      setState(() => _isLoading = false);
    }
  }

  // Hàm lọc danh sách
  List<Chore> get filteredChores {
    if (_selectedTabIndex == 1) {
      return allChores.where((chore) => chore.isDone == true).toList();
    } else if (_selectedTabIndex == 2) {
      return allChores.where((chore) => chore.isDone == false).toList();
    }
    return allChores;
  }

  // Hàm tính toán
  int get totalCount => allChores.length;
  int get doneCount => allChores.where((c) => c.isDone).length;
  int get pendingCount => allChores.where((c) => !c.isDone).length;

  // --- HÀM XỬ LÝ HOÀN THÀNH CÔNG VIỆC (GỌI API) ---
  void _showConfirmDialog(Chore chore) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
                  children: [
                    const TextSpan(text: "Xác nhận hoàn thành công việc "),
                    TextSpan(
                      text: "'${chore.title}'",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                    const TextSpan(text: " giúp "),
                    TextSpan(
                      // Lưu ý: Dùng assigneeName khớp với Model mới
                      text: "${chore.assigneeName} ?",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Điểm thưởng dự kiến", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("+ ${chore.points} điểm", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Hủy", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context); // Tắt popup trước
                        
                        // GỌI API COMPLETE
                        // Giả sử User hiện tại là ID 1 (Long)
                        final success = await _choreService.completeChore(chore.id, 1);

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Thành công! Điểm đã được cộng.'), backgroundColor: Colors.green),
                          );
                          _fetchTodayChores(); // Tải lại danh sách để cập nhật giao diện
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Lỗi kết nối Server!'), backgroundColor: Colors.red),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF66CC33),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Xác nhận", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  // --- HÀM THÊM MỚI (GỌI API) ---
  void _navigateToAddScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddChoreScreen()),
    );

    // Nếu có dữ liệu trả về từ màn hình Add
    if (result != null && result is Chore) {
      // Gọi API tạo mới
      final success = await _choreService.createTemplate(result);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã tạo việc mẫu: ${result.title}'),
            backgroundColor: Colors.green,
          ),
        );
        // Lưu ý: Việc mới tạo là Template, có thể chưa hiện ngay ở danh sách Today
        // trừ khi Backend có logic tự sinh việc. Ta cứ load lại cho chắc.
        _fetchTodayChores(); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tạo thất bại!'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ... (Giữ nguyên các hàm _buildTextFieldInput, _buildDropdownInput nếu bạn dùng cho mục đích khác, 
  // nhưng ở màn hình này có vẻ không dùng đến vì đã tách sang AddChoreScreen)

  @override
  Widget build(BuildContext context) {
    final currentList = filteredChores;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0), // Padding này để tránh bị che bởi BottomBar (nếu có)
        child: FloatingActionButton(
          onPressed: () async {
            // 1. Chờ kết quả từ màn hình thêm mới
            final newChore = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddChoreScreen()),
            );

            // 2. Kiểm tra kết quả trả về
            if (newChore != null) {
              // --- BƯỚC QUAN TRỌNG: GỌI API LƯU XUỐNG DB ---
              // (Hiển thị loading nhẹ hoặc thông báo nếu cần)
              try {
                  // Giả sử bạn đã inject ChoreService vào biến _choreService
                  // Hàm này sẽ gửi newChore.toJson() lên server
                  await _choreService.createTemplate(newChore); 

                  // 3. Sau khi lưu thành công thì mới load lại danh sách
                  _fetchTodayChores();
                  
                  // (Tùy chọn) Hiện thông báo thành công
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Thêm công việc thành công!"), backgroundColor: Colors.green),
                  );
              } catch (e) {
                  print("Lỗi tạo việc: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red),
                  );
              }
            }
          },

          backgroundColor: const Color(0xFF40C4C6),
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 40),
        ),
      ),

      body: SafeArea(
        // Hiển thị Loading khi đang gọi API
        child: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF40C4C6)))
        : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Ảnh banner
                Center(
                  child: Container(
                    height: 200,
                    margin: const EdgeInsets.only(bottom: 20, top: 30),
                    child: Image.asset('assets/images/chore_banner.png', fit: BoxFit.contain),
                  ),
                ),

                // 2. Thẻ Thống Kê
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ChoreStatCard(
                        title: "Tất cả",
                        count: "$totalCount việc",                      
                        iconColor: Colors.cyan,
                        titleColor: Colors.blue,
                        isSelected: _selectedTabIndex == 0,
                        onTap: () => setState(() => _selectedTabIndex = 0),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ChoreStatCard(
                        title: "Đã xong",
                        count: "$doneCount việc",
                        iconColor: Colors.green,
                        titleColor: Colors.green,
                        isSelected: _selectedTabIndex == 1,
                        onTap: () => setState(() => _selectedTabIndex = 1),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ChoreStatCard(
                        title: "Chưa làm",
                        count: "$pendingCount việc",
                        iconColor: Colors.redAccent,
                        titleColor: Colors.red,
                        isSelected: _selectedTabIndex == 2,
                        onTap: () => setState(() => _selectedTabIndex = 2),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // Thẻ điểm
                const ScoreCard(),

                const SizedBox(height: 25),

                // 3. Danh sách công việc
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withAlpha((0.05 * 255).round()), blurRadius: 10, offset: const Offset(0, 5))
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Danh sách công việc", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text("Hôm nay: ${currentList.length}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(),

                      if (currentList.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: Text("Chưa có công việc nào!", style: TextStyle(color: Colors.grey)),
                        )
                      else
                        ...currentList.map((chore) {
                          return ChoreItemCard(
                            title: chore.title,
                            assignee: chore.assigneeName, 
                            isDone: chore.isDone,
                            iconAsset: chore.iconAsset,
                            onTapButton: () {
                              _showConfirmDialog(chore);
                            },
                            onTapCard: () async {
                              // 1. Chờ kết quả từ màn hình chi tiết
                              // result sẽ là true nếu người dùng bấm "Lưu" hoặc "Xóa" thành công
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChoreDetailScreen(chore: chore),
                                ),
                              );

                              // 2. Chỉ cần kiểm tra nếu có thay đổi (result == true) thì load lại
                              if (result == true) {
                                _fetchTodayChores(); 
                                // Hàm này sẽ tự gọi setState và làm mới danh sách, 
                                // bạn không cần tự removeWhere thủ công nữa cho đỡ rối.
                              }
                            },
                          );
                        }),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}