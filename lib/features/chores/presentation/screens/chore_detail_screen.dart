import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/chore_model.dart';

// 1. Chuyển thành StatefulWidget để quản lý việc nhập liệu
class ChoreDetailScreen extends StatefulWidget {
  final Chore chore; 

  const ChoreDetailScreen({super.key, required this.chore});

  @override
  State<ChoreDetailScreen> createState() => _ChoreDetailScreenState();
}

class _ChoreDetailScreenState extends State<ChoreDetailScreen> {
  // 2. Khởi tạo các Controller để quản lý text input
  late TextEditingController _titleController;
  late TextEditingController _assigneeController;
  late TextEditingController _pointsController;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    // Gán giá trị ban đầu từ dữ liệu được truyền vào
    _titleController = TextEditingController(text: widget.chore.title);
    _assigneeController = TextEditingController(text: widget.chore.assignee);
    _pointsController = TextEditingController(text: "2 điểm"); // Giả định điểm là 2
    _noteController = TextEditingController(text: "Không có ghi chú thêm");
  }

  @override
  void dispose() {
    // Giải phóng bộ nhớ khi thoát màn hình
    _titleController.dispose();
    _assigneeController.dispose();
    _pointsController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lấy màu sắc dựa trên trạng thái (dùng widget.chore vì status không sửa ở đây)
    final statusColor = widget.chore.isDone ? Colors.green : Colors.orange;
    final statusText = widget.chore.isDone ? "Đã hoàn thành" : "Chưa hoàn thành";
    final statusIcon = widget.chore.isDone ? Icons.check_circle : Icons.pending;

    return Scaffold(
      backgroundColor: Colors.white,
      // Khi bàn phím hiện lên, giao diện sẽ cuộn lên tránh bị che
      resizeToAvoidBottomInset: true, 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Chi tiết & Chỉnh sửa", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: false,
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
                    // --- Ảnh minh họa ---
                    Container(
                      height: 100,
                      width: 100,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(widget.chore.iconAsset, fit: BoxFit.contain),
                    ),
                    const SizedBox(height: 20),

                    // --- Input Tên công việc (To & Đậm) ---
                    TextField(
                      controller: _titleController,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                      decoration: const InputDecoration(
                        border: InputBorder.none, // Bỏ viền để nhìn tự nhiên như Text thường
                        hintText: "Nhập tên công việc",
                      ),
                    ),
                    
                    const SizedBox(height: 10),

                    // --- Badge Trạng thái (Không cho sửa ở đây) ---
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

                    // --- Form nhập liệu chi tiết ---
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          _buildEditableRow(Icons.person, "Người thực hiện", _assigneeController),
                          const Divider(height: 30),
                          _buildEditableRow(Icons.stars_rounded, "Điểm thưởng", _pointsController, isNumber: true, valueColor: Colors.red),
                          const Divider(height: 30),
                          // Ngày tháng tạm thời để tĩnh hoặc dùng DatePicker sau này
                          _buildEditableRow(Icons.calendar_today, "Hạn hoàn thành", TextEditingController(text: "25/12/2025")), 
                          const Divider(height: 30),
                          _buildEditableRow(Icons.notes, "Ghi chú", _noteController),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- Khu vực nút bấm ---
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
                  // Nút Xóa
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
                  
                  // Nút Cập nhật
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // 3. Logic Cập nhật: Tạo object mới từ dữ liệu trong Controller
                        final updatedChore = Chore(
                          id: widget.chore.id,
                          title: _titleController.text, // Lấy tên mới
                          assignee: _assigneeController.text, // Lấy người làm mới
                          isDone: widget.chore.isDone, // Giữ nguyên trạng thái
                          iconAsset: widget.chore.iconAsset, // Giữ nguyên icon
                        );

                        // 4. Trả dữ liệu về màn hình trước
                        Navigator.pop(context, updatedChore);
                        
                        // Hiển thị thông báo nhỏ
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã cập nhật thông tin công việc!'), backgroundColor: Colors.green),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
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

  // Widget hiển thị dòng có thể chỉnh sửa (TextField)
  Widget _buildEditableRow(IconData icon, String label, TextEditingController controller, {bool isNumber = false, Color valueColor = Colors.black87}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.grey, size: 22),
        const SizedBox(width: 15),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 15)),
        const SizedBox(width: 10),
        
        // Dùng Expanded chứa TextField để nhập liệu
        Expanded(
          child: TextField(
            controller: controller,
            textAlign: TextAlign.end,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: valueColor),
            decoration: const InputDecoration(
              isDense: true, // Thu gọn chiều cao
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none, // Không hiện viền ô nhập
              hintText: "Nhập...",
            ),
          ),
        ),
        // Thêm icon bút chì nhỏ để người dùng biết là sửa được
        const SizedBox(width: 5),
        const Icon(Icons.edit, size: 14, color: Colors.grey), 
      ],
    );
  }

  // Widget hiển thị dòng tĩnh (không sửa được, ví dụ Ngày tháng)
  Widget _buildStaticRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 22),
        const SizedBox(width: 15),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 15)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
            overflow: TextOverflow.visible,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tắt popup
              Navigator.pop(context, "DELETE"); // Trả về tín hiệu xóa
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}