import 'package:flutter/material.dart';
import '../../data/models/finance_model.dart';
import '../../data/service/finance_service.dart';

class AddExpenseScreen extends StatefulWidget {
  final int initialType; // 0 = Chi từ quỹ, 1 = Chi phát sinh
  final FundSummary? summary;
  final int houseId;

  const AddExpenseScreen({
    Key? key,
    this.initialType = 0,
    this.summary,
    this.houseId = 1,
  }) : super(key: key);

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  late int _selectedType; // 0 = Chi từ quỹ, 1 = Chi phát sinh
  int _selectedSplit = 0; // 0=đều, 1=tỷ lệ, 2=tham gia

  DateTime _selectedDate = DateTime.now();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _amount = TextEditingController();
  List<MemberStatus> _members = [];
  int? _selectedMemberId;
  bool _submitting = false;
  late final FinanceService _service;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _service = FinanceService(houseId: widget.houseId);
    _members = widget.summary?.memberStatus ?? [];
    if (_members.isNotEmpty) {
      _selectedMemberId = _members.first.memberId;
    } else {
      _loadMembers();
    }
  }

  Future<void> _loadMembers() async {
    final summary = await _service.fetchFundSummary();
    if (!mounted) return;
    setState(() {
      _members = summary?.memberStatus ?? [];
      if (_members.isNotEmpty) {
        _selectedMemberId = _members.first.memberId;
      }
    });
  }

  double _parseAmount() {
    final raw = _amount.text.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(raw) ?? 0;
  }

  Future<void> _handleSubmit() async {
    if (_submitting) return;
    final title = _title.text.trim();
    final amount = _parseAmount();
    if (title.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên và số tiền hợp lệ')),
      );
      return;
    }
    if (_selectedMemberId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Chọn người trả')));
      return;
    }

    setState(() => _submitting = true);
    bool ok = false;

    if (_selectedType == 0) {
      ok = await _service.addCommonExpense(
        paidBy: _selectedMemberId!,
        title: title,
        description: null,
        amount: amount,
        expenseDate: _selectedDate,
      );
    } else {
      // Chia đều cho tất cả thành viên hiện có nếu chưa chọn cấu hình khác.
      final members = _members.isNotEmpty
          ? _members
          : [
              MemberStatus(
                memberId: _selectedMemberId!,
                memberName: '',
                status: 'pending',
                amount: 0,
                contributedAt: null,
                note: null,
              ),
            ];
      final equalShare = amount / (members.isNotEmpty ? members.length : 1);
      final sharePercent = 100 / (members.isNotEmpty ? members.length : 1);
      final splits = members
          .map(
            (m) => {
              'memberId': m.memberId,
              'sharePercentage': double.parse(sharePercent.toStringAsFixed(2)),
              'amountOwed': double.parse(equalShare.toStringAsFixed(2)),
            },
          )
          .toList();
      ok = await _service.addAdHocExpense(
        paidBy: _selectedMemberId!,
        title: title,
        description: null,
        totalAmount: amount,
        expenseDate: _selectedDate,
        splitMethod: _selectedSplit == 0
            ? 'equal'
            : _selectedSplit == 1
            ? 'ratio'
            : 'custom',
        splits: splits,
      );
    }

    if (!mounted) return;
    setState(() => _submitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Lưu chi tiêu thành công' : 'Không thể lưu chi tiêu',
        ),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );
    if (ok) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Loại chi tiêu"),
                  const SizedBox(height: 12),
                  _buildTypeSelector(),
                  const SizedBox(height: 24),

                  // FORM CHI TIÊU
                  _buildFormCard(),

                  const SizedBox(height: 28),

                  if (_selectedType == 1) _buildSplitMethod(),

                  const SizedBox(height: 30),
                  _buildMainButton(),
                  const SizedBox(height: 14),
                  _buildCancelButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- HEADER -------------------
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF5DBDD4), Color(0xFF7DD4E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: SafeArea(
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Text(
              "Thêm chi tiêu mới",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- SECTION TITLE -------------------
  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }

  // ---------------- TYPE SELECTOR -------------------
  Widget _buildTypeSelector() {
    return Column(
      children: [
        _buildTypeItem(
          title: "Chi từ quỹ sinh hoạt",
          description:
              "Các khoản nhỏ dùng chung · Mặc định chia đều · Trừ trực tiếp vào quỹ.",
          index: 0,
        ),
        const SizedBox(height: 14),
        _buildTypeItem(
          title: "Chi tiêu phát sinh (chia nợ riêng)",
          description:
              "Các khoản đặc biệt · Chia theo người dùng · Tính nợ riêng.",
          index: 1,
        ),
      ],
    );
  }

  Widget _buildTypeItem({
    required String title,
    required String description,
    required int index,
  }) {
    final isActive = _selectedType == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedType = index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? const Color(0xFF5DBDD4) : Colors.grey.shade300,
            width: isActive ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isActive ? const Color(0xFF5DBDD4) : Colors.black87,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- FORM CARD -------------------
  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFC7E8EB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF96DCE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            "Tên chi tiêu (*)",
            "Vd: Tiền điện tháng 11…",
            _title,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            "Số tiền (đ) (*)",
            "Nhập số tiền",
            _amount,
            type: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildMemberDropdown(),
          const SizedBox(height: 16),
          _buildDatePicker(),
          const SizedBox(height: 12),

          Text(
            _selectedType == 0
                ? "Khoản chi này sẽ được trừ trực tiếp từ quỹ sinh hoạt."
                : "Khoản chi này sẽ ghi nhận như nợ riêng của thành viên.",
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- FORM FIELDS -------------------
  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: type,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF5DBDD4), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMemberDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Người trả",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButton<int>(
            value: _selectedMemberId,
            underline: const SizedBox(),
            isExpanded: true,
            hint: Text(
              _members.isEmpty ? 'Đang tải thành viên...' : 'Chọn thành viên',
            ),
            items: _members
                .map(
                  (e) => DropdownMenuItem<int>(
                    value: e.memberId,
                    child: Text(
                      e.memberName.isNotEmpty
                          ? e.memberName
                          : 'Thành viên ${e.memberId}',
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _selectedMemberId = value),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Ngày chi",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),

        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null) setState(() => _selectedDate = picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                  style: const TextStyle(fontSize: 14),
                ),
                const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF5DBDD4),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- SPLIT METHODS -------------------
  Widget _buildSplitMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Kiểu chia tiền"),
        const SizedBox(height: 10),

        Row(
          children: [
            _buildSplitButton("Chia đều", 0, Icons.grid_view),
            const SizedBox(width: 8),
            _buildSplitButton("Theo tỷ lệ", 1, Icons.pie_chart),
            const SizedBox(width: 8),
            _buildSplitButton("Theo từng người", 2, Icons.group),
          ],
        ),
      ],
    );
  }

  Widget _buildSplitButton(String label, int index, IconData icon) {
    final active = _selectedSplit == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedSplit = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF5DBDD4) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active ? const Color(0xFF5DBDD4) : Colors.grey.shade400,
              width: 1.4,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 22,
                color: active ? Colors.white : Colors.black87,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- BUTTONS -------------------
  Widget _buildMainButton() {
    final String buttonText = _submitting
        ? "Đang lưu..."
        : _selectedType == 0
        ? "Lưu chi tiêu"
        : "Lưu chi tiêu phát sinh";

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitting ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7DD4E8),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          buttonText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return Center(
      child: TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text(
          "Huỷ",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
