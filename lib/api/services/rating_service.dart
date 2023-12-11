import 'package:proyecto_flutter/api/utils/http_api.dart';

import '../models/rating_model.dart';


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

 static Future<List<Rating>> getUserRatings(String userId) async {
    ApiResponse response = ApiResponse(data: {}, statusCode: 404);
    response = await Api().get('/ratings/readuserratings/$userId');

    if (response.statusCode == 200) {
      List<Rating> ratingList = [];
      List<dynamic> ratingsData = response.data['docs'];
      for (var ratingData in ratingsData) {
        Rating rating = Rating.fromJson(ratingData);
        ratingList.add(rating);
      }
      return ratingList;
    } else {
      print('Error en la solicitud: ${response.statusCode}');
      return [];
    }
  }
}
