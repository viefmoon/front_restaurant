class SalesReport {
  final double totalSales;
  final double totalAmountPaid;
  final List<SubcategorySales> subcategories;

  SalesReport({
    required this.totalSales,
    required this.totalAmountPaid,
    required this.subcategories,
  });

  factory SalesReport.fromJson(Map<String, dynamic> json) {
    var subcategoriesJson = json['subcategories'] as List<dynamic>;
    List<SubcategorySales> subcategories =
        subcategoriesJson.map((i) => SubcategorySales.fromJson(i)).toList();
    return SalesReport(
      totalSales: json['totalSales'].toDouble(),
      totalAmountPaid: json['totalAmountPaid'].toDouble(),
      subcategories: subcategories,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['totalSales'] = totalSales;
    data['totalAmountPaid'] = totalAmountPaid;
    data['subcategories'] = subcategories.map((v) => v.toJson()).toList();
    return data;
  }
}

class SubcategorySales {
  final String subcategoryName;
  final double totalSales;
  final List<ProductSales> products;

  SubcategorySales({
    required this.subcategoryName,
    required this.totalSales,
    required this.products,
  });

  factory SubcategorySales.fromJson(Map<String, dynamic> json) {
    var productsJson = json['products'] as List<dynamic>;
    List<ProductSales> products =
        productsJson.map((i) => ProductSales.fromJson(i)).toList();
    return SubcategorySales(
      subcategoryName: json['subcategoryName'],
      totalSales: json['totalSales'].toDouble(),
      products: products,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['subcategoryName'] = subcategoryName;
    data['totalSales'] = totalSales;
    data['products'] = products.map((v) => v.toJson()).toList();
    return data;
  }
}

class ProductSales {
  final String name;
  final int quantity;
  final double totalSales;

  ProductSales({
    required this.name,
    required this.quantity,
    required this.totalSales,
  });

  factory ProductSales.fromJson(Map<String, dynamic> json) {
    return ProductSales(
      name: json['name'],
      quantity: json['quantity'],
      totalSales: json['totalSales'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['name'] = name;
    data['quantity'] = quantity;
    data['totalSales'] = totalSales;
    return data;
  }
}
