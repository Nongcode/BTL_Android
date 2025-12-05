import 'package:flutter/material.dart';

class HomeHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    
    // 1. Bắt đầu từ góc trên trái (0,0) -> Kẻ xuống dưới, chừa lại 50px từ đáy
    path.lineTo(0, size.height - 50);

    // 2. Vẽ đường cong Bezier
    // Điểm điều khiển (control point) nằm ở giữa chiều ngang và dưới đáy cùng
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 30);
    
    path.quadraticBezierTo(
      firstControlPoint.dx, firstControlPoint.dy,
      firstEndPoint.dx, firstEndPoint.dy
    );

    var secondControlPoint = Offset(size.width * 3 / 4, size.height - 80);
    var secondEndPoint = Offset(size.width, size.height - 40);

    path.quadraticBezierTo(
      secondControlPoint.dx, secondControlPoint.dy,
      secondEndPoint.dx, secondEndPoint.dy
    );

    // 3. Kẻ lên góc trên phải
    path.lineTo(size.width, 0);
    
    // 4. Khép kín hình
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}