// lib/features/bulletin/presentation/screens/news_screen.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

// Widgets dùng chung
import 'package:btl_android_flutter/features/bulletin/presentation/widgets/index.dart';

// Screens khác
import 'add_note_screen.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  int _selectedFilterIndex = 0;

  final List<Map<String, dynamic>> _filters = [
    {"label": "Khẩn cấp", "color": const Color(0xFFFF6B6B)}, // đỏ
    {"label": "Nội quy", "color": const Color(0xFF3A7BFF)}, // xanh dương
    {"label": "Sửa chữa", "color": const Color(0xFFFFA726)}, // cam
    {"label": "Mua sắm", "color": const Color(0xFF2ECC71)}, // xanh lá
    {"label": "Thông báo", "color": const Color(0xFF9E9E9E)}, // xám
  ];

  final List<Map<String, dynamic>> _pinnedNotes = [
    {
      "title": "WC rò rỉ nước",
      "description":
          "Đường ống nước bị vỡ cần sửa chữa gấp. Mọi người tạm dừng sử dụng nước từ hôm nay.",
      "tag": "Khẩn cấp",
      "tagColor": Colors.redAccent,
      "time": "1 tiếng trước",
    },
    {
      "title": "Wifi & Liên hệ chủ nhà",
      "description": "Wifi: DVN T6",
      "tag": "Nội quy",
      "tagColor": Colors.blueAccent,
      "time": "1 tháng trước",
    },
  ];

  final List<Map<String, dynamic>> _allNotes = [
    {
      "title": "Chủ nhà đến kiểm tra điện",
      "description": "Thứ 7 tuần này sáng 9 giờ sáng.",
      "tag": "Thông báo",
      "tagColor": Colors.grey,
      "time": "Hôm qua",
    },
    {
      "title": "Lịch thu tiền nhà",
      "description": "Ngày 5 hàng tháng. Chuyển khoản hoặc đưa tiền mặt.",
      "tag": "Nội quy",
      "tagColor": Colors.blueAccent,
      "time": "2 tuần trước",
    },
    {
      "title": "Đổ rác đúng giờ",
      "description": "Mỗi tối từ 19h – 20h mang rác xuống tầng 1.",
      "tag": "Nội quy",
      "tagColor": Colors.blueAccent,
      "time": "3 tuần trước",
    },
  ];

  final List<Map<String, dynamic>> _shoppingNotes = const [
    {
      "title": "Danh sách mua sắm",
      "subtitle": "2 mục cần mua hôm nay",
      "icon": Icons.shopping_cart_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Nền cuộn
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildSearchAndFilters(),
                  const SizedBox(height: 20),

                  // Pinned
                  if (_pinnedNotes.isNotEmpty) ...[
                    _buildSectionTitle(
                      "Ghi chú được ghim (${_pinnedNotes.length})",
                    ),
                    const SizedBox(height: 8),
                    ..._pinnedNotes.map(
                      (e) => BulletinCard(
                        title: e["title"],
                        description: e["description"],
                        tag: e["tag"],
                        tagColor: e["tagColor"],
                        time: e["time"],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // All notes
                  _buildSectionTitle("Tất cả ghi chú (${_allNotes.length})"),
                  const SizedBox(height: 8),
                  ..._allNotes.map(
                    (e) => BulletinCard(
                      title: e["title"],
                      description: e["description"],
                      tag: e["tag"],
                      tagColor: e["tagColor"],
                      time: e["time"],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Quick actions (mua sắm,…)
                  _buildSectionTitle("Tiện ích"),
                  const SizedBox(height: 8),
                  ..._shoppingNotes.map(
                    (e) => ShoppingCard(
                      title: e["title"] as String,
                      subtitle: e["subtitle"] as String,
                      icon: e["icon"] as IconData,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),

            // Nút Thêm mới bám đáy
            Positioned(
              right: 16,
              bottom: 16,
              child: SizedBox(
                width: 64,
                height: 64,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AddNoteScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: const CircleBorder(),
                    padding: EdgeInsets.zero,
                    elevation: 6,
                  ),
                  child: const Icon(Icons.add, size: 36, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // HEADER gradient
  Widget _buildHeader() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3AD6C8), Color(0xFF15B2E0)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hàng trên: avatar + actions
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.grey),
              ),
              const SizedBox(width: 8),
              const Text(
                "Xin chào, bạn trọ!",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Bảng tin phòng trọ",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Cập nhật thông báo, nội quy và ghi chú chung.",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // SEARCH + FILTERS
  Widget _buildSearchAndFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ô tìm kiếm
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.grey.shade500, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Tìm ghi chú...",
                  ),
                ),
              ),
              Icon(Icons.tune_rounded, color: Colors.grey.shade500, size: 20),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_filters.length, (index) {
              final bool isSelected = _selectedFilterIndex == index;
              final filter = _filters[index];
              final String label = filter["label"] as String;
              final Color filterColor = filter["color"] as Color;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  selected: isSelected,
                  showCheckmark: false,
                  selectedColor: filterColor.withOpacity(0.16),
                  backgroundColor: Colors.grey.shade200,
                  side: isSelected
                      ? BorderSide.none
                      : BorderSide(color: Colors.grey.shade300),
                  onSelected: (_) {
                    setState(() => _selectedFilterIndex = index);
                    // TODO: lọc danh sách theo label / filterColor
                  },
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return SectionTitle(title);
  }
}
