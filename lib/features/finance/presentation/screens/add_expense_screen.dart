import 'package:flutter/material.dart';
import '../../data/models/finance_model.dart';
import '../../data/service/finance_service.dart';

class AddExpenseScreen extends StatefulWidget {
  final int initialType; // 0 = Chi từ quỹ, 1 = Chi phát sinh
  final FundSummary? summary;
  final int houseId;
  final AdHocExpense? adHocExpense;
  final bool viewOnly;

  const AddExpenseScreen({
    Key? key,
    this.initialType = 0,
    this.summary,
    this.houseId = 1,
    this.adHocExpense,
    this.viewOnly = false,
  }) : super(key: key);

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  late int _selectedType; // 0 = Chi từ quỹ, 1 = Chi phát sinh
  int _selectedSplit = 0; // 0=đều, 1=theo từng người

  DateTime _selectedDate = DateTime.now();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _amount = TextEditingController();
  List<MemberStatus> _members = [];
  int? _selectedMemberId;
  bool _submitting = false;
  late final FinanceService _service;
  // controllers cho chia custom theo người
  final List<TextEditingController> _amountCtrls = [];
  bool get _isEditingAdHoc => widget.adHocExpense != null && _selectedType == 1;
  bool get _isViewOnly => widget.viewOnly;

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

    if (widget.adHocExpense != null) {
      final a = widget.adHocExpense!;
      _selectedType = 1;
      _title.text = a.title;
      _amount.text = a.totalAmount.toStringAsFixed(0);
      _selectedDate = a.expenseDate;
      _selectedMemberId = a.paidBy;
      // map split method string to index (only equal/custom)
      _selectedSplit = a.splitMethod == 'custom' ? 1 : 0;
    }

    _initSplitInputsFromMembers();
    _prefillSplitFromExpense();
    _enforcePayerZeroInCustom();
  }

  void _initSplitInputsFromMembers() {
    _amountCtrls.clear();
    for (final _ in _members) {
      _amountCtrls.add(TextEditingController(text: ''));
    }
  }

  void _prefillSplitFromExpense() {
    final ad = widget.adHocExpense;
    if (ad == null) return;
    for (int i = 0; i < _members.length; i++) {
      final m = _members[i];
      final split = ad.splits.firstWhere(
        (s) => s.memberId == m.memberId,
        orElse: () => AdHocSplit(
          memberId: m.memberId,
          memberName: m.memberName,
          amountOwed: 0,
          sharePercentage: 0,
        ),
      );
      _amountCtrls[i].text = split.amountOwed.toStringAsFixed(0);
    }
  }

  void _enforcePayerZeroInCustom() {
    if (_selectedMemberId == null || _selectedSplit != 1) return;
    for (int i = 0; i < _members.length; i++) {
      if (_members[i].memberId == _selectedMemberId) {
        _amountCtrls[i].text = '0';
      }
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
      _initSplitInputsFromMembers();
      _prefillSplitFromExpense();
      _enforcePayerZeroInCustom();
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

      List<Map<String, dynamic>> splits;

      if (_selectedSplit == 0) {
        final participants = members
            .where((m) => m.memberId != _selectedMemberId)
            .toList();
        if (participants.isEmpty) {
          if (!mounted) return;
          setState(() => _submitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cần ít nhất một người khác để chia đều'),
            ),
          );
          return;
        }
        final equalShare = amount / participants.length;
        final sharePercent = 100 / participants.length;
        splits = members.map((m) {
          final isPayer = m.memberId == _selectedMemberId;
          final owed = isPayer ? 0 : equalShare;
          final pct = isPayer ? 0 : sharePercent;
          return {
            'memberId': m.memberId,
            'sharePercentage': double.parse(pct.toStringAsFixed(2)),
            'amountOwed': double.parse(owed.toStringAsFixed(2)),
          };
        }).toList();
      } else {
        // Theo từng người: nhập amountOwed trực tiếp, validate tổng = amount.
        double totalAmount = 0;
        splits = [];
        while (_amountCtrls.length < members.length) {
          _amountCtrls.add(TextEditingController(text: '0'));
        }
        for (int i = 0; i < members.length; i++) {
          final isPayer = members[i].memberId == _selectedMemberId;
          final owed = isPayer ? 0 : double.tryParse(_amountCtrls[i].text) ?? 0;
          totalAmount += owed;
          final pct = amount == 0 ? 0 : (owed / amount) * 100;
          splits.add({
            'memberId': members[i].memberId,
            'sharePercentage': double.parse(pct.toStringAsFixed(2)),
            'amountOwed': double.parse(owed.toStringAsFixed(2)),
          });
        }
        if ((totalAmount - amount).abs() > 0.01) {
          if (!mounted) return;
          setState(() => _submitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tổng tiền chia phải bằng số tiền')),
          );
          return;
        }
      }
      if (_isEditingAdHoc && widget.adHocExpense != null) {
        ok = await _service.updateAdHocExpense(
          expenseId: widget.adHocExpense!.id,
          paidBy: _selectedMemberId!,
          title: title,
          description: null,
          totalAmount: amount,
          expenseDate: _selectedDate,
          splitMethod: _selectedSplit == 0 ? 'equal' : 'custom',
          splits: splits,
        );
      } else {
        ok = await _service.addAdHocExpense(
          paidBy: _selectedMemberId!,
          title: title,
          description: null,
          totalAmount: amount,
          expenseDate: _selectedDate,
          splitMethod: _selectedSplit == 0 ? 'equal' : 'custom',
          splits: splits,
        );
      }
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
                  if (!_isViewOnly) _buildMainButton(),
                  if (!_isViewOnly) const SizedBox(height: 14),
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
            Text(
              _isViewOnly ? "Xem chi tiêu phát sinh" : "Thêm chi tiêu mới",
              style: const TextStyle(
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
      onTap: _isViewOnly ? null : () => setState(() => _selectedType = index),
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
          readOnly: _isViewOnly,
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
            onChanged: _isViewOnly
                ? null
                : (value) => setState(() {
                    _selectedMemberId = value;
                    _enforcePayerZeroInCustom();
                  }),
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
          onTap: _isViewOnly
              ? null
              : () async {
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
            _buildSplitButton("Theo từng người", 1, Icons.group),
          ],
        ),

        const SizedBox(height: 8),
        const Text(
          'Người trả không bị tính phần nợ.',
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),

        const SizedBox(height: 12),
        if (_selectedSplit == 1) _buildCustomAmountInputs(),
      ],
    );
  }

  Widget _buildCustomAmountInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Nhập số tiền từng người chịu (tổng = số tiền chi)",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...List.generate(_members.length, (i) {
          final m = _members[i];
          final isPayer = m.memberId == _selectedMemberId;
          if (isPayer &&
              (_amountCtrls[i].text.isEmpty || _amountCtrls[i].text != '0')) {
            _amountCtrls[i].text = '0';
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    m.memberName.isNotEmpty
                        ? m.memberName
                        : 'Thành viên ${m.memberId}',
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _amountCtrls[i],
                    keyboardType: TextInputType.number,
                    readOnly: _isViewOnly || isPayer,
                    decoration: InputDecoration(
                      isDense: true,
                      suffixText: isPayer ? '' : 'đ',
                      hintText: isPayer
                          ? 'Người trả không chịu'
                          : (_isViewOnly ? null : null),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSplitButton(String label, int index, IconData icon) {
    final active = _selectedSplit == index;

    return Expanded(
      child: GestureDetector(
        onTap: _isViewOnly
            ? null
            : () => setState(() {
                _selectedSplit = index;
                _enforcePayerZeroInCustom();
              }),
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
        child: Text(
          _isViewOnly ? "Quay lại" : "Huỷ",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
