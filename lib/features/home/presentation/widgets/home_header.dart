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
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF80E0FF), // Màu nhạt hơn chút ở góc (giống hiệu ứng ánh sáng)
              AppColors.primary, // Màu chính
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20), // Khoảng cách từ trên cùng (tránh tai thỏ)
            
            // Giả lập Logo House (Sau này bạn thay bằng Image.asset)
            Icon(Icons.home_work_rounded, size: 80, color: Colors.orange.shade800),
            
            const SizedBox(height: 10),
            
            // Chữ HOUSEPAL
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'Roboto'), // Chỉnh font nếu cần
                children: [
                  const TextSpan(text: 'HOUSE', style: TextStyle(color: Color(0xFF333333))),
                  TextSpan(text: 'PAL', style: TextStyle(color: Colors.orange.shade800)),
                ],
              ),
            ),
            
            const SizedBox(height: 10),
            
            // Dòng chào mừng
            const Text(
              "Chào mừng bạn đến với HousePal",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}