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

  // Dummy data
  final List<Map<String, dynamic>> _items = [
    {
      "name": "Giấy vệ sinh",
      "detail": "Loại cuộn mềm",
      "addedBy": "Đức Minh",
      "isDone": false,
    },
    {
      "name": "Nước rửa bát",
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
      "addedBy": "Lương Tuấn",
      "isDone": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredItems = _getFilteredItems();

    return Scaffold(
      backgroundColor: AppColors.background,
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
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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

  // Lọc theo tab
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

  // HEADER giống hình (back + title + nút thêm)
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
          // NÚT BACK
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),

          // TITLE Ở GIỮA (căn giữa chuẩn)
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

          // NÚT +
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AddShoppingItemScreen(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(Icons.add, color: AppColors.primary, size: 22),
            ),
          ),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.grey.shade300,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                _filters[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// CARD 1 item mua sắm
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
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // checkbox custom
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: isDone ? const Color(0xFF2ECC71) : Colors.grey.shade500,
              ),
              child: isDone
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 14),
          // text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  "Thêm bởi : $addedBy",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          // menu
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
