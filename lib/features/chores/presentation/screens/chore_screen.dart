import 'package:flutter/material.dart';
import '../../data/models/chore_model.dart';
import '../widgets/chore_stat_card.dart';
import '../widgets/chore_item_card.dart';
import '../widgets/score_card.dart';

class ChoreScreen extends StatefulWidget {
  const ChoreScreen({super.key});

  @override
  State<ChoreScreen> createState() => _ChoreScreenState();
}

class _ChoreScreenState extends State<ChoreScreen> {
  // Biến theo dõi tab đang chọn: 0=Tất cả, 1=Đã xong, 2=Chưa xong
  int _selectedTabIndex = 0;

  // 1. DỮ LIỆU ẢO (MOCK DATA)
  // Đổi tên thành allChores để khớp với logic bên dưới
  List<Chore> allChores = [
    Chore(
      id: '1', 
      title: 'Quét nhà lau nhà', 
      assignee: 'Minh', 
      isDone: true, 
      iconAsset: 'assets/images/icons/broom.png' // <--- Ảnh cái chổi
    ),
    Chore(
      id: '2', 
      title: 'Phơi quần áo', 
      assignee: 'Tuân', 
      isDone: true,
      iconAsset: 'assets/images/icons/laundry.png' // <--- Ảnh quần áo
    ),
    Chore(
      id: '3', 
      title: 'Đi chợ mua thức ăn', 
      assignee: 'Tuân', 
      isDone: false,
      iconAsset: 'assets/images/icons/grocery.png' // <--- Ảnh giỏ hàng
    ),
    Chore(
      id: '4', 
      title: 'Nấu ăn', 
      assignee: 'Long', 
      isDone: false,
      iconAsset: 'assets/images/icons/cooking.png' // <--- Ảnh nồi niêu
    ),
    Chore(
      id: '5', 
      title: 'Đổ rác', 
      assignee: 'Long', 
      isDone: false,
      iconAsset: 'assets/images/icons/trash.png' // <--- Ảnh thùng rác
    ),
    Chore(
      id: '6', 
      title: 'Giặt quần áo', 
      assignee: 'Minh', 
      isDone: false,
      iconAsset: 'assets/images/icons/wash_clothes.png'
    ),
  ];

  // Hàm lọc danh sách dựa trên tab đang chọn
  List<Chore> get filteredChores {
    if (_selectedTabIndex == 1) {
      return allChores.where((chore) => chore.isDone == true).toList();
    } else if (_selectedTabIndex == 2) {
      return allChores.where((chore) => chore.isDone == false).toList();
    }
    return allChores; // Tab 0 trả về tất cả
  }

  // Hàm tính toán số lượng để hiển thị lên thẻ
  int get totalCount => allChores.length;
  int get doneCount => allChores.where((c) => c.isDone).length;
  int get pendingCount => allChores.where((c) => !c.isDone).length;

  // 2. HÀM HIỂN THỊ POPUP XÁC NHẬN
  // Sửa: Nhận vào đối tượng Chore thay vì index để tránh lỗi khi lọc list
  void _showConfirmDialog(Chore chore) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Popup chỉ to vừa đủ nội dung
            children: [
              // Nội dung Text
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
                      text: "${chore.assignee} ?",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Điểm thưởng
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Điểm thưởng tích lũy", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("+ 2 điểm", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 30),

              // Hai nút bấm Hủy / Xác nhận
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context), // Tắt popup
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
                      onPressed: () {
                        // LOGIC QUAN TRỌNG: Cập nhật trạng thái
                        setState(() {
                          chore.isDone = true;
                        });
                        Navigator.pop(context); // Tắt popup sau khi xong
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF66CC33), // Màu xanh lá
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

  @override
  Widget build(BuildContext context) {
    // Lấy danh sách đã lọc để hiển thị
    final currentList = filteredChores;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
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

                // 2. Hàng Thẻ Thống Kê (Dùng Row + Expanded để chia đều)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tab 1: Tất cả
                    Expanded(
                      child: ChoreStatCard(
                        title: "Tất cả công việc",
                        count: "$totalCount công việc",                      
                        iconColor: Colors.cyan,
                        titleColor: Colors.blue,
                        isSelected: _selectedTabIndex == 0,
                        onTap: () => setState(() => _selectedTabIndex = 0),
                      ),
                    ),
                    const SizedBox(width: 10), // Khoảng cách giữa các thẻ

                    // Tab 2: Đã xong
                    Expanded(
                      child: ChoreStatCard(
                        title: "Công việc đã xong",
                        count: "$doneCount công việc",
                        iconColor: Colors.green,
                        titleColor: Colors.green,
                        isSelected: _selectedTabIndex == 1,
                        onTap: () => setState(() => _selectedTabIndex = 1),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Tab 3: Chưa xong
                    Expanded(
                      child: ChoreStatCard(
                        title: "Công việc chưa làm",
                        count: "$pendingCount công việc",
                        iconColor: Colors.redAccent,
                        titleColor: Colors.red,
                        isSelected: _selectedTabIndex == 2,
                        onTap: () => setState(() => _selectedTabIndex = 2),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25), // Khoảng cách

              // --- MỚI THÊM: THẺ ĐIỂM TÍCH LŨY ---
                const ScoreCard(),

                const SizedBox(height: 25),

                // 3. Danh sách công việc
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Danh sách công việc", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text("Có ${currentList.length} công việc", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(),

                      // Nếu list rỗng thì báo
                      if (currentList.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: Text("Không có công việc nào!", style: TextStyle(color: Colors.grey)),
                        )
                      else
                        // Dùng map để render danh sách đã lọc
                        ...currentList.map((chore) {
                          return ChoreItemCard(
                            title: chore.title,
                            assignee: chore.assignee,
                            isDone: chore.isDone,
                            iconAsset: chore.iconAsset,
                            onTapButton: () {
                              _showConfirmDialog(chore); // Truyền object chore vào popup
                            },
                          );
                        }).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}