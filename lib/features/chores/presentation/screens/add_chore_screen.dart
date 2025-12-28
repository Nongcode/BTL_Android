import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../../core/constants/api_urls.dart';
import '../../data/models/chore_model.dart';

class DropdownItem {
  final String id;
  final String label;
  final String? image;
  DropdownItem({required this.id, required this.label, this.image});
}

class AddChoreScreen extends StatefulWidget {
  const AddChoreScreen({super.key});

  @override
  State<AddChoreScreen> createState() => _AddChoreScreenState();
}

class _AddChoreScreenState extends State<AddChoreScreen> {
  // Controller
  final _titleController = TextEditingController();
  final _pointsController = TextEditingController();
  final _bonusController = TextEditingController();
  final _penaltyController = TextEditingController();
  final _dateController = TextEditingController();
  final _noteController = TextEditingController();
  
  // Data State
  List<DropdownItem> _apiUsers = [];
  List<DropdownItem> _apiIcons = [];
  bool _isLoadingData = true;

  // Selection State
  String? _selectedAssigneeId; 
  String? _selectedIconCode;
  String _selectedWorkType = 'daily'; 
  DateTime? _selectedDate;

  // Rotation State
  List<DropdownItem> _rotationList = [];

  final Map<String, String> _workTypes = {
    'daily': 'Hàng ngày (Xoay vòng)',
    'weekly': 'Hàng tuần (Xoay vòng)',
    'adhoc': 'Đột xuất (Một lần)',
  };

  @override
  void initState() {
    super.initState();
    _initLocale();
    _loadMetaData();
    
    _pointsController.text = "2";
    _bonusController.text = "1";
    _penaltyController.text = "2";
    
    // Mặc định là daily nên set text ngày là Tự động
    _dateController.text = "Tự động theo tần suất";
  }

  void _initLocale() async {
    await initializeDateFormatting('vi_VN');
    Intl.defaultLocale = 'vi_VN';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _pointsController.dispose();
    _bonusController.dispose();
    _penaltyController.dispose();
    _dateController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadMetaData() async {
    try {
      final userRes = await http.get(Uri.parse('${ApiUrls.baseUrl}/users'));
      final iconRes = await http.get(Uri.parse('${ApiUrls.baseUrl}/chores/static/icons')); 

      if (userRes.statusCode == 200) {
        final userBody = jsonDecode(userRes.body);
        final loadedUsers = (userBody['data'] as List).map((u) => DropdownItem(
          id: u['id'].toString(),
          label: u['username'],
        )).toList();

        List<DropdownItem> loadedIcons = [];
        if (iconRes.statusCode == 200) {
           final iconBody = jsonDecode(iconRes.body);
           loadedIcons = (iconBody['data'] as List).map((i) => DropdownItem(
            id: i['code'],
            label: i['name'],
            image: i['url'],
          )).toList();
        }

        if (mounted) {
          setState(() {
            _apiUsers = loadedUsers;
            _apiIcons = loadedIcons;
            if (_apiUsers.isNotEmpty) {
              _selectedAssigneeId = _apiUsers[0].id;
              _generateRandomRotation(); 
            }
            if (_apiIcons.isNotEmpty) _selectedIconCode = _apiIcons[0].id;
            _isLoadingData = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _apiUsers = [DropdownItem(id: '1', label: 'Long'), DropdownItem(id: '2', label: 'Minh')];
          _apiIcons = [DropdownItem(id: 'broom', label: 'Quét', image: 'assets/images/icons/broom.png')];
          _selectedAssigneeId = '1';
          _selectedIconCode = 'broom';
          _generateRandomRotation();
          _isLoadingData = false;
        });
      }
    }
  }

  void _generateRandomRotation() {
    if (_apiUsers.isEmpty) return;
    List<DropdownItem> shuffled = List.from(_apiUsers)..shuffle(Random());
    setState(() {
      _rotationList = shuffled;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    // [LOGIC MỚI] Nếu không phải đột xuất thì không cho chọn ngày
    if (_selectedWorkType != 'adhoc') return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF40C4C6), onPrimary: Colors.white, onSurface: Colors.black),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy', 'vi_VN').format(picked);
      });
    }
  }

  // --- Cập nhật Widget TextField để hỗ trợ trạng thái Disabled ---
  Widget _buildTextField({
    required TextEditingController controller, 
    required String label, 
    IconData? icon, 
    TextInputType type = TextInputType.text, 
    int maxLines = 1, 
    bool readOnly = false, 
    bool enabled = true, // [MỚI] Thêm thuộc tính enabled
    VoidCallback? onTap
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        // [MỚI] Đổi màu nền xám nếu bị disable
        color: enabled ? Colors.white : Colors.grey.shade200, 
        borderRadius: BorderRadius.circular(15), 
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 3))]
      ),
      child: TextField(
        controller: controller, 
        keyboardType: type, 
        maxLines: maxLines, 
        readOnly: readOnly, 
        enabled: enabled, // [MỚI] Disable input
        onTap: onTap,
        style: TextStyle(color: enabled ? Colors.black : Colors.grey), // Làm mờ text
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, color: enabled ? const Color(0xFF40C4C6) : Colors.grey) : null, 
          labelText: label, 
          labelStyle: const TextStyle(fontSize: 13, color: Colors.grey), 
          border: InputBorder.none, 
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)
        ),
      ),
    );
  }

  Widget _buildDynamicDropdown({required String? value, required String label, required List<DropdownMenuItem<String>> items, required Function(String?) onChanged, required IconData icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 3))]),
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(alignedDropdown: true, child: DropdownButton<String>(value: value, isExpanded: true, hint: Row(children: [Icon(icon, color: const Color(0xFF40C4C6), size: 24), const SizedBox(width: 12), Text(label, style: const TextStyle(color: Colors.black54))]), items: items, onChanged: onChanged, icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey))),
      ),
    );
  }

  Widget _buildRotationDisplay() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.blue.shade100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Thứ tự thực hiện:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              InkWell(
                onTap: _generateRandomRotation,
                child: const Row(children: [Icon(Icons.shuffle, size: 16, color: Colors.blue), SizedBox(width: 5), Text("Trộn lại", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))]),
              )
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _rotationList.asMap().entries.map((entry) {
              int idx = entry.key;
              DropdownItem user = entry.value;
              return Chip(
                avatar: CircleAvatar(backgroundColor: Colors.blue, child: Text("${idx + 1}", style: const TextStyle(fontSize: 10, color: Colors.white))),
                label: Text(user.label),
                backgroundColor: Colors.white,
                elevation: 1,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _saveChore() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập tên công việc"), backgroundColor: Colors.red));
      return;
    }
    
    bool isAdhoc = _selectedWorkType == 'adhoc';

    // [VALIDATE MỚI] Nếu là Đột xuất, bắt buộc phải chọn ngày
    if (isAdhoc && _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Công việc đột xuất cần có hạn hoàn thành"), backgroundColor: Colors.red));
      return;
    }
    
    bool isRotating = !isAdhoc;
    String frequency = _selectedWorkType == 'weekly' ? 'weekly' : (_selectedWorkType == 'daily' ? 'daily' : 'none');
    
    String assigneeName;
    int? assigneeId;
    List<int> rotationOrder = [];

    if (isRotating) {
      rotationOrder = _rotationList.map((u) => int.tryParse(u.id) ?? 0).toList();
      assigneeId = rotationOrder.isNotEmpty ? rotationOrder[0] : 0;
      assigneeName = _rotationList.isNotEmpty ? _rotationList[0].label : 'Chưa xác định';
    } else {
      assigneeId = int.tryParse(_selectedAssigneeId ?? '0');
      try {
         assigneeName = _apiUsers.firstWhere((u) => u.id == _selectedAssigneeId).label;
      } catch (e) {
         assigneeName = 'Không xác định';
      }
    }

    final newChore = Chore(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      description: _noteController.text,
      assigneeName: assigneeName,
      assigneeId: assigneeId,
      points: int.tryParse(_pointsController.text) ?? 0,
      bonusPoints: int.tryParse(_bonusController.text) ?? 0,
      penaltyPoints: int.tryParse(_penaltyController.text) ?? 0,
      iconType: _selectedIconCode ?? 'broom',
      iconAsset: 'assets/images/icons/${_selectedIconCode ?? 'broom'}.png',
      isRotating: isRotating,
      rotationOrder: rotationOrder,
      frequency: frequency,
      // [LOGIC MỚI] Nếu xoay vòng thì dueDate là null (backend tự sinh), nếu đột xuất thì lấy ngày chọn
      dueDate: isAdhoc ? _selectedDate : null,
      isDone: false,
      status: 'PENDING'
    );

    Navigator.pop(context, newChore);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF40C4C6))));

    bool isAdhoc = _selectedWorkType == 'adhoc';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(title: const Text("Thêm công việc", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)), centerTitle: true, backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87), onPressed: () => Navigator.pop(context))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. LOẠI CÔNG VIỆC
            _buildDynamicDropdown(
              value: _selectedWorkType,
              label: "Loại công việc",
              icon: Icons.repeat,
              items: _workTypes.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedWorkType = val!;
                  if (val == 'adhoc') {
                    // Nếu chuyển sang Đột xuất -> Xóa text tự động, yêu cầu chọn ngày
                    _dateController.clear();
                    _selectedDate = null;
                  } else {
                    // Nếu chuyển sang Xoay vòng -> Set text Tự động, disable ngày
                    _dateController.text = "Tự động theo tần suất";
                    _selectedDate = null;
                    _generateRandomRotation();
                  }
                });
              },
            ),

            // 2. TÊN CÔNG VIỆC
            _buildTextField(controller: _titleController, label: "Tên công việc", icon: Icons.task_alt),

            // 3. PHÂN CÔNG
            if (isAdhoc) 
              _buildDynamicDropdown(
                value: _selectedAssigneeId,
                label: "Người thực hiện",
                icon: Icons.person_outline,
                items: _apiUsers.map((e) => DropdownMenuItem(value: e.id, child: Text(e.label))).toList(),
                onChanged: (val) => setState(() => _selectedAssigneeId = val),
              )
            else 
              _buildRotationDisplay(),

            // 4. ĐIỂM SỐ
            Row(children: [
                Expanded(child: _buildTextField(controller: _pointsController, label: "Điểm", type: TextInputType.number)),
                const SizedBox(width: 10),
                Expanded(child: _buildTextField(controller: _bonusController, label: "Thưởng", type: TextInputType.number)),
                const SizedBox(width: 10),
                Expanded(child: _buildTextField(controller: _penaltyController, label: "Phạt", type: TextInputType.number)),
            ]),

            // 5. NGÀY & ICON
            Row(children: [
                Expanded(
                  flex: 3, 
                  // [LOGIC UI] Disable ô ngày nếu không phải Adhoc
                  child: _buildTextField(
                    controller: _dateController, 
                    label: "Hạn chót", 
                    icon: Icons.calendar_today, 
                    readOnly: true, 
                    enabled: isAdhoc, // Disable nếu không phải đột xuất
                    onTap: () => _selectDate(context)
                  )
                ),
                const SizedBox(width: 15),
                Expanded(flex: 2, child: _buildDynamicDropdown(value: _selectedIconCode, label: "Icon", icon: Icons.image_outlined, items: _apiIcons.map((e) => DropdownMenuItem(value: e.id, child: Row(children: [Image.asset(e.image ?? 'assets/images/icons/broom.png', width: 24, errorBuilder: (c,o,s) => const Icon(Icons.image)), const SizedBox(width: 5), Text(e.label, style: const TextStyle(fontSize: 12))]))).toList(), onChanged: (val) => setState(() => _selectedIconCode = val))),
            ]),

            _buildTextField(controller: _noteController, label: "Ghi chú...", icon: Icons.edit_note, maxLines: 3),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: _saveChore, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF40C4C6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 5), child: const Text("LƯU CÔNG VIỆC", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)))),
          ],
        ),
      ),
    );
  }
}