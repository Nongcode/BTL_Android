import 'package:flutter/material.dart';
import '../widgets/finance_header.dart';
import '../../data/service/finance_service.dart';

class ConfirmPaymentScreen extends StatefulWidget {
  final String from;
  final String to;
  final double amount;
  final int debtId;
  final int houseId;

  const ConfirmPaymentScreen({
    super.key,
    required this.from,
    required this.to,
    required this.amount,
    required this.debtId,
    this.houseId = 1,
  });

  @override
  State<ConfirmPaymentScreen> createState() => _ConfirmPaymentScreenState();
}

class _ConfirmPaymentScreenState extends State<ConfirmPaymentScreen> {
  DateTime selectedDate = DateTime.now();
  final TextEditingController noteController = TextEditingController();
  late final TextEditingController amountController;
  late final FinanceService _service;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController(
      text: widget.amount.toStringAsFixed(0),
    );
    _service = FinanceService(houseId: widget.houseId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F8FB),
      body: Column(
        children: [
          // ✅ HEADER DÙNG CHUNG – GIỐNG MÀN DANH SÁCH CHI TRẢ
          FinanceHeader(
            title: "Xác nhận thanh toán",
            onBack: () => Navigator.pop(context),
          ),

          // ✅ BODY SCROLL
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- CARD: NGƯỜI TRẢ TIỀN ---
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
                        text: "${widget.from} sẽ trả cho ${widget.to}: ",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: "${widget.amount.toStringAsFixed(0)} đ",
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

                  const Text(
                    "Số tiền thanh toán",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Nhập số tiền",
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

                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateUtils.isSameDay(selectedDate, DateTime.now())
                                ? "Hôm nay"
                                : "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const Icon(
                            Icons.calendar_today,
                            size: 20,
                            color: Color(0xFF5DBDD4),
                          ),
                        ],
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: noteController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Ví dụ: Chuyển khoản MB Bank...",
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- BUTTON: ĐÁNH DẤU ĐÃ TRẢ ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5DBDD4),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Đánh dấu đã trả",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- HUỶ ---
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

  Future<void> _handleSubmit() async {
    if (_submitting) return;
    final rawAmount =
        double.tryParse(
          amountController.text.replaceAll(RegExp(r'[^0-9.]'), ''),
        ) ??
        0;
    if (rawAmount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nhập số tiền hợp lệ')));
      return;
    }
    setState(() => _submitting = true);
    final ok = await _service.payDebt(
      debtId: widget.debtId,
      amountPaid: rawAmount,
      paymentDate: selectedDate,
      paymentMethod: 'cash',
      note: noteController.text.trim().isEmpty
          ? null
          : noteController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Ghi nhận thanh toán thành công'
              : 'Ghi nhận thanh toán thất bại',
        ),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );
    if (ok) Navigator.pop(context, true);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }
}
