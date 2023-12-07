class Product {
  String? id;
  String? name;
  String? description;
  double? price;
  int? units;
  List<String>? productImage;

  Product({
    this.id,
    this.name,
    this.description,
    this.price,
    this.units,
    this.productImage,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      units: json['units'] ?? 0,
      productImage: (json['productImage'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'units': units,
      'productImage': productImage,
    };
  }
}
