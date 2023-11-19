import 'package:proyecto_flutter/api/models/product_model.dart';
import 'package:proyecto_flutter/api/utils/http_api.dart';

class ProductService {
  static Future<List<Product>> getProducts(int page) async {
    ApiResponse response = ApiResponse(data: {}, statusCode: 404);
    response = await Api().get('/products/readall/?page=$page');

    if (response.statusCode == 200) {
      List<Product> productList = [];
      List<dynamic> productsData = response.data['docs'];
      for (var productData in productsData) {
        Product product = Product.fromJson(productData);
        productList.add(product);
      }
      return productList;
    } else {
      print('Error en la solicitud: ${response.statusCode}');
      return [];
    }
  }
}
