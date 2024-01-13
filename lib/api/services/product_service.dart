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

  static Future<List<Product>> getProductsOferta() async {
    ApiResponse response = ApiResponse(data: {}, statusCode: 404);
    response = await Api().get('/products/readuserproductsoferta');

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

  static Future<List<Product>> getUserProducts(String userId) async {
    ApiResponse response = ApiResponse(data: {}, statusCode: 404);
    response = await Api().get('/products/readuserproducts/$userId');

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

  static Future<ApiResponse> addProduct(Map<String, dynamic> product) async {
    ApiResponse response = ApiResponse(data: {}, statusCode: 404);
    response = await Api().postWithoutToken(
      '/products/createproduct',
      data: product,
    );
    return response;
  }

  static Future<ApiResponse> updateProduct(
      String productId, Map<String, dynamic> product) async {
    ApiResponse response = ApiResponse(data: {}, statusCode: 404);
    response = await Api()
        .putWithoutToken('/products/updateproduct/$productId', data: product);

    if (response.statusCode == 200) {
      print('Product updated successfully');
    } else {
      print('Error in update request: ${response.statusCode}');
    }
    return response;
  }
}
