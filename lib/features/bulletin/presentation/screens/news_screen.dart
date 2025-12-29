// lib/features/bulletin/presentation/screens/news_screen.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

// Widgets dùng chung
import 'package:btl_android_flutter/features/bulletin/presentation/widgets/index.dart';

// ✅ Service + Model
import 'package:btl_android_flutter/features/bulletin/data/service/bulletin_service.dart';
import 'package:btl_android_flutter/features/bulletin/data/models/bulletin_model.dart';

// Screens khác
import 'add_note_screen.dart';
import 'bulletin_detail_screen.dart';
import 'shopping_list_screen.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final int _houseId = 1; // TODO: đổi theo house bạn đang dùng
  final BulletinService _service = BulletinService();

  bool _isLoading = false;
  String? _error;

  List<Bulletin> _notes = [];

  int _selectedFilterIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _filters = [
    {"label": "Tất cả", "color": const Color(0xFF9E9E9E)},
    {"label": "Khẩn cấp", "color": const Color(0xFFFF6B6B)},
    {"label": "Nội quy", "color": const Color(0xFF3A7BFF)},
    {"label": "Sửa chữa", "color": const Color(0xFFFFA726)},
    {"label": "Mua sắm", "color": const Color(0xFF2ECC71)},
    {"label": "Thông báo", "color": const Color(0xFF9E9E9E)},
  ];

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _service.getNotes(houseId: _houseId);
      data.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
      setState(() => _notes = data);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Color _tagColor(String tag) {
    final found = _filters.firstWhere(
      (f) => f["label"] == tag,
      orElse: () => {"color": Colors.grey},
    );
    return found["color"] as Color;
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return "Vừa xong";
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return "Vừa xong";
    if (diff.inMinutes < 60) return "${diff.inMinutes} phút trước";
    if (diff.inHours < 24) return "${diff.inHours} giờ trước";
    if (diff.inDays < 30) return "${diff.inDays} ngày trước";
    return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
  }

  List<Bulletin> _applyFilter(List<Bulletin> input) {
    final q = _searchController.text.trim().toLowerCase();
    final selectedLabel = _filters[_selectedFilterIndex]["label"] as String;

    return input.where((n) {
      final matchSearch =
          q.isEmpty || n.title.toLowerCase().contains(q) || n.content.toLowerCase().contains(q);
      final matchTag = selectedLabel == "Tất cả" || n.category == selectedLabel;
      return matchSearch && matchTag;
    }).toList();
  }

  Future<void> _openDetail(Bulletin n) async {
    final changed = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BulletinDetailScreen(
          houseId: _houseId,
          note: n,
        ),
      ),
    );
    if (changed == true) _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    final pinned = _applyFilter(_notes.where((e) => e.isPinned).toList());
    final all = _applyFilter(_notes.where((e) => !e.isPinned).toList());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _loadNotes,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildSearchAndFilters(),
                    const SizedBox(height: 16),

                    if (_isLoading) ...[
                      const SizedBox(height: 30),
                      const Center(child: CircularProgressIndicator()),
                      const SizedBox(height: 30),
                    ] else if (_error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text("Lỗi: $_error"),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _loadNotes,
                          child: const Text("Thử lại"),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ] else ...[
                      if (pinned.isNotEmpty) ...[
                        _buildSectionTitle("Ghi chú được ghim (${pinned.length})"),
                        const SizedBox(height: 8),
                        ...pinned.map((n) {
                          return BulletinCard(
                            title: n.title,
                            description: n.content,
                            tag: n.category,
                            tagColor: _tagColor(n.category),
                            time: _formatTime(n.createdAt),
                            onTap: () => _openDetail(n), // ✅ dùng onTap của widget
                          );
                        }),
                        const SizedBox(height: 20),
                      ],

                      _buildSectionTitle("Tất cả ghi chú (${all.length})"),
                      const SizedBox(height: 8),
                      ...all.map((n) {
                        return BulletinCard(
                          title: n.title,
                          description: n.content,
                          tag: n.category,
                          tagColor: _tagColor(n.category),
                          time: _formatTime(n.createdAt),
                          onTap: () => _openDetail(n), // ✅
                        );
                      }),

                      const SizedBox(height: 24),

                      _buildSectionTitle("Mua sắm chung"),
                      const SizedBox(height: 8),
                      ShoppingCard(
                        title: "Danh sách mua sắm",
                        subtitle: "Xem & cập nhật các mục cần mua",
                        icon: Icons.shopping_cart_outlined,
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ShoppingListScreen(houseId: _houseId),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ],
                ),
              ),
            ),

            Positioned(
              right: 16,
              bottom: 16,
              child: SizedBox(
                width: 64,
                height: 64,
                child: ElevatedButton(
                  onPressed: () async {
                    final ok = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddNoteScreen(houseId: _houseId),
                      ),
                    );
                    if (ok == true) _loadNotes();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: const CircleBorder(),
                    padding: EdgeInsets.zero,
                    elevation: 6,
                  ),
                  child: const Icon(Icons.add, size: 30, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Bảng tin chung",
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          const Text(
            "Cập nhật thông báo, nội quy và ghi chú chung.",
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
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
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  selected: isSelected,
                  showCheckmark: false,
                  selectedColor: filterColor.withOpacity(0.16),
                  backgroundColor: Colors.grey.shade200,
                  side: isSelected ? BorderSide.none : BorderSide(color: Colors.grey.shade300),
                  onSelected: (_) => setState(() => _selectedFilterIndex = index),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) => SectionTitle(title);
}
