import 'package:json_annotation/json_annotation.dart';

part 'bundle.g.dart';

@JsonSerializable()
class Bundle {
  final String id;
  final String name;
  final String? description;

  @JsonKey(name: 'gc_amount', fromJson: _intFromJson)
  final int gcAmount; // Gold Coins in bundle

  @JsonKey(name: 'bonus_sc_amount', fromJson: _intFromJson)
  final int bonusScAmount; // FREE Bonus Sweeps Coins

  @JsonKey(name: 'price_usd', fromJson: _doubleFromJson)
  final double priceUsd; // Price in USD

  @JsonKey(name: 'is_featured')
  final bool isFeatured; // Highlighted bundle

  @JsonKey(name: 'discount_percentage', fromJson: _intFromJson)
  final int discountPercentage; // e.g., 10 for 10% off

  @JsonKey(name: 'sort_order')
  final int? sortOrder;

  Bundle({
    required this.id,
    required this.name,
    this.description,
    required this.gcAmount,
    required this.bonusScAmount,
    required this.priceUsd,
    this.isFeatured = false,
    this.discountPercentage = 0,
    this.sortOrder,
  });

  factory Bundle.fromJson(Map<String, dynamic> json) => _$BundleFromJson(json);

  Map<String, dynamic> toJson() => _$BundleToJson(this);

  // Custom converters to handle both String and num from API
  static int _intFromJson(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _doubleFromJson(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Formatted price string
  String get formattedPrice => '\$${priceUsd.toStringAsFixed(2)}';

  /// Formatted GC amount (e.g., "10,000")
  String get formattedGcAmount => gcAmount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');

  /// Value proposition text
  String get valueText {
    if (bonusScAmount > 0) {
      return '$formattedGcAmount GC + FREE $bonusScAmount SC';
    }
    return '$formattedGcAmount GC';
  }

  /// Discount text (if applicable)
  String? get discountText {
    if (discountPercentage > 0) {
      return '$discountPercentage% OFF';
    }
    return null;
  }

  /// Badge text (Featured, Best Value, etc.)
  String? get badgeText {
    if (isFeatured) return 'BEST VALUE';
    if (discountPercentage > 0) return 'SAVE $discountPercentage%';
    return null;
  }
}