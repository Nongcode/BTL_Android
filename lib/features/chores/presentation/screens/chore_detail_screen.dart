import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Hãy đảm bảo đường dẫn import dưới đây đúng với project của bạn
import '../../data/models/chore_model.dart';
import '../../data/service/chore_service.dart';

class ChoreDetailScreen extends StatefulWidget {
  final Chore chore;

  const ChoreDetailScreen({super.key, required this.chore});

  @override
  State<ChoreDetailScreen> createState() => _ChoreDetailScreenState();
}

class _ChoreDetailScreenState extends State<ChoreDetailScreen> {

  final ChoreService _choreService = ChoreService();
  bool _isLoading = false;
  
  // Controller
  late TextEditingController _titleController;
  late TextEditingController _assigneeController;
  late TextEditingController _pointsController;
  late TextEditingController _noteController;
  late TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.chore.title);
    _assigneeController = TextEditingController(text: widget.chore.assigneeName);
    _pointsController = TextEditingController(text: widget.chore.points.toString());
    _noteController = TextEditingController(text: widget.chore.description ?? "");

    // SỬA: Thêm .toLocal() để chuyển UTC -> Giờ địa phương
    String formattedDate = widget.chore.dueDate != null
        ? DateFormat('dd/MM/yyyy').format(widget.chore.dueDate!.toLocal())
        : "Không có hạn";
    _dateController = TextEditingController(text: formattedDate);
  }

  Future<void> _handleUpdate() async {
    setState(() => _isLoading = true);

    // SỬA: Parse lại ngày từ chuỗi hiển thị
    DateTime? newDueDate;
    try {
      if (_dateController.text.isNotEmpty && _dateController.text != "Không có hạn") {
        newDueDate = DateFormat('dd/MM/yyyy').parse(_dateController.text);
      }
    } catch (e) {
      // Fallback nếu lỗi parse: dùng ngày cũ
      newDueDate = widget.chore.dueDate;
    }

    final updatedChore = Chore(
      id: widget.chore.id,
      title: _titleController.text,
      assigneeName: _assigneeController.text,
      points: int.tryParse(_pointsController.text) ?? 0,
      description: _noteController.text,
      
      // SỬA: Sử dụng ngày mới đã parse
      dueDate: newDueDate,
      
      assigneeId: widget.chore.assigneeId, 
      templateId: widget.chore.templateId,
      isDone: widget.chore.isDone,
      iconAsset: widget.chore.iconAsset,
      iconType: widget.chore.iconType,
      isRotating: widget.chore.isRotating,
      frequency: widget.chore.frequency,
      rotationOrder: widget.chore.rotationOrder,
    );

    final templateIdToUpdate = widget.chore.templateId;
    
    // Gọi API
    final success = await _choreService.updateTemplate(templateIdToUpdate.toString(), updatedChore);

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        Navigator.pop(context, true); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thành công!'), backgroundColor: Colors.green),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi cập nhật!'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleDelete() async {
    Navigator.pop(context); // Đóng dialog

    setState(() => _isLoading = true);

    final templateIdToDelete = widget.chore.templateId;

    if (templateIdToDelete == null) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi: Không tìm thấy ID mẫu công việc!'), backgroundColor: Colors.red),
        );
        return;
    }

    final success = await _choreService.deleteTemplate(templateIdToDelete.toString());

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        Navigator.pop(context, true); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa công việc!'), backgroundColor: Colors.green),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi xóa công việc!'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _assigneeController.dispose();
    _pointsController.dispose();
    _noteController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // Hàm chọn ngày (DatePicker)
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.chore.dueDate?.toLocal() ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      // locale: const Locale('vi', 'VN'), // Bỏ comment nếu đã config localization
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = widget.chore.isDone ? Colors.green : Colors.orange;
    final statusText = widget.chore.isDone ? "Đã hoàn thành" : "Chưa hoàn thành";
    final statusIcon = widget.chore.isDone ? Icons.check_circle : Icons.pending;

    const primaryColor = Color(0xFF40C4C6);
    const backgroundColor = Color(0xFFF5F5F5);

    String jobType = widget.chore.isRotating 
        ? "Việc chung (Xoay vòng)" 
        : "Việc cá nhân (Cố định)";
    
    IconData jobTypeIcon = widget.chore.isRotating 
        ? Icons.sync 
        : Icons.person_pin;    
    
    if (_isLoading) {
        return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator(color: Color(0xFF40C4C6))),
        );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Chi tiết công việc & Chỉnh sửa", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Ảnh minh họa
                    Container(
                      height: 100,
                      width: 100,
                      padding: const EdgeInsets.all(15),
                      decoration: const BoxDecoration(
                        color: backgroundColor,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(widget.chore.iconAsset, fit: BoxFit.contain),
                    ),
                    const SizedBox(height: 20),

                    // Tên công việc
                    TextField(
                      controller: _titleController,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                      decoration: const InputDecoration(border: InputBorder.none, hintText: "Tên công việc"),
                    ),

                    const SizedBox(height: 10),

                    // Trạng thái
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 18, color: statusColor),
                          const SizedBox(width: 8),
                          Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Form chi tiết
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          _buildEditableRow(Icons.person, "Người thực hiện", _assigneeController),
                          const Divider(height: 30),

                          _buildReadOnlyRow(jobTypeIcon, "Loại công việc", jobType, textColor: Colors.blue[700]),
                          const Divider(height: 30),

                          _buildEditableRow(Icons.stars_rounded, "Điểm thưởng", _pointsController, isNumber: true, valueColor: Colors.red),
                          const Divider(height: 30),
                          
                          // SỬA: Thêm GestureDetector để chọn ngày
                          GestureDetector(
                            onTap: () => _selectDate(context),
                            child: AbsorbPointer( // Chặn bàn phím hiện lên
                                child: _buildEditableRow(Icons.calendar_today, "Hạn hoàn thành", _dateController),
                            ),
                          ),
                          const Divider(height: 30),
                          
                          _buildEditableRow(Icons.notes, "Ghi chú", _noteController),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Nút bấm
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showDeleteConfirmDialog(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red),
                          SizedBox(width: 8),
                          Text("Xóa", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleUpdate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_as_outlined, color: Colors.white),
                          SizedBox(width: 8),
                          Text("Lưu lại", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableRow(IconData icon, String label, TextEditingController controller, {bool isNumber = false, Color valueColor = Colors.black87}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.grey, size: 22),
        const SizedBox(width: 15),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 15)),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            textAlign: TextAlign.end,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: valueColor),
            decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.zero, border: InputBorder.none, hintText: "Nhập..."),
          ),
        ),
        const SizedBox(width: 5),
        const Icon(Icons.edit, size: 14, color: Colors.grey),
      ],
    );
  }

  Widget _buildReadOnlyRow(IconData icon, String label, String value, {Color? textColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.grey, size: 22),
        const SizedBox(width: 15),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 15)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor ?? Colors.black87),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text("Bạn có chắc chắn muốn xóa công việc '${widget.chore.title}' không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          TextButton(
            onPressed: _handleDelete,
            child: const Text("Xóa", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}