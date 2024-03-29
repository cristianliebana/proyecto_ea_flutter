//import 'dart:ffi';

class Product {
  String? id;
  String? name;
  String? description;
  double? price;
  int? units;
  List<String>? productImage;
  Location? location;
  DateTime? date;
  bool? sold;

  Product({
    this.id,
    this.name,
    this.description,
    this.price,
    this.units,
    this.productImage,
    this.location,
    this.date,
    this.sold,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      units: json['units'] ?? 0,
      productImage: (json['productImage'] as List<dynamic>).cast<String>(),
      location:
          json['location'] != null ? Location.fromJson(json['location']) : null,
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      sold: json['sold'] ?? '',
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
      'location': location?.toJson(),
      'date': date,
      'sold': sold,
    };
  }
}

class Location {
  double? latitude;
  double? longitude;

  Location({this.latitude, this.longitude});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
