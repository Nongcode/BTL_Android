import 'package:flutter/material.dart';
import '../../data/models/finance_model.dart';
import '../../data/service/finance_service.dart';
import '../widgets/finance_header.dart';

class PaymentHistoryScreen extends StatefulWidget {
  final int debtId;
  final String title;
  final int houseId;

  const PaymentHistoryScreen({
    super.key,
    required this.debtId,
    required this.title,
    this.houseId = 1,
  });

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  late final FinanceService _service;
  List<DebtPayment> _payments = [];
  bool _loading = false;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _service = FinanceService(houseId: widget.houseId);
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() => _loading = true);
    final list = await _service.fetchDebtPayments(debtId: widget.debtId);
    if (!mounted) return;
    setState(() {
      _payments = list;
      _loading = false;
    });
  }

  Future<void> _confirmPayment(DebtPayment payment) async {
    setState(() => _loading = true);
    final ok = await _service.confirmDebtPayment(paymentId: payment.paymentId);
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Đã xác nhận thanh toán' : 'Xác nhận thất bại'),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );
    if (ok) {
      _changed = true;
      await _loadPayments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F8FB),
      body: Column(
        children: [
          FinanceHeader(
            title: 'Lịch sử thanh toán',
            onBack: () => Navigator.pop(context, _changed),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadPayments,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _payments.isEmpty ? 1 : _payments.length,
                itemBuilder: (context, index) {
                  if (_payments.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Center(
                        child: _loading
                            ? const CircularProgressIndicator()
                            : const Text('Chưa có thanh toán'),
                      ),
                    );
                  }
                  final p = _payments[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text('${p.amountPaid.toStringAsFixed(0)} đ'),
                      subtitle: Text(
                        '${p.paymentDate.day}/${p.paymentDate.month}/${p.paymentDate.year} · ${p.paymentMethod}',
                      ),
                      trailing: p.confirmed
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : (_loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : TextButton(
                                    onPressed: () => _confirmPayment(p),
                                    child: const Text('Xác nhận'),
                                  )),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
