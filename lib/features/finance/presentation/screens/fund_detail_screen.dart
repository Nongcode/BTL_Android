import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/finance_model.dart';
import '../../data/service/finance_service.dart';
import 'add_expense_screen.dart';
import 'finance_screen.dart';

class FundDetailScreen extends StatefulWidget {
  final FundSummary? summary;
  final List<CommonExpense>? expenses;
  final int houseId;

  const FundDetailScreen({
    Key? key,
    this.summary,
    this.expenses,
    this.houseId = 1,
  }) : super(key: key);

  @override
  State<FundDetailScreen> createState() => _FundDetailScreenState();
}

class _FundDetailScreenState extends State<FundDetailScreen> {
  int _selectedMonth = 0;
  FundSummary? _summary;
  List<CommonExpense> _expenses = [];
  bool _loading = false;
  String? _error;
  int? _deletingId;
  late final FinanceService _service;
  final NumberFormat _fmt = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _service = FinanceService(houseId: widget.houseId);
    _summary = widget.summary;
    _expenses = widget.expenses ?? [];
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final now = DateTime.now();
    final month = _selectedMonth == 0
        ? now.month
        : now.subtract(const Duration(days: 30)).month;
    final year = _selectedMonth == 0
        ? now.year
        : now.subtract(const Duration(days: 30)).year;

    try {
      final result = await Future.wait([
        _service.fetchFundSummary(month: month, year: year),
        _service.fetchCommonExpenses(month: month, year: year),
      ]);
      if (!mounted) return;
      setState(() {
        _summary = result[0] as FundSummary? ?? _summary;
        _expenses = (result[1] as List<CommonExpense>? ?? [])
          ..sort((a, b) => b.expenseDate.compareTo(a.expenseDate));
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Không tải được dữ liệu quỹ';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteExpense(CommonExpense e) async {
    if (_deletingId != null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa chi tiêu quỹ?'),
        content: Text('Bạn chắc chắn muốn xóa "${e.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _deletingId = e.id);
    final ok = await _service.deleteCommonExpense(expenseId: e.id);

    if (!mounted) return;
    setState(() => _deletingId = null);

    if (ok) {
      setState(() {
        _expenses = _expenses.where((x) => x.id != e.id).toList();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã xóa chi tiêu quỹ')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Xóa thất bại, thử lại')));
    }
  }

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
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_loading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
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
      onTap: () {
        setState(() => _selectedMonth = index);
        _loadData();
      },
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
    final summary = _summary;
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
            summary != null
                ? _fmt.format(summary.contributionAmount)
                : FinanceScreen.contributionAmount,
          ),
          const SizedBox(height: 4),
          _infoRow("Số thành viên:", summary?.totalMembers.toString() ?? "-"),
          const Divider(height: 24),
          _infoRow(
            "Tổng quỹ:",
            summary != null ? _fmt.format(summary.totalContributions) : "…",
            valueColor: const Color(0xFF00AA55),
          ),
          const SizedBox(height: 4),
          _infoRow(
            "Số dư hiện tại:",
            summary != null ? _fmt.format(summary.currentBalance) : "…",
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
    final members = _summary?.memberStatus ?? [];
    if (members.isEmpty) {
      return const Text(
        "Chưa có dữ liệu đóng quỹ",
        style: TextStyle(color: Colors.grey),
      );
    }

    return Column(
      children: members.map((m) {
        final hasPaid = m.status == 'contributed';
        final amountText = hasPaid ? _fmt.format(m.amount) : 'Chưa đóng';
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
                      m.memberName.isNotEmpty
                          ? m.memberName.substring(0, 1)
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    m.memberName,
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
                  amountText,
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
    if (_expenses.isEmpty) {
      return const Text(
        "Chưa có chi tiêu",
        style: TextStyle(color: Colors.grey),
      );
    }

    return Column(
      children: _expenses.map((e) {
        final dateText =
            '${e.expenseDate.day}/${e.expenseDate.month}/${e.expenseDate.year}';
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
                    e.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        _fmt.format(e.amount),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      (_deletingId == e.id)
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                                size: 18,
                              ),
                              onPressed: () => _deleteExpense(e),
                            ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 4),
              Text(
                'Do ${e.paidByName.isNotEmpty ? e.paidByName : 'thành viên'} mua • ngày $dateText',
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
      onTap: () async {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AddExpenseScreen(summary: _summary, houseId: _service.houseId),
          ),
        );
        if (result == true) {
          await _loadData();
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Đã thêm chi tiêu quỹ')));
        }
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
