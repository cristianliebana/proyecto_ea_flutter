import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:proyecto_flutter/api/models/product_model.dart';
import 'package:proyecto_flutter/api/services/token_service.dart';
import 'package:proyecto_flutter/api/utils/http_api.dart';

class FavoriteService {
  Future<List<Product>> getFavorites(String userId) async {
    ApiResponse response = ApiResponse(data: {}, statusCode: 404);
    response = await Api().get('/favorites/readuserfavorites/$userId');

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

  static Future<ApiResponse> createFavorite(
      String userId, String productId) async {
    ApiResponse response = ApiResponse(data: {}, statusCode: 404);
    try {
      response = await Api().postWithoutToken(
        '/favorites/createfavorite',
        data: {'user': userId, 'product': productId},
      );
      return response;
    } catch (error) {
      return response;
    }
  }

  static Future<ApiResponse> getUserById() async {
    ApiResponse response = ApiResponse(data: {}, statusCode: 404);
    try {
      bool isLoggedIn = await TokenService.loggedIn();
      if (isLoggedIn) {
        String? token = await TokenService.getToken();
        if (token != null) {
          Map<String, dynamic> payload = JwtDecoder.decode(token);
          String userId = payload['id'];
          response = await Api().getWithoutToken('/users/readuser/$userId');
          print('API Response: $response');
          return response;
        } else {
          return ApiResponse(data: {});
        }
      } else {
        return ApiResponse(data: {});
      }
    } catch (error) {
      return response;
    }
  }

  static Future<ApiResponse> deleteFavorite(String favoriteId) async {
    ApiResponse response = ApiResponse(data: {}, statusCode: 404);
    try {
      response = await Api().delete(
        '/favorites/deletefavorite/$favoriteId',
      );
      return response;
    } catch (error) {
      return response;
    }
  }

  static Future<Map<String, dynamic>> checkIfUserHasFavorite(
      String userId, String productId) async {
    ApiResponse response = ApiResponse(data: {}, statusCode: 404);
    try {
      response = await Api().get(
        '/favorites/favoriteexist/$userId/$productId',
      );

      if (response.statusCode == 200) {
        bool exists = response.data['exists'] ?? false;
        String favoriteId = response.data['favoriteId'] ?? '';
        return {'exists': exists, 'favoriteId': favoriteId};
      } else {
        return {'exists': false, 'favoriteId': ''};
      }
    } catch (error) {
      return {'exists': false, 'favoriteId': ''};
    }
  }
}
