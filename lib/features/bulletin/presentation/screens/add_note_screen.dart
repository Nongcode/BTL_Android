// lib/features/bulletin/presentation/screens/add_note_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import 'package:btl_android_flutter/features/bulletin/presentation/widgets/index.dart';
import 'package:btl_android_flutter/features/bulletin/data/service/bulletin_service.dart';

class AddNoteScreen extends StatefulWidget {
  final int houseId;

  const AddNoteScreen({super.key, required this.houseId});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  final BulletinService _service = BulletinService();
  final ImagePicker _picker = ImagePicker();

  int _selectedTagIndex = 0;
  bool _hasReminder = false;
  bool _isSaving = false;

  File? _selectedImage;
  String? _uploadedImageUrl;
  bool _uploadingImage = false;

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

  Future<void> _pickAndUploadImage() async {
    final XFile? xfile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (xfile == null) return;

    setState(() {
      _selectedImage = File(xfile.path);
      _uploadingImage = true;
      _uploadedImageUrl = null;
    });

    final url = await _service.uploadImage(file: _selectedImage!);

    if (!mounted) return;
    setState(() {
      _uploadingImage = false;
      _uploadedImageUrl = url;
    });

    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload ảnh thất bại.")),
      );
    }
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final category = _tags[_selectedTagIndex]["label"] as String;

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập tiêu đề và nội dung.")),
      );
      return;
    }

    if (_uploadingImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đang upload ảnh, vui lòng đợi...")),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final ok = await _service.createNote(
        houseId: widget.houseId,
        title: title,
        content: content,
        category: category,
        imageUrl: _uploadedImageUrl,
        hasReminder: _hasReminder,
        isPinned: false,
      );

      if (!mounted) return;
      if (ok) {
        Navigator.of(context).pop(true); // báo màn trước reload
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tạo ghi chú thất bại.")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FormLabel("Tiêu đề ghi chú"),
                    const SizedBox(height: 6),
                    AppTextField(
                      controller: _titleController,
                      hint: "Ví dụ: Wifi, lịch thu tiền nhà...",
                      maxLines: 1,
                    ),
                    const SizedBox(height: 16),

                    const FormLabel("Nội dung"),
                    const SizedBox(height: 6),
                    AppTextField(
                      controller: _contentController,
                      hint: "Nhập nội dung chi tiết...",
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

                    _buildSaveButton(),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 80,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF3AD6C8), Color(0xFF15B2E0)]),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(false),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Expanded(
            child: Text(
              "Thêm ghi chú",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
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
        final Color color = tag["color"] as Color;

        return ChoiceChip(
          label: Text(tag["label"]),
          labelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : color,
          ),
          selected: isSelected,
          selectedColor: color,
          backgroundColor: color.withOpacity(0.12),
          showCheckmark: false,
          onSelected: (_) => setState(() => _selectedTagIndex = index),
        );
      }),
    );
  }

  Widget _buildUploadBox() {
    return Container(
      height: 110,
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
        onTap: _uploadingImage ? null : _pickAndUploadImage,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: _selectedImage == null
                    ? Icon(Icons.image_outlined, color: Colors.grey.shade500, size: 28)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _uploadingImage ? "Đang tải ảnh lên..." : "Tải lên hình ảnh",
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _uploadedImageUrl != null ? "Đã upload ✅" : "Chọn ảnh từ thư viện",
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
              if (_uploadingImage)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
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
          value: _hasReminder,
          onChanged: (value) => setState(() => _hasReminder = value),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 4,
        ),
        onPressed: _isSaving ? null : _save,
        child: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Text(
                "Lưu ghi chú",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
              ),
      ),
    );
  }
}
