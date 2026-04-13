class OutletModel {
  final String id;
  final String name;
  final String code;
  final String address;
  final int totalProducts;
  final int criticalProductsCount;

  OutletModel({
    required this.id,
    required this.name,
    required this.code,
    required this.address,
    this.totalProducts = 0,
    this.criticalProductsCount = 0,
  });

  /// Factory constructor to create an OutletModel from a JSON map.
  factory OutletModel.fromJson(Map<String, dynamic> json) {
    return OutletModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown Outlet',
      code: json['code'] as String? ?? '',
      address: json['address'] as String? ?? '',
      totalProducts: json['totalProducts'] as int? ?? 0,
      criticalProductsCount: json['criticalProductsCount'] as int? ?? 0,
    );
  }

  /// Converts the OutletModel to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'address': address,
      'totalProducts': totalProducts,
      'criticalProductsCount': criticalProductsCount,
    };
  }
}