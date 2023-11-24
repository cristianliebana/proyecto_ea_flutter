//import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:proyecto_flutter/api/models/product_model.dart';
//import 'package:proyecto_flutter/api/services/token_service.dart';
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

  static Future<ApiResponse> getProductById(String productId) async {
    ApiResponse response = ApiResponse(data: {}, statusCode: 404);
    response = await Api().getWithoutToken('/products/readproduct/$productId');
    print('API Response: $response');
    return response;
  }
}
