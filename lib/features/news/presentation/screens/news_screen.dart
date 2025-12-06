import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'shopping_list_screen.dart';

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
      "tagColor": Colors.deepPurpleAccent,
      "time": "2 tiếng trước",
    },
    {
      "title": "Quy định đổ rác",
      "description": "Đổ rác trước 8h sáng các ngày chẵn.",
      "tag": "Nội quy",
      "tagColor": Colors.blueAccent,
      "time": "1 tháng trước",
    },
  ];

  final List<Map<String, dynamic>> _shoppingNotes = [
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
                    ..._pinnedNotes
                        .map(
                          (e) => _BulletinCard(
                            title: e["title"],
                            description: e["description"],
                            tag: e["tag"],
                            tagColor: e["tagColor"],
                            time: e["time"],
                          ),
                        )
                        .toList(),
                    const SizedBox(height: 20),
                  ],
                  // All notes
                  _buildSectionTitle("Tất cả ghi chú (${_allNotes.length})"),
                  const SizedBox(height: 8),
                  ..._allNotes
                      .map(
                        (e) => _BulletinCard(
                          title: e["title"],
                          description: e["description"],
                          tag: e["tag"],
                          tagColor: e["tagColor"],
                          time: e["time"],
                        ),
                      )
                      .toList(),
                  const SizedBox(height: 20),
                  // Shopping
                  _buildSectionTitle("Mua sắm chung"),
                  const SizedBox(height: 8),
                  ..._shoppingNotes
                      .map(
                        (e) => _ShoppingCard(
                          title: e["title"],
                          subtitle: e["subtitle"],
                          icon: e["icon"],
                        ),
                      )
                      .toList(),
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
                    // TODO: mở màn hình tạo ghi chú
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // thanh trên cùng
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Bảng Tin Chung",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                onPressed: () {
                  // TODO: mở màn hình cài đặt / thông báo
                },
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Text(
            "Tất cả thông báo và ghi chú chung\ntrong nhà sẽ ở đây.",
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // SEARCH + FILTER CHIPS
  Widget _buildSearchAndFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // search
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
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
                    isDense: true,
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
        // Trong _buildSearchAndFilters()
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
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                  selected: isSelected,
                  showCheckmark: false,
                  onSelected: (_) {
                    setState(() {
                      _selectedFilterIndex = index;
                    });
                    // TODO: lọc danh sách theo label / filterColor
                  },
                  backgroundColor: Colors.grey.shade200,
                  selectedColor: filterColor.withOpacity(0.16),
                  labelPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 0,
                  ),
                  visualDensity: VisualDensity.compact,
                  side: isSelected
                      ? BorderSide.none
                      : BorderSide(color: Colors.grey.shade300),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    );
  }
}

// Card ghi chú
class _BulletinCard extends StatelessWidget {
  final String title;
  final String description;
  final String tag;
  final Color tagColor;
  final String time;

  const _BulletinCard({
    required this.title,
    required this.description,
    required this.tag,
    required this.tagColor,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // title + menu
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  // TODO: show menu sửa / xoá
                },
                icon: const Icon(Icons.more_vert_rounded, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(fontSize: 13, height: 1.3)),
          const SizedBox(height: 8),
          Row(
            children: [
              // tag chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: tagColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: tagColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.circle, size: 4, color: Colors.grey.shade500),
              const SizedBox(width: 6),
              Text(
                time,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Card mua sắm
class _ShoppingCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _ShoppingCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ShoppingListScreen()));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Icon(icon, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}
