import 'package:flutter/material.dart';
import '../widgets/finance_stat_card.dart';
import 'fund_detail_screen.dart';
import 'add_expense_screen.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  int _expenseTabIndex = 0; // 0 = Chi tiêu, 1 = Doanh thu

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F8FB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header
                const Text(
                  "Quỹ chung",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Tổng quan chi tiêu trong nhà",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),

                // 2. Stat Cards (3 cột)
                Row(
                  children: [
                    Expanded(
                      child: FinanceStatCard(
                        title: "Tổng chi quỹ",
                        amount: "1.250.000 đ",
                        amountColor: const Color(0xFF68A7E3),
                        icon: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFF68A7E3).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.trending_up,
                              size: 16,
                              color: Color(0xFF68A7E3),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FinanceStatCard(
                        title: "Số dư quỹ",
                        amount: "80.000 đ",
                        amountColor: const Color(0xFF14B8A6),
                        icon: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFF14B8A6).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.attach_money,
                              size: 16,
                              color: Color(0xFF14B8A6),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FinanceStatCard(
                        title: "Bạn đang nợ",
                        amount: "150.000 đ",
                        amountColor: const Color(0xFFFC9F66),
                        icon: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFC9F66).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.help_outline,
                              size: 16,
                              color: Color(0xFFFC9F66),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // 3. Quỹ sinh hoạt section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF5DBDD4),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Quỹ sinh hoạt
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Quỹ sinh hoạt",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const FundDetailScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Xem chi tiêu quỹ",
                              style: TextStyle(
                                color: Color(0xFF5DBDD4),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Mục đông
                      _buildQuotaRow("Mức đóng:", "500.000 đ/người/tháng"),
                      const SizedBox(height: 12),

                      // Đổ đông (members)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Đã đóng:",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          Row(
                            children: const [
                              _MemberCircle(
                                label: "M",
                                color: Color(0xFFE8B4D0),
                              ),
                              SizedBox(width: 8),
                              _MemberCircle(
                                label: "L",
                                color: Color(0xFFB8E8B8),
                              ),
                              SizedBox(width: 8),
                              _MemberCircle(
                                label: "T",
                                color: Color(0xFFB8E8E8),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Số dự hiện tại
                      _buildQuotaRow(
                        "Số dự hiện tại:",
                        "80.000 đ",
                        color: const Color(0xFF5DBDD4),
                      ),
                      const SizedBox(height: 16),

                      const Divider(thickness: 1),
                      const SizedBox(height: 16),

                      // Chi tiêu quỹ items
                      _buildFundExpenseItem(
                        title: "Binh nước uống",
                        amount: "90.000 đ - Trừ quỹ ngày 10/11",
                      ),
                      const SizedBox(height: 12),

                      _buildFundExpenseItem(
                        title: "Nước rửa chén",
                        amount: "40.000 đ - Trừ quỹ ngày 08/11",
                      ),

                      const SizedBox(height: 16),

                      // Button Xem tất cả
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5DBDD4),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Xem tất cả chi tiêu quỹ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // 4. Chi tiêu phát sinh section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with "Thêm chi tiêu mới" button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Chi tiêu phát sinh",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Handle add new expense
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF5DBDD4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "Thêm chi tiêu mới",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Tabs
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() => _expenseTabIndex = 0);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _expenseTabIndex == 0
                                    ? const Color(0xFF5DBDD4)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: _expenseTabIndex == 0
                                    ? null
                                    : Border.all(
                                        color: Colors.grey.shade300,
                                        width: 1,
                                      ),
                              ),
                              child: Text(
                                "Chi tiêu",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: _expenseTabIndex == 0
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              setState(() => _expenseTabIndex = 1);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _expenseTabIndex == 1
                                    ? const Color(0xFF5DBDD4)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: _expenseTabIndex == 1
                                    ? null
                                    : Border.all(
                                        color: Colors.grey.shade300,
                                        width: 1,
                                      ),
                              ),
                              child: Text(
                                "Danh sách nợ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: _expenseTabIndex == 1
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Tab content
                      if (_expenseTabIndex == 0) ...[
                        // Chi tiêu list
                        _buildExpenseItemWithIcon(
                          icon: "⭐",
                          title: "Phần thưởng tháng 12",
                          description: "A được nhận",
                          date: "1/1/2026",
                          amount: "100.000 đ",
                          badge: "Xác nhận",
                          badgeColor: const Color(0xFFB8D8D0),
                        ),
                        const SizedBox(height: 12),
                        _buildExpenseItemWithIcon(
                          icon: "",
                          title: "Phí phát tháng 12",
                          description: "C bị phạt",
                          date: "1/1/2026",
                          amount: "100.000 đ",
                          badge: "Thành toán",
                          badgeColor: const Color(0xFFB8D8D0),
                        ),
                        const SizedBox(height: 12),
                        _buildExpenseItemWithIcon(
                          icon: "",
                          title: "Dị ăn lẩu cuối tháng",
                          description: "A đã trả - Chia cho A, B, C",
                          date: "27/11/2025",
                          amount: "500.000 đ",
                          badge: "Chia theo người thêm gia",
                          badgeColor: const Color(0xFFB8D8D0),
                          // isHighlight: true,
                        ),
                        const SizedBox(height: 12),
                        _buildExpenseItemWithIcon(
                          icon: "",
                          title: "Bánh sinh nhật",
                          description: "B đã trả - Chia cho A, B, C, D",
                          date: "27/11/2025",
                          amount: "200.000 đ",
                          badge: "Chia đều",
                          badgeColor: const Color(0xFFB8D8D0),
                        ),
                      ] else if (_expenseTabIndex == 1) ...[
                        // Danh sách nợ
                        _buildDebtItem(
                          name: "Tuấn đang nợ Long",
                          amount: "100.000 đ",
                        ),
                        const SizedBox(height: 12),
                        _buildDebtItem(
                          name: "Long đang nợ Tuấn",
                          amount: "200.000 đ",
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: GestureDetector(
                            onTap: () {},
                            child: const Text(
                              "Xem chi tiết ai nợ ai",
                              style: TextStyle(
                                color: Color(0xFF5DBDD4),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseItemWithIcon({
    required String icon,
    required String title,
    required String description,
    required String date,
    required String amount,
    required String badge,
    required Color badgeColor,
    bool isHighlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isHighlight ? const Color(0xFFE8F8FB) : const Color(0xFFE8F8FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFB8D8D0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(icon, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            description,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            date,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (isHighlight) ...[
            const SizedBox(height: 8),
            Text(
              "Chia theo người thêm gia",
              style: TextStyle(
                fontSize: 11,
                color: Colors.blue.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDebtItem({required String name, required String amount}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF5DBDD4).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.arrow_forward,
                size: 16,
                color: Color(0xFF5DBDD4),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF5DBDD4),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              amount,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF5DBDD4),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              "Xác nhận thành toán",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuotaRow(
    String label,
    String value, {
    Color color = Colors.black87,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildFundExpenseItem({
    required String title,
    required String amount,
  }) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FEFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD0EFF5), width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    amount,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _MemberCircle extends StatelessWidget {
  final String label;
  final Color color;

  const _MemberCircle({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
