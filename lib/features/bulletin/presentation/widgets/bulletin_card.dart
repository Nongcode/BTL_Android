// lib/features/bulletin/presentation/widgets/bulletin_card.dart
import 'package:flutter/material.dart';

class BulletinCard extends StatelessWidget {
  final String title;
  final String description;
  final String tag;
  final Color tagColor;
  final String time;

  /// Chỉ để hiển thị icon điều hướng, không tự navigate nữa
  final bool showNavigate;

  /// Bắt buộc màn cha truyền vào để điều hướng đúng (có houseId/note…)
  final VoidCallback? onTap;

  const BulletinCard({
    super.key,
    required this.title,
    required this.description,
    required this.tag,
    required this.tagColor,
    required this.time,
    this.showNavigate = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap, // ✅ không tự push screen trong widget
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // tiêu đề + icon
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (showNavigate)
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: Colors.grey,
                  ),
              ],
            ),
            const SizedBox(height: 4),

            // mô tả
            Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                height: 1.3,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // tag + thời gian
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: tagColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: tagColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.circle, size: 4, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
