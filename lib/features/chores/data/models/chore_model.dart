class Chore {
  final String id;
  final String title;
  final String? description; // <--- Trường mới bị thiếu
  
  final String assigneeName; // <--- Trường mới (Thay cho 'assignee' cũ)
  final int? assigneeId;     // <--- Trường mới

  bool isDone;
  final String status;       
  final String iconType;     
  final String iconAsset;    

  final int points;          
  final int bonusPoints;     // <--- Trường mới
  final int penaltyPoints;   // <--- Trường mới
  
  final bool isRotating;     
  final List<int> rotationOrder; 
  final String frequency;    
  
  final DateTime? dueDate;

  Chore({
    required this.id,
    required this.title,
    this.description,
    required this.assigneeName, // Đổi tên tham số từ assignee thành assigneeName
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
      // Nếu type rỗng hoặc null, trả về chổi mặc định
      if (type == null || type.isEmpty) return 'assets/images/icons/broom.png';
      
      // Map các loại icon
      switch (type) {
        case 'cooking': return 'assets/images/icons/cooking.png';
        case 'trash': return 'assets/images/icons/trash.png';
        case 'laundry': return 'assets/images/icons/laundry.png';
        case 'grocery': return 'assets/images/icons/grocery.png';
        case 'water': return 'assets/images/icons/water.png';
        case 'card': return 'assets/images/icons/card.png';
        default: return 'assets/images/icons/broom.png';
      }
    }

    return Chore(
      id: json['id'].toString(),
      title: json['title'] ?? 'Công việc',
      description: json['description'], // Map description
      
      // Ưu tiên lấy assignee_name từ server, nếu không có thì ghi 'Chưa giao'
      assigneeName: json['assignee_name'] ?? 'Chưa giao', 
      assigneeId: json['assignee_id'], 

      // Map trạng thái
      status: json['status'] ?? 'PENDING',
      isDone: json['status'] == 'COMPLETED',
      
      // Map Icon
      iconType: json['icon_type'] ?? 'broom',
      iconAsset: getIconPath(json['icon_type']),
      
      // Map điểm số
      points: json['base_points'] ?? 0,
      bonusPoints: json['bonus_points'] ?? 0,
      penaltyPoints: json['penalty_points'] ?? 0,

      // Map cấu hình xoay vòng
      isRotating: json['is_rotating'] ?? false,
      rotationOrder: json['rotation_order'] != null 
          ? List<int>.from(json['rotation_order']) 
          : [],
      frequency: json['frequency'] ?? 'daily',

      // Map ngày tháng
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
    );
  }

  // --- 2. TO JSON (Flutter -> Server) ---
  Map<String, dynamic> toJson() {
    return {
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
      // "assignee_name": assigneeName, // Thường server không cần cái này khi gửi lên, nhưng nếu cần thì mở ra
    };
  }
}