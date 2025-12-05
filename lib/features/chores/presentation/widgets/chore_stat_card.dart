import 'package:flutter/material.dart';

class ChoreStatCard extends StatelessWidget {
  final String title;
  final String count;
  final Color iconColor;
  final Color titleColor;
  final bool isSelected;
  final Color? backgroundColor;
  
  // 1. Thêm biến này để nhận hàm xử lý click
  final VoidCallback onTap; 

  const ChoreStatCard({
    super.key,
    required this.title,
    required this.count,
    required this.iconColor,
    this.backgroundColor,
    
    // 2. Bắt buộc phải truyền hàm này vào khi gọi Widget
    required this.onTap, 
    
    this.titleColor = Colors.black87,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    // 3. Bọc Container bằng GestureDetector để bắt sự kiện click
    return GestureDetector(
      onTap: onTap, 
      child: Container(
        // Lưu ý: Đã bỏ width: 110 để nó tự co giãn theo Expanded bên ngoài
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white, // Chọn thì trắng, không thì xám
          borderRadius: BorderRadius.circular(16),
          // Viền xanh nếu được chọn
          border: isSelected 
              ? Border.all(color: Colors.cyan, width: 2) 
              : Border.all(color: Colors.transparent, width: 2),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.cyan.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.checklist_rounded, color: iconColor, size: 35),
            const SizedBox(height: 12),
            Text(
              title, 
              style: TextStyle(
                fontSize: 15, 
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                height: 1.3,
                color: Colors.black87
              )
            ),
            const SizedBox(height: 8),
            Text(
              count, 
              style: TextStyle(
                color: titleColor, 
                fontWeight: FontWeight.bold, 
                fontSize: 15
              )
            ),
          ],
        ),
      ),
    );
  }
}