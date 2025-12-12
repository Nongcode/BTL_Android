import 'package:flutter/material.dart';

class SplitDetailScreen extends StatefulWidget {
  final String title;
  final int amount;
  final String payer;
  final List<Map<String, dynamic>> members;

  /// 0 = Chia đều
  /// 1 = Theo tỷ lệ %
  /// 2 = Theo người tham gia
  final int splitType;

  /// Callback trả dữ liệu chia tiền
  final Function(Map<String, dynamic> result) onConfirm;

  const SplitDetailScreen({
    super.key,
    required this.title,
    required this.amount,
    required this.payer,
    required this.members,
    required this.splitType,
    required this.onConfirm,
  });

  @override
  State<SplitDetailScreen> createState() => _SplitDetailScreenState();
}

class _SplitDetailScreenState extends State<SplitDetailScreen> {
  // Dùng cho chia theo tỷ lệ
  late List<TextEditingController> percentControllers;

  // Dùng cho chọn người tham gia
  late List<bool> selectedMembers;

  @override
  void initState() {
    super.initState();

    percentControllers = List.generate(
      widget.members.length,
      (i) => TextEditingController(text: "0"),
    );

    selectedMembers = List.generate(
      widget.members.length,
      (i) => true,
    ); // mặc định ai cũng tham gia
  }

  @override
  Widget build(BuildContext context) {
    final equalShare = (widget.amount / widget.members.length).round();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FA),
      body: Column(
        children: [
          _buildHeader(context),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 14),
                  _buildBillCard(),
                  const SizedBox(height: 20),

                  const Text(
                    "Thiết lập số tiền mỗi thành viên phải trả.",
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 14),

                  _buildSplitUI(equalShare),

                  const SizedBox(height: 30),
                  _buildConfirmButton(),
                  const SizedBox(height: 12),
                  _buildCancelButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========================= HIỂN THỊ UI THEO KIỂU CHIA =========================

  Widget _buildSplitUI(int equalShare) {
    switch (widget.splitType) {
      case 0:
        return _uiEqual(equalShare);

      case 1:
        return _uiPercentage();

      case 2:
        return _uiMemberSelection();

      default:
        return const Text("Lỗi kiểu chia tiền!");
    }
  }

  // ========================= UI CHIA ĐỀU =========================

  Widget _uiEqual(int share) {
    return Column(
      children: [
        ...widget.members.map(
          (m) => _buildMemberRow(
            name: m["name"],
            color: m["color"],
            amount: share,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          "Chia đều cho ${widget.members.length} thành viên • Mỗi người $share đ",
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black54,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  // ========================= UI CHIA THEO TỶ LỆ (%) =========================

  Widget _uiPercentage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Nhập phần trăm cho từng thành viên:"),

        const SizedBox(height: 10),

        ...List.generate(widget.members.length, (i) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2EEF0)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: widget.members[i]["color"].withOpacity(0.2),
                  child: Text(
                    widget.members[i]["name"][0],
                    style: TextStyle(
                      color: widget.members[i]["color"],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.members[i]["name"],
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(
                  width: 70,
                  child: TextField(
                    controller: percentControllers[i],
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "%",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
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

  // ========================= UI CHỌN NGƯỜI THAM GIA =========================

  Widget _uiMemberSelection() {
    return Column(
      children: [
        const Text("Chọn thành viên tham gia chi tiêu:"),
        const SizedBox(height: 10),
        ...List.generate(widget.members.length, (i) {
          return CheckboxListTile(
            title: Text(widget.members[i]["name"]),
            value: selectedMembers[i],
            onChanged: (v) {
              setState(() {
                selectedMembers[i] = v ?? false;
              });
            },
          );
        }),
      ],
    );
  }

  // ========================= NÚT XÁC NHẬN =========================

  Widget _buildConfirmButton() {
    return GestureDetector(
      onTap: () {
        List<Map<String, dynamic>> finalResult = [];

        if (widget.splitType == 0) {
          // Chia đều
          final share = (widget.amount / widget.members.length).round();
          finalResult = widget.members
              .map((m) => {"name": m["name"], "pay": share})
              .toList();
        }

        if (widget.splitType == 1) {
          // Chia theo % input
          for (int i = 0; i < widget.members.length; i++) {
            int pct = int.tryParse(percentControllers[i].text) ?? 0;
            int pay = (widget.amount * pct / 100).round();
            finalResult.add({"name": widget.members[i]["name"], "pay": pay});
          }
        }

        if (widget.splitType == 2) {
          // Chỉ chia cho người tham gia
          List<int> involved = [];
          for (int i = 0; i < selectedMembers.length; i++) {
            if (selectedMembers[i]) involved.add(i);
          }

          int share = (widget.amount / involved.length).round();

          for (int index in involved) {
            finalResult.add({
              "name": widget.members[index]["name"],
              "pay": share,
            });
          }
        }

        widget.onConfirm({
          "title": widget.title,
          "amount": widget.amount,
          "payer": widget.payer,
          "split": finalResult,
        });

        Navigator.pop(context);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF7DD4E8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            "Xác nhận chia tiền",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: const Center(
        child: Text(
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

  // ========================= HEADER =========================

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF5DBDD4), Color(0xFF7DD4E8)],
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Text(
              "Chia tiền chi tiết",
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

  // ========================= BILL CARD =========================

  Widget _buildBillCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4EDF2), width: 1),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${widget.amount} đ",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 6),
              _chip(
                widget.splitType == 0
                    ? "Chia đều"
                    : widget.splitType == 1
                    ? "Theo tỷ lệ"
                    : "Theo người",
              ),
            ],
          ),
          const Spacer(),
          Column(
            children: [
              const Text(
                "Người thanh toán",
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF8FB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.payer,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF5DBDD4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========================= COMPONENT CHIP =========================

  Widget _chip(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFF5DBDD4),
      borderRadius: BorderRadius.circular(40),
    ),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white, fontSize: 12),
    ),
  );

  // ========================= COMPONENT DÒNG THÀNH VIÊN =========================

  Widget _buildMemberRow({
    required String name,
    required Color color,
    required int amount,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2EEF0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withOpacity(0.2),
            child: Text(
              name[0],
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(
            "$amount đ",
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
