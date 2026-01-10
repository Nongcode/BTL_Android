// lib/features/bulletin/presentation/screens/shopping_list_screen.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'add_shopping_item_screen.dart';
import 'shopping_item_detail_screen.dart';

// ✅ Service mới nằm ở features/bulletin/service
import 'package:btl_android_flutter/features/bulletin/data/service/bulletin_service.dart';
import 'package:btl_android_flutter/features/bulletin/data/models/bulletin_item_model.dart';

class ShoppingListScreen extends StatefulWidget {
  final int houseId;

  const ShoppingListScreen({super.key, required this.houseId});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final BulletinService _service = BulletinService();

  bool _isLoading = false;
  String? _error;

  int _selectedFilterIndex = 0;
  final List<String> _filters = ["Tất cả", "Cần mua", "Đã mua"];

  List<BulletinItem> _items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _service.getItems(houseId: widget.houseId);
      data.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
      setState(() => _items = data);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<BulletinItem> _getFilteredItems() {
    if (_selectedFilterIndex == 1) {
      return _items.where((e) => e.isChecked == false).toList();
    } else if (_selectedFilterIndex == 2) {
      return _items.where((e) => e.isChecked == true).toList();
    }
    return _items;
  }

  BulletinItem _copyItem(BulletinItem i, {bool? isChecked}) {
    return BulletinItem(
      id: i.id,
      houseId: i.houseId,
      createdBy: i.createdBy,
      itemName: i.itemName,
      itemNote: i.itemNote,
      quantity: i.quantity,
      imageUrl: i.imageUrl,
      isChecked: isChecked ?? i.isChecked,
      createdAt: i.createdAt,
      updatedAt: i.updatedAt,
    );
  }

  Future<void> _toggleItem(BulletinItem item) async {
    final newValue = !item.isChecked;

    // optimistic UI
    setState(() {
      _items = _items.map((e) => e.id == item.id ? _copyItem(e, isChecked: newValue) : e).toList();
    });

    // ✅ gọi updateItem theo service mới (truyền field)
    final ok = await _service.updateItem(
      id: item.id,
      itemName: item.itemName,
      itemNote: item.itemNote,
      quantity: item.quantity,
      imageUrl: item.imageUrl,
      isChecked: newValue,
    );

    if (!ok && mounted) {
      // revert
      setState(() {
        _items = _items.map((e) => e.id == item.id ? item : e).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cập nhật trạng thái thất bại.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _getFilteredItems();

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final ok = await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => AddShoppingItemScreen(houseId: widget.houseId)),
          );
          if (ok == true) _loadItems();
        },
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        elevation: 6,
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildFilterTabs(),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadItems,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                  children: [
                    if (_isLoading) ...[
                      const SizedBox(height: 24),
                      const Center(child: CircularProgressIndicator()),
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
                      OutlinedButton(onPressed: _loadItems, child: const Text("Thử lại")),
                    ] else ...[
                      ...filteredItems.map((item) {
                        final addedBy = item.createdBy == null ? "Ai đó" : "User #${item.createdBy}";
                        return _ShoppingItemCard(
                          name: item.itemName,
                          detail: item.itemNote ?? "",
                          addedBy: addedBy,
                          isDone: item.isChecked,
                          onToggle: () => _toggleItem(item),
                          onTap: () async {
                            final changed = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ShoppingItemDetailScreen(
                                  houseId: widget.houseId,
                                  item: item,
                                ),
                              ),
                            );
                            if (changed == true) _loadItems();
                          },
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 90,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF27C5C5),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Expanded(
            child: Center(
              child: Text(
                "Danh sách mua sắm",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(_filters.length, (index) {
        final bool isSelected = index == _selectedFilterIndex;

        return Padding(
          padding: EdgeInsets.only(right: index == _filters.length - 1 ? 0 : 8),
          child: GestureDetector(
            onTap: () => setState(() => _selectedFilterIndex = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                _filters[index],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _ShoppingItemCard extends StatelessWidget {
  final String name;
  final String detail;
  final String addedBy;
  final bool isDone;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const _ShoppingItemCard({
    required this.name,
    required this.detail,
    required this.addedBy,
    required this.isDone,
    required this.onToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
            Checkbox(
              value: isDone,
              onChanged: (_) => onToggle(),
              shape: const CircleBorder(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Thêm bởi $addedBy",
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert_rounded, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
