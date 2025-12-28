class BulletinComment {
  final String id;

  final int? userId;
  final String? targetType; // note/item (server trả về có)
  final String? targetId;

  final String content;
  final String? parentId;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  BulletinComment({
    this.id = '',
    this.userId,
    this.targetType,
    this.targetId,
    required this.content,
    this.parentId,
    this.createdAt,
    this.updatedAt,
  });

  factory BulletinComment.fromJson(Map<String, dynamic> json) {
    return BulletinComment(
      id: json['id'].toString(),
      userId: json['user_id'] == null ? null : int.tryParse(json['user_id'].toString()),
      targetType: json['target_type']?.toString(),
      targetId: json['target_id']?.toString(),
      content: (json['content'] ?? '').toString(),
      parentId: json['parent_id']?.toString(),
      createdAt: json['created_at'] == null ? null : DateTime.tryParse(json['created_at'].toString()),
      updatedAt: json['updated_at'] == null ? null : DateTime.tryParse(json['updated_at'].toString()),
    );
  }

  /// JSON để GỬI LÊN BACKEND
  /// Backend createComment nhận { content, parentId }
  Map<String, dynamic> toRequestJson() {
    return {
      'content': content,
      'parentId': parentId,
    };
  }
}
