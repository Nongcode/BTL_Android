class Chore {
  final String id;
  final int? templateId;
  final String title;
  final String? description;
  
  final String assigneeName;
  final int? assigneeId;

  bool isDone;
  final String status;       
  final String iconType;     
  final String iconAsset;    

  final int points;          
  final int bonusPoints;     
  final int penaltyPoints;   
  
  final bool isRotating;     
  final List<int> rotationOrder; 
  final String frequency;    
  
  final DateTime? dueDate;

  Chore({
    required this.id,
    this.templateId,
    required this.title,
    this.description,
    required this.assigneeName,
    this.assigneeId,
    required this.isDone,
    this.status = 'PENDING',
    this.iconType = 'broom',
    required this.iconAsset,
    this.points = 0,
    this.bonusPoints = 0,
    this.penaltyPoints = 0,
    this.isRotating = false,
    this.rotationOrder = const [],
    this.frequency = 'daily',
    this.dueDate,
  });

  // --- 1. FROM JSON (Server -> Flutter) ---
  factory Chore.fromJson(Map<String, dynamic> json) {
    
    // Helper lấy đường dẫn ảnh từ type
    String getIconPath(String? type) {
      if (type == null || type.isEmpty) return 'assets/images/icons/broom.png';
      switch (type) {
        case 'cooking': return 'assets/images/icons/cooking.png';
        case 'trash': return 'assets/images/icons/trash.png';
        case 'laundry': return 'assets/images/icons/laundry.png';
        case 'card': return 'assets/images/icons/card.png';
        case 'water': return 'assets/images/icons/water.png';
        case 'wc': return 'assets/images/icons/wc.png';
        case 'repair': return 'assets/images/icons/repair.png'; // Bổ sung cho đủ
        default: return 'assets/images/icons/broom.png';
      }
    }

    return Chore(
      id: json['id'].toString(),
      templateId: json['chore_template_id'] ?? json['template_id'],
      title: json['title'] ?? 'Công việc',
      description: json['description'], 
      
      assigneeName: json['assignee_name'] ?? 'Chưa giao', 
      assigneeId: json['assignee_id'], 

      status: json['status'] ?? 'PENDING',
      isDone: json['status'] == 'COMPLETED',
      
      iconType: json['icon_type'] ?? 'broom',
      iconAsset: getIconPath(json['icon_type']),
      
      points: json['base_points'] ?? 0,
      bonusPoints: json['bonus_points'] ?? 0,
      penaltyPoints: json['penalty_points'] ?? 0,

      isRotating: json['is_rotating'] ?? false,
      rotationOrder: json['rotation_order'] != null 
          ? List<int>.from(json['rotation_order']) 
          : [],
      frequency: json['frequency'] ?? 'daily',

      // --- [QUAN TRỌNG 1] SỬA LỖI LỆCH MÚI GIỜ ---
      // Thêm .toLocal() để chuyển giờ UTC về giờ Việt Nam ngay khi nhận dữ liệu
      dueDate: json['due_date'] != null 
          ? DateTime.parse(json['due_date']).toLocal() 
          : null,
    );
  }

  // --- 2. TO JSON (Flutter -> Server) ---
  Map<String, dynamic> toJson() {
    return {
      'chore_template_id': templateId,
      "title": title,
      "description": description,
      "base_points": points,
      "bonus_points": bonusPoints,
      "penalty_points": penaltyPoints,
      "icon_type": iconType, 
      "is_rotating": isRotating,
      "rotation_order": rotationOrder,
      "frequency": frequency,
      "assignee_id": assigneeId,
      
      // --- [QUAN TRỌNG 2] BỔ SUNG GỬI NGÀY THÁNG ---
      // Nếu không có dòng này, chỉnh sửa ngày xong sẽ không lưu được
      "due_date": dueDate?.toIso8601String(), 
    };
  }
}