class OrderAdjustment {
  final int? id;
  final String? uuid;
  final String? name;
  final double? amount;

  OrderAdjustment({
    this.id,
    this.uuid,
    this.name,
    this.amount,
  });

  OrderAdjustment copyWith({
    int? id,
    String? uuid,
    String? name,
    double? amount,
  }) {
    return OrderAdjustment(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      amount: amount ?? this.amount,
    );
  }

  factory OrderAdjustment.fromJson(Map<String, dynamic> json) {
    return OrderAdjustment(
      id: json['id'],
      uuid: json['uuid'],
      name: json['name'],
      amount: json['amount'] != null
          ? double.tryParse(json['amount'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['uuid'] = uuid;
    data['name'] = name;
    data['amount'] = amount;
    return data;
  }
}
