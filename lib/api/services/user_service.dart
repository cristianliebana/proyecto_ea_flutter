import 'package:jwt_decoder/jwt_decoder.dart';
//import 'package:proyecto_flutter/api/models/user_model.dart';
import 'package:proyecto_flutter/api/services/token_service.dart';
import 'package:proyecto_flutter/api/utils/http_api.dart';

class UserService {
  static Future<ApiResponse> registerUser(Map<String, dynamic> user) async {
    ApiResponse response = ApiResponse(data: {}, statusCode: 404);
    try {
      response = await Api().postWithoutToken(
        '/users/createuser',
        data: user,
      );
      return response;
    } catch (error) {
      return response;
    }
  }

  static Future<ApiResponse> loginUser(Map<String, dynamic> user) async {
    ApiResponse response = ApiResponse(data: {}, statusCode: 404);
    try {
      response = await Api().post(
        '/users/signin',
        data: user,
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

  static Future<ApiResponse> getCreadorById(String creadorId) async {
    ApiResponse response = ApiResponse(data: {}, statusCode: 404);
    response = await Api().getWithoutToken('/users/readuser/$creadorId');
    print('API Response: $response');
    return response;
  }

  static Future<ApiResponse> usernameExists(String username) async {
    ApiResponse response = ApiResponse(data: {}, statusCode: 404);
    try {
      response = await Api().getWithoutToken('/users/usernameexists/$username');
      return response;
    } catch (error) {
      return response;
    }
  }

  static Future<ApiResponse> emailExists(String email) async {
    ApiResponse response2 = ApiResponse(data: {}, statusCode: 404);
    try {
      response2 = await Api().getWithoutToken('/users/emailexists/$email');
      return response2;
    } catch (error) {
      return response2;
    }
  }

  static Future<ApiResponse> updateUser(Map<String, dynamic> user) async {
    ApiResponse response = ApiResponse(data: {}, statusCode: 404);
    try {
      bool isLoggedIn = await TokenService.loggedIn();
      if (isLoggedIn) {
        String? token = await TokenService.getToken();
        if (token != null) {
          Map<String, dynamic> payload = JwtDecoder.decode(token);
          String userId = payload['id'];
          response = await Api()
              .putWithoutToken('/users/updateuser/$userId', data: user);
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
}
