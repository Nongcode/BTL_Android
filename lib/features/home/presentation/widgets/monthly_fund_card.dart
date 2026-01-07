import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../finance/data/models/finance_model.dart';
import '../../../finance/data/service/finance_service.dart';
import '../../../finance/logic/finance_sync.dart';

class MonthlyFundCard extends StatefulWidget {
  final VoidCallback? onPressed;
  final int houseId;
  final int currentMemberId;

  const MonthlyFundCard({
    super.key,
    this.onPressed,
    this.houseId = 1,
    this.currentMemberId = 1,
  });

  @override
  State<MonthlyFundCard> createState() => _MonthlyFundCardState();
}

class _MonthlyFundCardState extends State<MonthlyFundCard> {
  late final FinanceService _service;
  FundSummary? _summary;
  double _debtOwed = 0;
  bool _loading = true;
  String? _error;
  final NumberFormat _fmt = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _service = FinanceService(houseId: widget.houseId);
    FinanceSync.version.addListener(_handleSync);
    _loadData();
  }

  @override
  void dispose() {
    FinanceSync.version.removeListener(_handleSync);
    super.dispose();
  }

  void _handleSync() {
    _loadData();
  }

  Future<void> refresh() => _loadData();

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final now = DateTime.now();
    try {
      final data = await _service.fetchFundSummary(
        month: now.month,
        year: now.year,
      );
      final debts = await _service.fetchDebts(memberId: widget.currentMemberId);
      if (!mounted) return;
      setState(() {
        _summary = data;
        _debtOwed = _sumDebtOwed(debts);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Không tải được dữ liệu quỹ');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  MemberStatus? get _userStatus {
    final members = _summary?.memberStatus ?? [];
    try {
      return members.firstWhere((m) => m.memberId == widget.currentMemberId);
    } catch (_) {
      return null;
    }
  }

  bool get _userContributed => _userStatus?.status == 'contributed';

  double _sumDebtOwed(List<DebtItem> debts) {
    double total = 0;
    for (final d in debts) {
      final remaining = d.remainingAmount < 0 ? 0 : d.remainingAmount;
      total += remaining;
    }
    return total;
  }

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
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            )
          else ...[
            /// ---------------- CARD 1: QUỸ CHUNG ----------------
            _buildFundSummary(),

            const SizedBox(height: 20),

            /// ---------------- CARD 2: TRẠNG THÁI ĐÓNG QUỸ ----------------
            _buildDebtStatus(),
          ],

          const SizedBox(height: 24),

          /// ---------------- BUTTON ----------------
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: widget.onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF50C2C9),
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
    final summary = _summary;
    final memberStatus = _userStatus;
    final contributionText = summary != null
        ? _fmt.format(summary.contributionAmount)
        : '-';
    final balanceText = summary != null
        ? _fmt.format(summary.currentBalance)
        : '...';

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

          _buildRow("Mức đóng:", "$contributionText/người"),
          const SizedBox(height: 6),

          _buildRow(
            "Số dư quỹ sinh hoạt:",
            balanceText,
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
              _statusChip(memberStatus),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDebtStatus() {
    final summary = _summary;
    final contributionAmount = summary?.contributionAmount ?? 0;
    final memberStatus = _userStatus;
    final pendingText = _fmt.format(contributionAmount);

    final isPaid = _userContributed;
    final fundDue = isPaid ? 0 : contributionAmount;
    final totalDue = fundDue + _debtOwed;
    final totalText = _fmt.format(totalDue);

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

          _buildRow(
            isPaid ? "Bạn đã đóng quỹ:" : "Bạn cần đóng quỹ:",
            _fmt.format(
              isPaid ? (memberStatus?.amount ?? contributionAmount) : fundDue,
            ),
            isPaid ? const Color(0xFF00AA55) : const Color(0xFFFF9500),
          ),
          const SizedBox(height: 8),
          _buildRow(
            "Nợ chi tiêu phát sinh:",
            _fmt.format(_debtOwed),
            _debtOwed > 0 ? const Color(0xFFFF9500) : Colors.black87,
          ),
          const Divider(height: 18),
          _buildRow(
            "Tổng bạn đang nợ:",
            totalText,
            totalDue > 0 ? const Color(0xFFFF3B30) : const Color(0xFF00AA55),
          ),
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

  Widget _statusChip(MemberStatus? status) {
    final contributed = _userContributed;
    final label = contributed ? 'ĐÃ ĐÓNG' : 'CHƯA ĐÓNG';
    final bg = contributed
        ? const Color.fromARGB(255, 134, 205, 169)
        : const Color(0xFFFFE5C2);
    final color = contributed ? Colors.white : const Color(0xFFFF9500);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            contributed ? Icons.check_circle_outline : Icons.hourglass_bottom,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
