import 'package:flutter/material.dart';
import '../widgets/finance_header.dart';

class PaidPaymentScreen extends StatelessWidget {
  final String from;
  final String to;
  final int amount;
  final DateTime date;
  final String note;

  const PaidPaymentScreen({
    super.key,
    required this.from,
    required this.to,
    required this.amount,
    required this.date,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F8FB),
      body: Column(
        children: [
          // ✅ HEADER ĐỒNG NHẤT 100% VỚI CONFIRM PAYMENT
          FinanceHeader(
            title: "Đã thanh toán",
            onBack: () => Navigator.pop(context),
          ),

          // ✅ BODY
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- CARD: ĐÃ THANH TOÁN ---
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFB8D8D0)),
                    ),
                    child: RichText(
                      text: TextSpan(
                        text: "$from đã trả cho $to: ",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: "$amount đ",
                            style: const TextStyle(
                              color: Color(0xFF5DBDD4),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- NGÀY THANH TOÁN ---
                  const Text(
                    "Ngày thanh toán",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 6),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      _formatDate(date),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- GHI CHÚ ---
                  const Text(
                    "Ghi chú (tuỳ chọn)",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 6),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      note.isEmpty ? "(Không có ghi chú)" : note,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- BUTTON: HUỶ ---
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Huỷ",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (DateUtils.isSameDay(date, now)) return "Hôm nay";
    return "${date.day}/${date.month}/${date.year}";
  }
}
