import 'package:flutter/material.dart';
import 'add_expense_screen.dart';
import 'finance_screen.dart';

class FundDetailScreen extends StatefulWidget {
  const FundDetailScreen({Key? key}) : super(key: key);

  @override
  State<FundDetailScreen> createState() => _FundDetailScreenState();
}

class _FundDetailScreenState extends State<FundDetailScreen> {
  int _selectedMonth = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          _buildMonthSelector(), // <-- TAB CHUẨN FIGMA
          // --- CONTENT ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Tổng quỹ"),
                  const SizedBox(height: 12),
                  _buildSummaryCardFigma(),

                  const SizedBox(height: 28),
                  _sectionTitle("Trạng thái thành viên"),
                  const SizedBox(height: 12),
                  _buildMemberStatusFigma(),

                  const SizedBox(height: 28),
                  _sectionTitle("Chi tiêu từ quỹ"),
                  const SizedBox(height: 12),
                  _buildExpenseListFigma(),

                  const SizedBox(height: 20),
                  _buildAddButton(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ======================= HEADER ==========================
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF5DBDD4), Color(0xFF7DD4E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Text(
                "Quỹ sinh hoạt",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ======================= MONTH SELECTOR (CHUẨN FIGMA) ====================
  Widget _buildMonthSelector() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        children: [
          Row(
            children: [
              _buildMonthTab("Tháng này", 0),
              const SizedBox(width: 10),
              _buildMonthTab("Tháng trước", 1),
            ],
          ),
          const SizedBox(height: 14),

          // Line separator (FIGMA)
          Container(height: 1, color: Colors.black.withOpacity(0.18)),
        ],
      ),
    );
  }

  Widget _buildMonthTab(String label, int index) {
    final bool isSelected = _selectedMonth == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedMonth = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5DBDD4) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            width: 1.3,
            color: isSelected ? const Color(0xFF5DBDD4) : Colors.grey.shade400,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  // ========================= SUMMARY CARD ==========================
  Widget _buildSummaryCardFigma() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F7FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF96DCE8), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(1, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(
            "Mức đóng:",
            FinanceScreen.contributionAmount.replaceAll(
              '/người/tháng',
              '/người',
            ),
          ),
          const SizedBox(height: 4),
          _infoRow("Số thành viên:", "3"),
          const Divider(height: 24),
          _infoRow("Tổng quỹ:", "1.500.000 đ", valueColor: Color(0xFF00AA55)),
          const SizedBox(height: 4),
          _infoRow(
            "Số dư hiện tại:",
            "80.000 đ",
            valueColor: Color(0xFF5DBDD4),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value, {
    Color valueColor = Colors.black,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.black54, fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ======================= MEMBER STATUS ==========================
  Widget _buildMemberStatusFigma() {
    final members = [("Minh", true), ("Long", false), ("Tuấn", true)];

    return Column(
      children: members.map((m) {
        final hasPaid = m.$2;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5F6F9)),
            boxShadow: [
              BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 6),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Avatar + name
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF5DBDD4),
                    child: Text(
                      m.$1.substring(0, 1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    m.$1,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              // Status
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: hasPaid
                      ? const Color(0xFF00AA55).withOpacity(0.12)
                      : const Color(0xFFFFA500).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  hasPaid ? "Đã đóng 500.000 đ" : "Chưa đóng",
                  style: TextStyle(
                    color: hasPaid
                        ? const Color(0xFF00AA55)
                        : const Color(0xFFFFA500),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ========================= EXPENSE LIST ==========================
  Widget _buildExpenseListFigma() {
    final expenses = [
      ("Bình nước uống", "90.000 đ", "Do Long mua • trừ quỹ ngày 10/11"),
      ("Nước rửa chén", "45.000 đ", "Do Minh mua • trừ quỹ ngày 08/11"),
    ];

    return Column(
      children: expenses.map((e) {
        return Container(
          margin: const EdgeInsets.only(bottom: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    e.$1,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    e.$2,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),
              Text(
                e.$3,
                style: TextStyle(fontSize: 13, color: Colors.blue.shade600),
              ),
              const SizedBox(height: 8),
              Container(height: 1, color: Colors.grey.shade300),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ========================= BUTTON ADD SPENDING ==========================
  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
        );
      },
      child: Center(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF7DD4E8),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: const Center(
            child: Text(
              "Thêm chi tiêu từ quỹ",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }
}
