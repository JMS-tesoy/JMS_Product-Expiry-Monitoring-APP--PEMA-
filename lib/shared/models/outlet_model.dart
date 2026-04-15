class OutletModel {
  final String id;
  final String name;
  final String code;
  final String address;
  final String? inventoryOutletId;
  final String? inventoryOutletName;
  final int totalQuantity;
  final int invoiceCount;
  final int customerCount;
  final int totalProducts;
  final int criticalProductsCount;

  OutletModel({
    required this.id,
    required this.name,
    this.code = '',
    this.address = '',
    this.inventoryOutletId,
    this.inventoryOutletName,
    this.totalQuantity = 0,
    this.invoiceCount = 0,
    this.customerCount = 0,
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
      inventoryOutletId: json['inventoryOutletId'] as String?,
      inventoryOutletName: json['inventoryOutletName'] as String?,
      totalQuantity: json['totalQuantity'] as int? ?? 0,
      invoiceCount: json['invoiceCount'] as int? ?? 0,
      customerCount: json['customerCount'] as int? ?? 0,
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
      'inventoryOutletId': inventoryOutletId,
      'inventoryOutletName': inventoryOutletName,
      'totalQuantity': totalQuantity,
      'invoiceCount': invoiceCount,
      'customerCount': customerCount,
      'totalProducts': totalProducts,
      'criticalProductsCount': criticalProductsCount,
    };
  }
}
