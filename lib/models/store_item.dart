import 'package:json_annotation/json_annotation.dart';

part 'store_item.g.dart';

enum ItemCategory {
  @JsonValue('golf_gear')
  golfGear,
  @JsonValue('gift_cards')
  giftCards,
  @JsonValue('exclusive_items')
  exclusiveItems,
}

enum OrderStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('processing')
  processing,
  @JsonValue('shipped')
  shipped,
  @JsonValue('delivered')
  delivered,
  @JsonValue('cancelled')
  cancelled,
}

@JsonSerializable()
class StoreItem {
  final String id;
  final String name;
  final String description;
  final ItemCategory category;
  @JsonKey(name: 'points_cost')
  final int pointsCost;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'stock_quantity')
  final int stockQuantity;
  @JsonKey(name: 'is_available')
  final bool isAvailable;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  StoreItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.pointsCost,
    this.imageUrl,
    required this.stockQuantity,
    required this.isAvailable,
    required this.createdAt,
  });

  factory StoreItem.fromJson(Map<String, dynamic> json) =>
      _$StoreItemFromJson(json);
  Map<String, dynamic> toJson() => _$StoreItemToJson(this);

  bool get inStock => stockQuantity > 0;
}

@JsonSerializable()
class Order {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'item_id')
  final String itemId;
  @JsonKey(name: 'item_name')
  final String itemName;
  final int quantity;
  @JsonKey(name: 'total_points')
  final int totalPoints;
  final OrderStatus status;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.totalPoints,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);
}
