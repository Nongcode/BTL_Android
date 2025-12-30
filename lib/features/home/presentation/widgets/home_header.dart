import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart'; // Đảm bảo đường dẫn đúng
import 'home_header_clipper.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: HomeHeaderClipper(), // Sử dụng cái kéo chúng ta vừa tạo
      child: Container(
        height: 350, // Chiều cao của phần header
        width: double.infinity,
        decoration: const BoxDecoration(

          color: AppColors.primary,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20), // Giữ lại khoảng cách an toàn (tránh tai thỏ)
            
            // --- BẮT ĐẦU PHẦN THAY THẾ ---
            
            // Thay vì dùng Icon + RichText, ta dùng Image.asset
            Image.asset(
              'assets/images/logo.png',
              height: 150,
              width: 250,
              fit: BoxFit.contain,   
            ),
            
            // --- KẾT THÚC PHẦN THAY THẾ ---

            const SizedBox(height: 10),
            
            // Dòng chào mừng (Giữ nguyên hoặc xóa nếu muốn)
            const Text(
              "Chào mừng bạn đến với HousePal",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}