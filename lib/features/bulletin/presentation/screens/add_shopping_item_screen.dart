// lib/features/bulletin/presentation/screens/add_shopping_item_screen.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:btl_android_flutter/features/bulletin/presentation/widgets/index.dart';

class AddShoppingItemScreen extends StatefulWidget {
  const AddShoppingItemScreen({super.key});

  @override
  State<AddShoppingItemScreen> createState() => _AddShoppingItemScreenState();
}

class _AddShoppingItemScreenState extends State<AddShoppingItemScreen> {
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();
  final _quantityController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    _quantityController.dispose();
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
                    const FormLabel("Tên mặt hàng"),
                    const SizedBox(height: 6),
                    AppTextField(
                      controller: _nameController,
                      hint: "Ví dụ: Giấy vệ sinh...",
                    ),
                    const SizedBox(height: 16),

                    const FormLabel("Ghi chú (tuỳ chọn)"),
                    const SizedBox(height: 6),
                    AppTextField(
                      controller: _noteController,
                      hint: "Ví dụ: loại, kích thước, thương hiệu...",
                    ),
                    const SizedBox(height: 16),

                    const FormLabel("Số lượng (tuỳ chọn)"),
                    const SizedBox(height: 6),
                    AppTextField(
                      controller: _quantityController,
                      hint: "Ví dụ: 2 cuộn, 3 chai...",
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 16),

                    const FormLabel("Đính kèm hình ảnh"),
                    const SizedBox(height: 6),
                    _buildUploadBox(),
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
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 4),
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
                "Tải lên hình ảnh ",
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
          // TODO: validate + gửi dữ liệu ngược lại ShoppingList
          Navigator.of(context).pop(); // tạm thời quay lại
        },
        child: const Text(
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
