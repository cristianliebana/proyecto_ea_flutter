import 'package:proyecto_flutter/api/utils/http_api.dart';

class RoomService {
  static Future<ApiResponse> createRoom(String userId1, String userId2) async {
    ApiResponse response = ApiResponse(data: {}, statusCode: 404);

    try {
      Map<String, dynamic> roomData = {
        "userId1": userId1,
        "userId2": userId2,
      };

      response = await Api().postWithoutToken(
        '/rooms/createroom',
        data: roomData,
      );

      return response;
    } catch (error) {
      // Puedes manejar el error según tus necesidades
      print("Error en la solicitud: $error");
      return response;
    }
  }

  static Future<ApiResponse> readRoomsByUserId(String userId) async {
    ApiResponse response = ApiResponse(data: {}, statusCode: 404);
    response = await Api().get('/rooms/readrooms/$userId');
    print('API Response: $response');
    return response;
  }

  static Future<ApiResponse> checkIfRoomExists(
      String userId1, String userId2) async {
    ApiResponse response = ApiResponse(data: {}, statusCode: 404);

    try {
      response = await Api().get('/rooms/roomexist/$userId1/$userId2');
      return response;
    } catch (error) {
      // Puedes manejar el error según tus necesidades
      print("Error en la solicitud: $error");
      return response;
    }
  }
}
