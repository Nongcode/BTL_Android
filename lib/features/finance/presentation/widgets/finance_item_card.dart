import 'package:flutter/material.dart';

class FinanceItemCard extends StatelessWidget {
  final String title;
  final String description;
  final String amount;
  final String category; // 'expense' hoặc 'income'
  final String? date;

  const FinanceItemCard({
    super.key,
    required this.title,
    required this.description,
    required this.amount,
    required this.category,
    this.date,
  });

  @override
  Widget build(BuildContext context) {
    bool isExpense = category == 'expense';
    Color categoryColor = isExpense ? Colors.red : Colors.green;
    IconData categoryIcon = isExpense ? Icons.trending_down : Icons.trending_up;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isExpense
              ? const Color(0xFFFFF0F0)
              : const Color(0xFFF0FFF0),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: categoryColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon category
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(categoryIcon, color: categoryColor, size: 24),
            ),
            const SizedBox(width: 15),

            // Title và description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                  if (date != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        date!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Amount
            Text(
              amount,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: categoryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
