class OrderItemSummary {
  final String subcategoryName;
  final List<ProductOrVariantCount> products;

  OrderItemSummary({required this.subcategoryName, required this.products});

  factory OrderItemSummary.fromJson(Map<String, dynamic> json) {
    return OrderItemSummary(
      subcategoryName: json['subcategoryName'],
      products: List<ProductOrVariantCount>.from(json['products']
          .map((product) => ProductOrVariantCount.fromJson(product))),
    );
  }
}

class ProductOrVariantCount {
  final String name;
  final int count;

  ProductOrVariantCount({required this.name, required this.count});

  factory ProductOrVariantCount.fromJson(Map<String, dynamic> json) {
    return ProductOrVariantCount(
      name: json['name'],
      count: json['count'],
    );
  }
}
