import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  int _selectedTagIndex = 0;
  bool _reminder = false;

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
                    _buildLabel("Tiêu đề ghi chú"),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _titleController,
                      hint: "Ví dụ : wifi, lịch thu tiền nhà,...",
                      maxLines: 1,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel("Nội dung"),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _contentController,
                      hint: "Nhập nội dung chi tiết của ghi chú...",
                      maxLines: 5,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel("Chọn nhãn"),
                    const SizedBox(height: 6),
                    _buildTagSelector(),
                    const SizedBox(height: 16),

                    _buildLabel("Đính kèm hình ảnh"),
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
        color: Color(0xFF27C5C5),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
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
          const SizedBox(width: 48), // chừa chỗ đối xứng với nút back
        ],
      ),
    );
  }

  // ----- WIDGET CON -----
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required int maxLines,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildTagSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(_tags.length, (index) {
          final tag = _tags[index];
          final bool isSelected = index == _selectedTagIndex;

          return GestureDetector(
            onTap: () => setState(() => _selectedTagIndex = index),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? tag["color"] : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tag["label"],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        }),
      ),
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
          // TODO: chọn / chụp hình
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.file_upload_outlined, size: 24),
              const SizedBox(height: 4),
              Text(
                "Tải lên hình ảnh",
                style: TextStyle(
                  fontSize: 13,
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Đặt nhắc nhở",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Switch(
          value: _reminder,
          activeColor: Colors.white,
          activeTrackColor: AppColors.primary,
          onChanged: (value) {
            setState(() => _reminder = value);
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
          // TODO: validate + lưu ghi chú
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
