import 'package:flutter/material.dart';
import '../../data/models/finance_model.dart';
import '../../data/service/finance_service.dart';
import '../widgets/finance_header.dart';

class FundHistoryScreen extends StatefulWidget {
  final int houseId;
  final int? month;
  final int? year;
  final String type;

  const FundHistoryScreen({
    super.key,
    required this.houseId,
    this.month,
    this.year,
    this.type = 'all',
  });

  @override
  State<FundHistoryScreen> createState() => _FundHistoryScreenState();
}

class _FundHistoryScreenState extends State<FundHistoryScreen> {
  late final FinanceService _service;
  List<FundHistoryItem> _items = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _service = FinanceService(houseId: widget.houseId);
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await _service.fetchFundHistory(
      month: widget.month,
      year: widget.year,
      type: widget.type,
    );
    if (!mounted) return;
    setState(() {
      _items = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F8FB),
      body: Column(
        children: [
          FinanceHeader(
            title: 'Lịch sử thanh toán',
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              child: _loading && _items.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _items.isEmpty ? 1 : _items.length,
                      itemBuilder: (context, index) {
                        if (_items.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Center(child: Text('Chưa có lịch sử')),
                          );
                        }
                        final item = _items[index];
                        final isPositive = item.amount >= 0;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isPositive
                                  ? const Color(0xFF14B8A6)
                                  : Colors.redAccent,
                              child: Text(
                                item.type.isNotEmpty
                                    ? item.type.substring(0, 1).toUpperCase()
                                    : '?',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              item.description.isNotEmpty
                                  ? item.description
                                  : 'Biến động quỹ',
                            ),
                            subtitle: Text(
                              '${item.memberName.isNotEmpty ? item.memberName : 'Không rõ'} · ${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}',
                            ),
                            trailing: Text(
                              (isPositive ? '+' : '') +
                                  item.amount.toStringAsFixed(0),
                              style: TextStyle(
                                color: isPositive
                                    ? const Color(0xFF14B8A6)
                                    : Colors.redAccent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
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
