// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bundle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Bundle _$BundleFromJson(Map<String, dynamic> json) => Bundle(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  gcAmount: Bundle._intFromJson(json['gc_amount']),
  bonusScAmount: Bundle._intFromJson(json['bonus_sc_amount']),
  priceUsd: Bundle._doubleFromJson(json['price_usd']),
  isFeatured: json['is_featured'] as bool? ?? false,
  discountPercentage: json['discount_percentage'] == null
      ? 0
      : Bundle._intFromJson(json['discount_percentage']),
  sortOrder: (json['sort_order'] as num?)?.toInt(),
);

Map<String, dynamic> _$BundleToJson(Bundle instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'gc_amount': instance.gcAmount,
  'bonus_sc_amount': instance.bonusScAmount,
  'price_usd': instance.priceUsd,
  'is_featured': instance.isFeatured,
  'discount_percentage': instance.discountPercentage,
  'sort_order': instance.sortOrder,
};
