import 'package:flutter/material.dart';

import '../../data/models/finance_model.dart';
import '../../data/service/finance_service.dart';

class DebtSummaryScreen extends StatefulWidget {
  const DebtSummaryScreen({super.key});

  @override
  State<DebtSummaryScreen> createState() => _DebtSummaryScreenState();
}

class _DebtSummaryScreenState extends State<DebtSummaryScreen> {
  final FinanceService _service = FinanceService(houseId: 1);
  List<DebtPair> _pairs = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _service.fetchDebtSummary();
      if (!mounted) return;
      setState(() {
        _pairs = list;
        if (list.isEmpty) {
          _error = 'Chưa có dữ liệu nợ';
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Không tải được danh sách nợ';
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F8FB),

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadSummary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Dựa trên tất cả chi tiêu, đây là số tiền mỗi người đang nợ",
                        style: TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                      const SizedBox(height: 14),

                      if (_loading)
                        const Center(child: CircularProgressIndicator())
                      else if (_error != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 6),
                            if (FinanceService.lastDebtSummaryDebug != null)
                              Text(
                                FinanceService.lastDebtSummaryDebug!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                          ],
                        )
                      else ...[
                        _buildOverviewRow(),

                        const SizedBox(height: 24),
                        const Text(
                          "Danh sách cặp nợ",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),

                        ..._pairs.map(
                          (p) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildDebtCard(
                              context,
                              name:
                                  "${p.debtor.memberName} đang nợ ${p.creditor.memberName}",
                              amount:
                                  "${p.remainingAmount.toStringAsFixed(0)} đ",
                              color: const Color(0xFFB8E0F8),
                              showPayButton: false,
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                        _suggestionBox(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ======================= HEADER =======================
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF5DBDD4), Color(0xFF7DD4E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Text(
            "Danh sách chi trả",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ======================= OVERVIEW CARD =======================
  Widget _buildOverviewRow() {
    final top = _pairs.take(3).toList();
    if (top.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: top
          .map(
            (p) => _buildSmallStat(
              p.debtor.memberName,
              '-${p.remainingAmount.toStringAsFixed(0)} đ',
              'Đang nợ ${p.creditor.memberName}',
            ),
          )
          .toList(),
    );
  }

  Widget _buildSmallStat(String name, String amount, String note) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFBEE6F2)),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF5DBDD4),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            note,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // ======================= DEBT CARD =======================
  Widget _buildDebtCard(
    BuildContext context, {
    required String name,
    required String amount,
    required Color color,
    bool showPayButton = true,
    String confirmLabel = "Xác nhận thanh toán",
    Color confirmColor = const Color(0xFF7DD4E8),
  }) {
    // TÁCH NGƯỜI NỢ – NGƯỜI ĐƯỢC TRẢ TỪ CHUỖI "Lan đang nợ Minh"
    final parts = name.split(" đang nợ ");
    if (parts.length < 2) {
      return const SizedBox.shrink();
    }
    final from = parts[0]; // người nợ
    final to = parts[1]; // người được trả

    final intAmount = int.tryParse(amount.replaceAll(RegExp(r'[^0-9]'), ""));

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBEE6F2)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),

          // ===== TEXT =====
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          if (showPayButton)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: confirmColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                confirmLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ======================= SUGGESTION BOX =======================
  Widget _suggestionBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F7FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBEE6F2)),
      ),
      child: const Text(
        "Gợi ý thanh toán\nLan trả Minh 100.000 đ – Hà trả Minh 200.000 đ",
        style: TextStyle(fontSize: 14, color: Colors.black87),
      ),
    );
  }
}
