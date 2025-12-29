// lib/features/bulletin/presentation/screens/add_shopping_item_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import 'package:btl_android_flutter/features/bulletin/data/service/bulletin_service.dart';

import 'package:btl_android_flutter/features/bulletin/presentation/widgets/index.dart';

class AddShoppingItemScreen extends StatefulWidget {
  final int houseId;

  const AddShoppingItemScreen({super.key, required this.houseId});

  @override
  State<AddShoppingItemScreen> createState() => _AddShoppingItemScreenState();
}

class _AddShoppingItemScreenState extends State<AddShoppingItemScreen> {
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();
  final _quantityController = TextEditingController();

  final BulletinService _service = BulletinService();
  final ImagePicker _picker = ImagePicker();

  bool _isSaving = false;

  File? _selectedImage;
  String? _uploadedImageUrl;
  bool _uploadingImage = false;

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    _quantityController.dispose();
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Upload ảnh thất bại.")));
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final note = _noteController.text.trim();
    final qty = int.tryParse(_quantityController.text.trim());

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập tên mặt hàng.")),
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
      final ok = await _service.createItem(
        houseId: widget.houseId,
        itemName: name,
        itemNote: note.isEmpty ? null : note,
        quantity: qty,
        imageUrl: _uploadedImageUrl,
        isChecked: false,
      );

      if (!mounted) return;
      if (ok) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Tạo mặt hàng thất bại.")));
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FormLabel("Tên mặt hàng"),
                    const SizedBox(height: 6),
                    AppTextField(
                      controller: _nameController,
                      hint: "Ví dụ: Giấy vệ sinh...",
                      maxLines: 1,
                    ),
                    const SizedBox(height: 16),

                    const FormLabel("Ghi chú (tuỳ chọn)"),
                    const SizedBox(height: 6),
                    AppTextField(
                      controller: _noteController,
                      hint: "Ví dụ: loại, kích thước, thương hiệu...",
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    const FormLabel("Số lượng (tuỳ chọn)"),
                    const SizedBox(height: 6),
                    AppTextField(
                      controller: _quantityController,
                      hint: "Ví dụ: 2",
                      keyboardType: TextInputType.number,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 16),

                    const FormLabel("Đính kèm hình ảnh"),
                    const SizedBox(height: 6),
                    _buildUploadBox(),
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
        gradient: LinearGradient(
          colors: [Color(0xFF27C5C5), Color(0xFF15B2E0)],
        ),
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
              "Thêm mặt hàng",
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
                    ? Icon(
                        Icons.image_outlined,
                        color: Colors.grey.shade500,
                        size: 28,
                      )
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
                      _uploadingImage
                          ? "Đang tải ảnh lên..."
                          : "Tải lên hình ảnh",
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _uploadedImageUrl != null
                          ? "Đã upload ✅"
                          : "Chọn ảnh từ thư viện",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
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

  Widget _buildSaveButton() {
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
        onPressed: _isSaving ? null : _save,
        child: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                "Lưu mặt hàng",
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
