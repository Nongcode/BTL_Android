import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class MemberRank {
  final String name;
  final String avatar; // Đường dẫn ảnh hoặc tên viết tắt
  final int score;
  final int tasksDone;
  final int rank;
  final Color color;

  MemberRank({
    required this.name,
    required this.avatar,
    required this.score,
    required this.tasksDone,
    required this.rank,
    required this.color,
  });
}