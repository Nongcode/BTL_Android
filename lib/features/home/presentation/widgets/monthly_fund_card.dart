import 'package:flutter/material.dart';

class MonthlyFundCard extends StatelessWidget {
  final VoidCallback? onPressed;
  const MonthlyFundCard({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ---------------- CARD 1: QUỸ CHUNG ----------------
          _buildFundSummary(),

          const SizedBox(height: 20),

          /// ---------------- CARD 2: NỢ CỦA BẠN ----------------
          _buildDebtStatus(),

          const SizedBox(height: 20),

          /// ---------------- LIST EXPENSE ITEMS ----------------
          _buildExpenseItem(
            title: "Bình nước uống",
            subtitle: "90.000 đ · trừ quỹ ngày 10/11",
          ),
          const SizedBox(height: 16),

          _buildExpenseItem(
            title: "Nước rửa chén",
            subtitle: "45.000 đ · trừ quỹ ngày 08/11",
          ),

          const SizedBox(height: 26),

          /// ---------------- BUTTON ----------------
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7DD4E8),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Xem chi tiết quỹ chung",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- UI BLOCKS ----------------

  Widget _buildFundSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F3FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF5DBDD4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF5DBDD4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.attach_money,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "Quỹ chung tháng này",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _buildRow("Mức đóng:", "500.000 đ/người"),
          const SizedBox(height: 6),

          _buildRow(
            "Số dư quỹ sinh hoạt:",
            "1.350.000 đ",
            const Color(0xFF00AA55),
          ),
          const SizedBox(height: 6),

          Row(
            children: [
              const Expanded(
                child: Text(
                  "Bạn:",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00AA55),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  "ĐÃ ĐÓNG",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDebtStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2D9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFCC970), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tình hình nợ của bạn",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),

          _buildRow("Bạn đang nợ:", "500.000 đ/người", const Color(0xFFFF9500)),
        ],
      ),
    );
  }

  Widget _buildExpenseItem({required String title, required String subtitle}) {
    return GestureDetector(
      onTap: () {},
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),

          const Icon(Icons.chevron_right, color: Colors.black87, size: 24),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, [Color? color]) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
