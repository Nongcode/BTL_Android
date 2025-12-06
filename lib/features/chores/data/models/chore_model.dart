class Chore {
  final String id;
  final String title;    // Tên việc (VD: Quét nhà)
  final String assignee; // Người được giao (VD: Minh)
  final String iconAsset;
  bool isDone;           // Trạng thái: true (Hoàn thành) / false (Chưa làm)

  Chore({
    required this.id,
    required this.title,
    required this.assignee,
    required this.iconAsset,
    this.isDone = false,
  });
}