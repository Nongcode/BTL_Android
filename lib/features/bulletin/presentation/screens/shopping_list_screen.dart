// lib/features/bulletin/presentation/screens/shopping_list_screen.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'add_shopping_item_screen.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  int _selectedFilterIndex = 0;

  final List<String> _filters = ["Tất cả", "Cần mua", "Đã mua"];

  final List<Map<String, dynamic>> _items = [
    {
      "name": "Giấy vệ sinh",
      "detail": "Loại cuộn mềm",
      "addedBy": "Đức Minh",
      "isDone": false,
    },
    {
      "name": "Nước rửa chén",
      "detail": "Loại Sunlight 750ml",
      "addedBy": "Đức Minh",
      "isDone": true,
    },
    {
      "name": "Bột giặt",
      "detail": "3kg Omo",
      "addedBy": "Phạm Long",
      "isDone": true,
    },
    {
      "name": "Nước lọc 19L",
      "detail": "Đã đặt 2 bình",
      "addedBy": "Lương Tuân",
      "isDone": false,
    },
  ];

  List<Map<String, dynamic>> _getFilteredItems() {
    if (_selectedFilterIndex == 1) {
      // Cần mua
      return _items.where((e) => e["isDone"] == false).toList();
    } else if (_selectedFilterIndex == 2) {
      // Đã mua
      return _items.where((e) => e["isDone"] == true).toList();
    }
    return _items;
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _getFilteredItems();

    return Scaffold(
      backgroundColor: AppColors.background,

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddShoppingItemScreen()),
          );
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
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return _ShoppingItemCard(
                    name: item["name"],
                    detail: item["detail"],
                    addedBy: item["addedBy"],
                    isDone: item["isDone"],
                    onToggle: () {
                      setState(() {
                        item["isDone"] = !(item["isDone"] as bool);
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // HEADER
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
          Expanded(
            child: Center(
              child: Text(
                "Danh sách mua sắm",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  // 3 tab: Tất cả / Cần mua / Đã mua
  Widget _buildFilterTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(_filters.length, (index) {
        final bool isSelected = index == _selectedFilterIndex;

        return Padding(
          padding: EdgeInsets.only(right: index == _filters.length - 1 ? 0 : 8),
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedFilterIndex = index);
            },
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

// Card từng mặt hàng
class _ShoppingItemCard extends StatelessWidget {
  final String name;
  final String detail;
  final String addedBy;
  final bool isDone;
  final VoidCallback onToggle;

  const _ShoppingItemCard({
    required this.name,
    required this.detail,
    required this.addedBy,
    required this.isDone,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    decoration: isDone
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    decoration: isDone
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
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
            onPressed: () {
              // TODO: menu (sửa, xoá,...)
            },
            icon: const Icon(Icons.more_vert_rounded, size: 20),
          ),
        ],
      ),
    );
  }
}
