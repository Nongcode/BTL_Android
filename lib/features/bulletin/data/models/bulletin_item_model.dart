class BulletinItem {
  final String id;

  final int? houseId;
  final int? createdBy;

  final String itemName;
  final String? itemNote;
  final int? quantity;
  final String? imageUrl;
  final bool isChecked;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  BulletinItem({
    this.id = '',
    this.houseId,
    this.createdBy,
    required this.itemName,
    this.itemNote,
    this.quantity,
    this.imageUrl,
    this.isChecked = false,
    this.createdAt,
    this.updatedAt,
  });

  factory BulletinItem.fromJson(Map<String, dynamic> json) {
    return BulletinItem(
      id: json['id'].toString(),
      houseId: json['house_id'] == null ? null : int.tryParse(json['house_id'].toString()),
      createdBy: json['created_by'] == null ? null : int.tryParse(json['created_by'].toString()),
      itemName: (json['item_name'] ?? '').toString(),
      itemNote: json['item_note']?.toString(),
      quantity: json['quantity'] == null ? null : int.tryParse(json['quantity'].toString()),
      imageUrl: json['image_url']?.toString(),
      isChecked: (json['is_checked'] ?? false) == true,
      createdAt: json['created_at'] == null ? null : DateTime.tryParse(json['created_at'].toString()),
      updatedAt: json['updated_at'] == null ? null : DateTime.tryParse(json['updated_at'].toString()),
    );
  }

  /// JSON để GỬI LÊN BACKEND (camelCase đúng với controller Node)
  Map<String, dynamic> toRequestJson() {
    return {
      'itemName': itemName,
      'itemNote': itemNote,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'isChecked': isChecked,
    };
  }
}
