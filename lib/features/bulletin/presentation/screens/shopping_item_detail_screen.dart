// lib/features/bulletin/presentation/screens/shopping_item_detail_screen.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

// API + model
import 'package:btl_android_flutter/features/bulletin/data/service/bulletin_service.dart';
import 'package:btl_android_flutter/features/bulletin/data/models/bulletin_item_model.dart';
import 'package:btl_android_flutter/features/bulletin/data/models/bulletin_comment_model.dart';

class ShoppingItemDetailScreen extends StatefulWidget {
  final int houseId;
  final BulletinItem item;

  const ShoppingItemDetailScreen({
    super.key,
    required this.houseId,
    required this.item,
  });

  @override
  State<ShoppingItemDetailScreen> createState() => _ShoppingItemDetailScreenState();
}

class _ShoppingItemDetailScreenState extends State<ShoppingItemDetailScreen> {
  final BulletinService _service = BulletinService();

  bool _loadingComments = false;
  List<BulletinComment> _comments = [];

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    setState(() => _loadingComments = true);
    try {
      final data = await _service.getComments(
        houseId: widget.houseId,
        targetType: "item",
        targetId: widget.item.id,
      );
      setState(() => _comments = data);
    } finally {
      if (mounted) setState(() => _loadingComments = false);
    }
  }

  Future<void> _deleteItem() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xóa mặt hàng?"),
        content: const Text("Bạn có chắc muốn xóa mặt hàng này không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Xóa")),
        ],
      ),
    );

    if (ok != true) return;

    final success = await _service.deleteItem(id: widget.item.id);
    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Xóa thất bại.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildHeader(context),
                  const SizedBox(height: 16),

                  _buildLabel("Tên mặt hàng"),
                  const SizedBox(height: 6),
                  _buildValueBox(item.itemName),
                  const SizedBox(height: 14),

                  _buildLabel("Ghi chú"),
                  const SizedBox(height: 6),
                  _buildValueBox(item.itemNote ?? "Không có"),
                  const SizedBox(height: 14),

                  _buildLabel("Số lượng"),
                  const SizedBox(height: 6),
                  _buildValueBox(item.quantity?.toString() ?? "Không có"),
                  const SizedBox(height: 14),

                  _buildLabel("Hình ảnh đính kèm"),
                  const SizedBox(height: 6),
                  _buildImageBox(),
                  const SizedBox(height: 16),

                  _buildLabel("Người tạo"),
                  const SizedBox(height: 8),
                  _buildCreatorRow(item.createdBy),
                  const SizedBox(height: 16),

                  _buildLabel("Bình luận"),
                  const SizedBox(height: 10),
                  _buildCommentBox(),
                ],
              ),
            ),

            // Input comment + send (chưa có JWT token thì chỉ xem)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.transparent,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          "Viết bình luận.. (cần đăng nhập)",
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.35),
                      ),
                      child: IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Chức năng comment cần JWT token.")),
                          );
                        },
                        icon: const Icon(Icons.send_rounded, size: 20, color: Colors.white),
                      ),
                    ),
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
            onPressed: () => Navigator.of(context).pop(false),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Text(
              "Chi tiết mặt hàng",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            onPressed: _deleteItem,
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700));
  }

  Widget _buildValueBox(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Text(
        value,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildImageBox() {
    return Container(
      width: double.infinity,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported_outlined, size: 24, color: Colors.grey.shade500),
            const SizedBox(height: 6),
            Text("Không có hình ảnh", style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatorRow(int? createdBy) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.orange.shade200,
          child: Text(
            (createdBy?.toString() ?? "?").substring(0, 1),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "User #${createdBy ?? "?"}",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommentBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: _loadingComments
          ? const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 14), child: CircularProgressIndicator()))
          : (_comments.isEmpty
              ? Center(
                  child: Text("Chưa có bình luận", style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _comments.map((c) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text("- ${c.content} (User #${c.userId ?? "?"})"),
                    );
                  }).toList(),
                )),
    );
  }
}
