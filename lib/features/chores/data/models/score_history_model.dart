import 'package:flutter/material.dart';

class ScoreHistoryItem {
  final String title;
  final String time;
  final int points;
  final bool isBonus;
  final IconData icon;

  ScoreHistoryItem({
    required this.title, 
    required this.time, 
    required this.points, 
    this.isBonus = true,
    this.icon = Icons.check_circle_outline,
  });
}