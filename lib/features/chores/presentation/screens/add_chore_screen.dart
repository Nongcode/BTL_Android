import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../../core/constants/api_urls.dart';
import '../../data/models/chore_model.dart';

// Model phụ để hứng dữ liệu User và Icon từ API cho Dropdown
class DropdownItem {
  final String id;
  final String label;
  final String? image; // Dùng cho icon
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
  
  // State dữ liệu động (Lấy từ API)
  List<DropdownItem> _apiUsers = [];
  List<DropdownItem> _apiIcons = [];
  bool _isLoadingData = true;

  // Biến lựa chọn
  String? _selectedAssigneeId; // Lưu ID user
  String? _selectedIconCode;   // Lưu code icon
  String _selectedWorkType = 'daily'; 
  DateTime? _selectedDate;

  // Map loại công việc
  final Map<String, String> _workTypes = {
    'daily': 'Hàng ngày (Xoay vòng)',
    'weekly': 'Hàng tuần (Xoay vòng)',
    'adhoc': 'Đột xuất (Một lần)',
  };

  @override
  void initState() {
    super.initState();
    _initLocale();
    _loadMetaData(); // Gọi API lấy dữ liệu
    
    // Default values
    _pointsController.text = "2";
    _bonusController.text = "1";
    _penaltyController.text = "2";
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

  // --- GỌI API LẤY USER VÀ ICON ---
  Future<void> _loadMetaData() async {
    try {
      // Gọi API Users và Icons
      final userRes = await http.get(Uri.parse('${ApiUrls.baseUrl}/users'));
      
      // Lưu ý: Nếu chưa có API icon, bạn có thể comment dòng iconRes này lại và dùng list cứng
      final iconRes = await http.get(Uri.parse('${ApiUrls.baseUrl}/chores/static/icons')); 

      if (userRes.statusCode == 200) {
        final userBody = jsonDecode(userRes.body);
        
        // Parse Users
        final loadedUsers = (userBody['data'] as List).map((u) => DropdownItem(
          id: u['id'].toString(),
          label: u['username'],
        )).toList();

        // Parse Icons (Nếu API icon chưa sẵn sàng, dùng list giả ở dưới catch)
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
            
            // Set mặc định
            if (_apiUsers.isNotEmpty) _selectedAssigneeId = _apiUsers[0].id;
            if (_apiIcons.isNotEmpty) _selectedIconCode = _apiIcons[0].id;
            
            _isLoadingData = false;
          });
        }
      }
    } catch (e) {
      print("Lỗi tải metadata (Dùng dữ liệu giả tạm thời): $e");
      // Fallback data nếu API lỗi hoặc chưa chạy
      if (mounted) {
        setState(() {
          _apiUsers = [
            DropdownItem(id: '1', label: 'Long (Offline)'),
            DropdownItem(id: '2', label: 'Minh (Offline)'),
          ];
          _apiIcons = [
             DropdownItem(id: 'broom', label: 'Quét', image: 'assets/images/icons/broom.png'),
             DropdownItem(id: 'trash', label: 'Rác', image: 'assets/images/icons/trash.png'),
          ];
          _selectedAssigneeId = '1';
          _selectedIconCode = 'broom';
          _isLoadingData = false;
        });
      }
    }
  }

  // --- HÀM CHỌN NGÀY ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF40C4C6), 
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy', 'vi_VN').format(picked);
      });
    }
  }

  // --- HÀM TẠO TEXT FIELD (Bị thiếu ở bản trước) ---
  Widget _buildTextField({
    required TextEditingController controller, 
    required String label, 
    IconData? icon,
    TextInputType type = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 3)),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: type,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF40C4C6)) : null,
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  // --- HÀM TẠO DROPDOWN ĐỘNG ---
  Widget _buildDynamicDropdown({
    required String? value,
    required String label,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 3))],
      ),
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            hint: Row(
              children: [
                Icon(icon, color: const Color(0xFF40C4C6), size: 24),
                const SizedBox(width: 12),
                Text(label, style: const TextStyle(color: Colors.black54)),
              ],
            ),
            items: items,
            onChanged: onChanged,
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  void _saveChore() {
    if (_titleController.text.isEmpty) return;
    
    // XỬ LÝ LOGIC LOẠI CÔNG VIỆC
    bool isRotating = true;
    String frequency = 'daily';
    
    if (_selectedWorkType == 'weekly') {
      frequency = 'weekly';
      isRotating = true;
    } else if (_selectedWorkType == 'adhoc') {
      frequency = 'none'; 
      isRotating = false; 
    }

    // Helper lấy tên người được giao
    String assigneeName = 'Chưa giao';
    if (_apiUsers.isNotEmpty && _selectedAssigneeId != null) {
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
      assigneeId: int.tryParse(_selectedAssigneeId ?? '0'), 
      
      points: int.tryParse(_pointsController.text) ?? 0,
      bonusPoints: int.tryParse(_bonusController.text) ?? 0,
      penaltyPoints: int.tryParse(_penaltyController.text) ?? 0,
      
      iconType: _selectedIconCode ?? 'broom',
      iconAsset: 'assets/images/icons/${_selectedIconCode ?? 'broom'}.png', 
      
      isRotating: isRotating,
      frequency: frequency,
      dueDate: _selectedDate,
      
      isDone: false,
      status: 'PENDING'
    );

    Navigator.pop(context, newChore);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF40C4C6))));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Thêm công việc", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Input Tên
            _buildTextField(controller: _titleController, label: "Tên công việc", icon: Icons.task_alt),
            
            // Hàng Điểm
            Row(children: [
                Expanded(child: _buildTextField(controller: _pointsController, label: "Điểm", type: TextInputType.number)),
                const SizedBox(width: 10),
                Expanded(child: _buildTextField(controller: _bonusController, label: "Thưởng", type: TextInputType.number)),
                const SizedBox(width: 10),
                Expanded(child: _buildTextField(controller: _penaltyController, label: "Phạt", type: TextInputType.number)),
            ]),

            // Hàng Người & Loại việc (Dữ liệu động)
            Row(children: [
                Expanded(
                  child: _buildDynamicDropdown(
                    value: _selectedAssigneeId,
                    label: "Người làm",
                    icon: Icons.person_outline,
                    items: _apiUsers.map((e) => DropdownMenuItem(value: e.id, child: Text(e.label))).toList(),
                    onChanged: (val) => setState(() => _selectedAssigneeId = val),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildDynamicDropdown(
                    value: _selectedWorkType,
                    label: "Loại việc",
                    icon: Icons.repeat,
                    items: _workTypes.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, style: const TextStyle(fontSize: 12)))).toList(),
                    onChanged: (val) => setState(() => _selectedWorkType = val!),
                  ),
                ),
            ]),

            // Hàng Ngày & Icon (Dữ liệu động)
            Row(children: [
                Expanded(
                  flex: 3,
                  child: _buildTextField(controller: _dateController, label: "Hạn chót", icon: Icons.calendar_today, readOnly: true, onTap: () => _selectDate(context)),
                ),
                const SizedBox(width: 15),
                Expanded(
                  flex: 2,
                  child: _buildDynamicDropdown(
                    value: _selectedIconCode,
                    label: "Icon",
                    icon: Icons.image_outlined,
                    items: _apiIcons.map((e) => DropdownMenuItem(
                      value: e.id, 
                      child: Row(children: [
                         // Nếu là URL mạng thì dùng Image.network, đây tạm dùng asset local
                         // Bạn có thể sửa thành: e.image!.startsWith('http') ? Image.network(...) : Image.asset(...)
                         Image.asset(e.image ?? 'assets/images/icons/broom.png', width: 24, errorBuilder: (c,o,s) => const Icon(Icons.image)),
                         const SizedBox(width: 5),
                         Text(e.label, style: const TextStyle(fontSize: 12))
                      ])
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedIconCode = val),
                  ),
                ),
            ]),

            _buildTextField(controller: _noteController, label: "Ghi chú...", icon: Icons.edit_note, maxLines: 3),
            
            const SizedBox(height: 20),
            
            SizedBox(
              width: double.infinity, 
              height: 55, 
              child: ElevatedButton(
                onPressed: _saveChore, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF40C4C6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                ),
                child: const Text("LƯU CÔNG VIỆC", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))
              )
            ),
          ],
        ),
      ),
    );
  }
}