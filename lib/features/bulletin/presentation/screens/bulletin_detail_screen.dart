// lib/features/bulletin/presentation/screens/bulletin_detail_screen.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:btl_android_flutter/features/bulletin/presentation/widgets/index.dart';

// API + Models
import 'package:btl_android_flutter/features/bulletin/data/service/bulletin_service.dart';
import 'package:btl_android_flutter/features/bulletin/data/models/bulletin_model.dart';
import 'package:btl_android_flutter/features/bulletin/data/models/bulletin_comment_model.dart';

class BulletinDetailScreen extends StatefulWidget {
  final int houseId;
  final Bulletin note;

  const BulletinDetailScreen({
    super.key,
    required this.houseId,
    required this.note,
  });

  @override
  State<BulletinDetailScreen> createState() => _BulletinDetailScreenState();
}

class _BulletinDetailScreenState extends State<BulletinDetailScreen> {
  final BulletinService _service = BulletinService();

  bool _loadingComments = false;
  List<BulletinComment> _comments = [];

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return "";
    return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
  }

  Future<void> _loadComments() async {
    setState(() => _loadingComments = true);
    try {
      final data = await _service.getComments(
        houseId: widget.houseId,
        targetType: "note",
        targetId: widget.note.id,
      );
      setState(() => _comments = data);
    } finally {
      if (mounted) setState(() => _loadingComments = false);
    }
  }

  Future<void> _deleteNote() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xóa ghi chú?"),
        content: const Text("Bạn có chắc muốn xóa ghi chú này không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Xóa")),
        ],
      ),
    );

    if (ok != true) return;

    final success = await _service.deleteNote(id: widget.note.id);
    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true); // báo về list để reload
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Xóa thất bại.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.note;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildHeader(context),
                  const SizedBox(height: 16),
                  _buildInfoSection(n),
                  const SizedBox(height: 16),
                  _buildMainContentCard(n),
                  const SizedBox(height: 20),
                  _buildCommentSection(),
                ],
              ),
            ),

            // (comment UI giữ lại, nhưng bạn chưa có JWT token thì chỉ xem comments)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                          "Viết bình luận... (cần đăng nhập)",
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
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3AD6C8), Color(0xFF15B2E0)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Chức năng comment cần JWT token.")),
                          );
                        },
                        icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
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
      height: 80,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF27C5C5), Color(0xFF15B2E0)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(false),
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
          ),
          const Text(
            "Chi tiết",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: _deleteNote,
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(Bulletin n) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7F8),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            n.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.06),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              n.category,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.orange.shade200,
                child: Text(
                  (n.createdBy?.toString() ?? "?").substring(0, 1),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "User #${n.createdBy ?? "?"}",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTime(n.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainContentCard(Bulletin n) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Nội dung chi tiết",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            n.content,
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle("Bình luận"),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _loadingComments
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                )
              : (_comments.isEmpty
                  ? Center(
                      child: Text(
                        "Chưa có bình luận",
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    )
                  : Column(
                      children: _comments.map((c) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildCommentRow(
                            name: "User #${c.userId ?? "?"}",
                            initial: (c.userId?.toString() ?? "?").substring(0, 1),
                            time: c.createdAt?.toString() ?? "",
                            content: c.content,
                          ),
                        );
                      }).toList(),
                    )),
        ),
      ],
    );
  }

  Widget _buildCommentRow({
    required String name,
    required String initial,
    required String time,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.green.shade200,
          child: Text(
            initial,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(
                time,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 6),
              Text(content, style: const TextStyle(fontSize: 13, height: 1.3)),
            ],
          ),
        ),
      ],
    );
  }
}
