import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/finance_model.dart';
import '../../data/service/finance_service.dart';
import '../widgets/finance_stat_card.dart';
import 'fund_detail_screen.dart';
import 'add_expense_screen.dart';
import 'confirm_payment_screen.dart';
import 'payment_history_screen.dart';
import 'fund_history_screen.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  static String contributionAmount = "500.000 đ/người/tháng";

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  int _expenseTabIndex = 0; // 0 = Chi tiêu, 1 = Doanh thu
  late String _contributionAmount;
  final FinanceService _service = FinanceService(houseId: 1);
  FundSummary? _summary;
  List<CommonExpense> _commonExpenses = [];
  List<AdHocExpense> _adHocExpenses = [];
  int? _deletingAdHocId;
  List<DebtItem> _debts = [];
  int? _selectedDebtMemberId;
  bool _loadingDebts = false;
  bool _loading = false;
  String? _error;
  String? _debtError;

  final NumberFormat _currency = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _contributionAmount = FinanceScreen.contributionAmount;
    _loadFinance();
  }

  Future<void> _loadFinance() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final summary = await _service.fetchFundSummary();
      final common = await _service.fetchCommonExpenses();
      final adHoc = await _service.fetchAdHocExpenses();
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _commonExpenses = common;
        _adHocExpenses = adHoc;
        if (summary != null) {
          _contributionAmount =
              "${_currency.format(summary.contributionAmount)} /người";
          FinanceScreen.contributionAmount = _contributionAmount;
        }
        _initDebtMember(summary);
      });
      if (_selectedDebtMemberId != null) {
        await _loadDebtsForMember(_selectedDebtMemberId!);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Không tải được dữ liệu quỹ';
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _initDebtMember(FundSummary? summary) {
    if (_selectedDebtMemberId != null) return;
    final members = summary?.memberStatus ?? [];
    if (members.isNotEmpty) {
      _selectedDebtMemberId = members.first.memberId;
    }
  }

  Future<void> _loadDebtsForMember(int memberId) async {
    setState(() {
      _loadingDebts = true;
      _debtError = null;
    });
    try {
      final list = await _service.fetchDebts(memberId: memberId);
      if (!mounted) return;
      setState(() {
        _debts = list;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _debtError = 'Không tải được danh sách nợ';
      });
    } finally {
      if (mounted) setState(() => _loadingDebts = false);
    }
  }

  Future<void> _handleAddExpense() async {
    final summary = _summary;
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(
          initialType: 1, // chi tiêu phát sinh
          summary: summary,
          houseId: _service.houseId,
        ),
      ),
    );
    if (result == true) {
      await _loadFinance();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã thêm chi tiêu phát sinh')),
      );
    }
  }

  Future<void> _handleEditAdHoc(AdHocExpense expense) async {
    final summary = _summary;
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(
          initialType: 1,
          summary: summary,
          houseId: _service.houseId,
          adHocExpense: expense,
          viewOnly: true,
        ),
      ),
    );
    if (result == true) {
      await _loadFinance();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật chi tiêu phát sinh')),
      );
    }
  }

  Future<void> _openDebtExpense(DebtItem debt) async {
    AdHocExpense? target;
    AdHocExpense? findById() {
      if (debt.expenseId <= 0) return null;
      for (final e in _adHocExpenses) {
        if (e.id == debt.expenseId) return e;
      }
      return null;
    }

    target = findById();

    // Nếu chưa thấy, tải lại danh sách chi tiêu phát sinh rồi thử lại
    if (target == null) {
      final refreshed = await _service.fetchAdHocExpenses();
      if (mounted) setState(() => _adHocExpenses = refreshed);
      target = findById();
    }

    // Nếu backend chưa trả expenseId hoặc dữ liệu chưa đồng bộ
    if (target == null) {
      final msg = debt.expenseId > 0
          ? 'Không tìm thấy chi tiêu gốc (ID ${debt.expenseId}). Thử tải lại.'
          : 'Khoản nợ này chưa gắn với chi tiêu phát sinh.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return;
    }

    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(
          initialType: 1,
          summary: _summary,
          houseId: _service.houseId,
          adHocExpense: target,
          viewOnly: true,
        ),
      ),
    );

    if (changed == true && _selectedDebtMemberId != null) {
      await _loadFinance();
      await _loadDebtsForMember(_selectedDebtMemberId!);
    }
  }

  Future<void> _handleDeleteAdHoc(AdHocExpense expense) async {
    if (_deletingAdHocId != null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa chi tiêu phát sinh?'),
        content: Text('Bạn chắc chắn muốn xóa "${expense.title}"?'),
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

    setState(() => _deletingAdHocId = expense.id);
    final ok = await _service.deleteAdHocExpense(expenseId: expense.id);

    if (!mounted) return;
    setState(() => _deletingAdHocId = null);

    if (ok) {
      await _loadFinance();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa chi tiêu phát sinh')),
      );
    } else {
      final msg =
          FinanceService.lastDeleteAdHocError ?? 'Xóa thất bại, thử lại';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  void _editContributionAmount() {
    final initialNumber =
        _summary?.contributionAmount ??
        double.tryParse(_contributionAmount.replaceAll(RegExp(r'[^0-9.]'), ''));
    TextEditingController controller = TextEditingController(
      text: (initialNumber != null && initialNumber > 0)
          ? initialNumber.toStringAsFixed(0)
          : '',
    );

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        bool isSaving = false;
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text("Chỉnh sửa mức đóng quỹ sinh hoạt"),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: "Nhập mức đóng (vd: 500000)",
                ),
                keyboardType: TextInputType.number,
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text("Hủy"),
                ),
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final parsed = double.tryParse(controller.text) ?? 0;
                          if (parsed <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Vui lòng nhập số hợp lệ'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }

                          setLocalState(() => isSaving = true);

                          final success = await _service.updateFundSettings(
                            contributionAmount: parsed.toDouble(),
                          );

                          await Future.delayed(const Duration(seconds: 1));

                          if (!mounted) return;

                          setState(() {
                            _contributionAmount =
                                "${_currency.format(parsed)} /người";
                            FinanceScreen.contributionAmount =
                                _contributionAmount;
                          });

                          Navigator.of(dialogContext).pop();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Đã cập nhật mức đóng'
                                    : 'Cập nhật thất bại, thử lại',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Lưu"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _fmt(num value) => _currency.format(value);

  @override
  Widget build(BuildContext context) {
    final summary = _summary;
    return Scaffold(
      backgroundColor: const Color(0xFFE8F8FB),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadFinance,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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

                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  // 2. Stat Cards (3 cột)
                  Row(
                    children: [
                      Expanded(
                        child: FinanceStatCard(
                          title: "Tổng chi quỹ",
                          amount: summary != null
                              ? _fmt(summary.totalExpenses)
                              : "…",
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
                          amount: summary != null
                              ? _fmt(summary.currentBalance)
                              : "…",
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
                          amount: "0 đ",
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
                              onTap: _editContributionAmount,
                              child: const Text(
                                "Chỉnh sửa mức đóng",
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Mức đóng:",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  _contributionAmount,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),

                                // IconButton(
                                //   onPressed: _editContributionAmount,
                                //   icon: const Icon(
                                //     Icons.edit,
                                //     size: 16,
                                //     color: Color(0xFF5DBDD4),
                                //   ),
                                //   padding: EdgeInsets.zero,
                                //   constraints: const BoxConstraints(),
                                // ),
                              ],
                            ),
                          ],
                        ),
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
                              children: [
                                if (summary?.memberStatus.isNotEmpty == true)
                                  ...summary!.memberStatus
                                      .where((m) => m.status == 'contributed')
                                      .take(4)
                                      .map(
                                        (m) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          child: _MemberCircle(
                                            label: m.memberName.isNotEmpty
                                                ? m.memberName[0].toUpperCase()
                                                : '?',
                                            color: const Color(0xFFB8E8E8),
                                          ),
                                        ),
                                      ),
                                if (summary == null ||
                                    summary.memberStatus
                                        .where((m) => m.status == 'contributed')
                                        .isEmpty)
                                  const Text(
                                    "Chưa có dữ liệu",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Số dự hiện tại
                        _buildQuotaRow(
                          "Số dư hiện tại:",
                          summary != null ? _fmt(summary.currentBalance) : "…",
                          color: const Color(0xFF5DBDD4),
                        ),
                        const SizedBox(height: 16),

                        const Divider(thickness: 1),
                        const SizedBox(height: 16),

                        // Chi tiêu quỹ items
                        if (_commonExpenses.isEmpty)
                          const Text(
                            "Chưa có chi tiêu",
                            style: TextStyle(color: Colors.grey),
                          )
                        else
                          ..._commonExpenses
                              .take(3)
                              .map(
                                (e) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildFundExpenseItem(
                                    title: e.title,
                                    amount:
                                        "${_fmt(e.amount)} - ${e.expenseDate.day}/${e.expenseDate.month}/${e.expenseDate.year}",
                                  ),
                                ),
                              ),

                        const SizedBox(height: 16),

                        // Button Xem tất cả
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              final changed = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FundDetailScreen(
                                    summary: summary,
                                    expenses: _commonExpenses,
                                    houseId: _service.houseId,
                                  ),
                                ),
                              );
                              if (changed == true) {
                                await _loadFinance();
                              }
                            },
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
                              onTap: _handleAddExpense,
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
                          if (_adHocExpenses.isEmpty)
                            const Text(
                              "Chưa có chi tiêu phát sinh",
                              style: TextStyle(color: Colors.grey),
                            )
                          else
                            ..._adHocExpenses.map(
                              (e) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: GestureDetector(
                                  onTap: () => _handleEditAdHoc(e),
                                  child: _buildExpenseItemWithIcon(
                                    icon: "",
                                    title: e.title,
                                    description: e.description ?? '',
                                    date:
                                        "${e.expenseDate.day}/${e.expenseDate.month}/${e.expenseDate.year}",
                                    amount: _fmt(e.totalAmount),
                                    badge: e.paidByName.isNotEmpty
                                        ? "${e.paidByName} đã trả"
                                        : "Đã chi",
                                    badgeColor: const Color(0xFF5DBDD4),
                                    trailing: (_deletingAdHocId == e.id)
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.redAccent,
                                              size: 18,
                                            ),
                                            onPressed: () =>
                                                _handleDeleteAdHoc(e),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                        ] else if (_expenseTabIndex == 1) ...[
                          _buildDebtHeader(),
                          const SizedBox(height: 12),
                          if (_loadingDebts)
                            const Center(child: CircularProgressIndicator())
                          else if (_debtError != null)
                            Text(
                              _debtError!,
                              style: const TextStyle(color: Colors.red),
                            )
                          else if (_debts.isEmpty)
                            const Text(
                              "Chưa có khoản nợ",
                              style: TextStyle(color: Colors.grey),
                            )
                          else
                            ..._debts.map(
                              (d) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: GestureDetector(
                                  onTap: () => _openDebtExpense(d),
                                  child: _buildDebtCard(d),
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
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
    Widget? trailing,
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
              if (trailing != null) ...[const SizedBox(width: 8), trailing],
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
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildDebtHeader() {
    final members = _summary?.memberStatus ?? [];
    return Row(
      children: [
        const Text(
          "Chọn người nợ:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButton<int>(
              value: _selectedDebtMemberId,
              underline: const SizedBox(),
              isExpanded: true,
              hint: Text(members.isEmpty ? 'Đang tải...' : 'Chọn thành viên'),
              items: members
                  .map(
                    (m) => DropdownMenuItem<int>(
                      value: m.memberId,
                      child: Text(
                        m.memberName.isNotEmpty
                            ? m.memberName
                            : 'Thành viên ${m.memberId}',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) async {
                if (value == null) return;
                setState(() => _selectedDebtMemberId = value);
                await _loadDebtsForMember(value);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDebtCard(DebtItem debt) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            debt.fromExpense.isNotEmpty ? debt.fromExpense : 'Khoản nợ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Chủ nợ: ${debt.creditorName}',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              () {
                final remaining = debt.remainingAmount < 0
                    ? 0
                    : debt.remainingAmount;
                final paidOff = remaining <= 0;
                return Text(
                  paidOff ? 'Đã thanh toán nợ' : 'Còn lại: ${_fmt(remaining)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: paidOff ? Colors.green : Colors.redAccent,
                    fontSize: 14,
                  ),
                );
              }(),
              Row(
                children: [
                  TextButton(
                    onPressed: () async {
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ConfirmPaymentScreen(
                            from:
                                _summary?.memberStatus
                                    .firstWhere(
                                      (m) =>
                                          m.memberId == _selectedDebtMemberId,
                                      orElse: () => MemberStatus(
                                        memberId: 0,
                                        memberName: '',
                                        status: '',
                                        amount: 0,
                                        contributedAt: null,
                                        note: null,
                                      ),
                                    )
                                    .memberName ??
                                '',
                            to: debt.creditorName,
                            amount: debt.remainingAmount,
                            debtId: debt.debtId,
                            houseId: _service.houseId,
                          ),
                        ),
                      );
                      if (result == true && _selectedDebtMemberId != null) {
                        await _loadFinance();
                      }
                    },
                    child: const Text('Thanh toán'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final changed = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentHistoryScreen(
                            debtId: debt.debtId,
                            title: debt.fromExpense,
                            houseId: _service.houseId,
                          ),
                        ),
                      );
                      if (changed == true && _selectedDebtMemberId != null) {
                        await _loadFinance();
                      }
                    },
                    child: const Text('Lịch sử'),
                  ),
                ],
              ),
            ],
          ),
        ],
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
