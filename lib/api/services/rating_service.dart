import 'package:proyecto_flutter/api/utils/http_api.dart';

class RatingService {
  static Future<ApiResponse> createRating(Map<String, dynamic> rating) async {
    ApiResponse response = ApiResponse(data: {}, statusCode: 404);
    try {
      response = await Api().post(
        '/ratings/createrating',
        data: rating,
      );
      return response;
    } catch (error) {
      return response;
    }
  }

  static Future<ApiResponse> getRatingById(String ratingId) async {
    ApiResponse response = ApiResponse(data: {}, statusCode: 404);
    response = await Api().get('/ratings/readrating/$ratingId');
    print('API Response: $response');
    return response;
  }

  static Future<ApiResponse> getAllRatings() async {
    ApiResponse response = ApiResponse(data: {}, statusCode: 404);
    response = await Api().get('/ratings/readallratings');
    print('API Response: $response');
    return response;
  }

  static Future<ApiResponse> deleteRating(String ratingId) async {
    ApiResponse response = ApiResponse(data: {}, statusCode: 404);
    response = await Api().delete('/ratings/deleterating/$ratingId');
    print('API Response: $response');
    return response;
  }

    static Future<ApiResponse> updateAverageRating(String userId) async {
    ApiResponse response = ApiResponse(data: {}, statusCode: 404);
    try {
      response = await Api().putWithoutToken(
        '/ratings/updateaveragerating/$userId',
      );
      return response;
    } catch (error) {
      return response;
    }
  }
}

