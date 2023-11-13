import 'package:proyecto_flutter/api/utils/http_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
}
