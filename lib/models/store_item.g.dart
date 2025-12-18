// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoreItem _$StoreItemFromJson(Map<String, dynamic> json) => StoreItem(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  category: $enumDecode(_$ItemCategoryEnumMap, json['category']),
  pointsCost: (json['points_cost'] as num).toInt(),
  imageUrl: json['image_url'] as String?,
  stockQuantity: (json['stock_quantity'] as num).toInt(),
  isAvailable: json['is_available'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$StoreItemToJson(StoreItem instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'category': _$ItemCategoryEnumMap[instance.category]!,
  'points_cost': instance.pointsCost,
  'image_url': instance.imageUrl,
  'stock_quantity': instance.stockQuantity,
  'is_available': instance.isAvailable,
  'created_at': instance.createdAt.toIso8601String(),
};

const _$ItemCategoryEnumMap = {
  ItemCategory.golfGear: 'golf_gear',
  ItemCategory.giftCards: 'gift_cards',
  ItemCategory.exclusiveItems: 'exclusive_items',
};

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  itemId: json['item_id'] as String,
  itemName: json['item_name'] as String,
  quantity: (json['quantity'] as num).toInt(),
  totalPoints: (json['total_points'] as num).toInt(),
  status: $enumDecode(_$OrderStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'item_id': instance.itemId,
  'item_name': instance.itemName,
  'quantity': instance.quantity,
  'total_points': instance.totalPoints,
  'status': _$OrderStatusEnumMap[instance.status]!,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'pending',
  OrderStatus.processing: 'processing',
  OrderStatus.shipped: 'shipped',
  OrderStatus.delivered: 'delivered',
  OrderStatus.cancelled: 'cancelled',
};
