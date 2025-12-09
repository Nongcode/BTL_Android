// lib/features/bulletin/widgets/form_label.dart
import 'package:flutter/material.dart';

class FormLabel extends StatelessWidget {
  final String text;

  const FormLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }
}
