// lib/features/bulletin/presentation/screens/add_note_screen.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:btl_android_flutter/features/bulletin/presentation/widgets/index.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  int _selectedTagIndex = 0;

  final List<Map<String, dynamic>> _tags = [
    {"label": "Khẩn cấp", "color": const Color(0xFFFF6B6B)},
    {"label": "Nội quy", "color": const Color(0xFF3A7BFF)},
    {"label": "Sửa chữa", "color": const Color(0xFFFFA726)},
    {"label": "Mua sắm", "color": const Color(0xFF2ECC71)},
    {"label": "Thông báo", "color": const Color(0xFF9E9E9E)},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FormLabel("Tiêu đề ghi chú"),
                    const SizedBox(height: 6),
                    AppTextField(
                      controller: _titleController,
                      hint: "Ví dụ : wifi, lịch thu tiền nhà,...",
                      maxLines: 1,
                    ),
                    const SizedBox(height: 16),

                    const FormLabel("Nội dung"),
                    const SizedBox(height: 6),
                    AppTextField(
                      controller: _contentController,
                      hint: "Nhập nội dung chi tiết của ghi chú...",
                      maxLines: 5,
                    ),
                    const SizedBox(height: 16),

                    const FormLabel("Chọn nhãn"),
                    const SizedBox(height: 6),
                    _buildTagSelector(),
                    const SizedBox(height: 16),

                    const FormLabel("Đính kèm hình ảnh"),
                    const SizedBox(height: 6),
                    _buildUploadBox(),
                    const SizedBox(height: 16),

                    _buildReminderRow(),
                    const SizedBox(height: 24),

                    _buildSaveButton(context),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----- HEADER -----
  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 90,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3AD6C8), Color(0xFF15B2E0)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Text(
              "Thêm ghi chú",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildTagSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(_tags.length, (index) {
        final tag = _tags[index];
        final bool isSelected = index == _selectedTagIndex;

        return ChoiceChip(
          label: Text(tag["label"]),
          labelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : tag["color"],
          ),
          selected: isSelected,
          selectedColor: tag["color"],
          backgroundColor: (tag["color"] as Color).withOpacity(0.12),
          showCheckmark: false,
          onSelected: (_) {
            setState(() => _selectedTagIndex = index);
          },
        );
      }),
    );
  }

  Widget _buildUploadBox() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // TODO: mở picker chọn ảnh
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.file_upload_outlined, size: 20),
              const SizedBox(height: 4),
              Text(
                "Chọn ảnh từ thư viện",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReminderRow() {
    return Row(
      children: [
        const Icon(Icons.alarm_rounded, size: 20),
        const SizedBox(width: 8),
        const Text(
          "Nhắc tôi về ghi chú này",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Switch(
          value: false,
          onChanged: (value) {
            // TODO: logic bật nhắc nhở
          },
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 4,
        ),
        onPressed: () {
          // TODO: validate + gửi dữ liệu ngược lại NewsScreen
          Navigator.of(context).pop(); // tạm thời quay lại
        },
        child: const Text(
          "Lưu ghi chú",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
