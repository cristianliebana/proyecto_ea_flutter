import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';
import 'package:proyecto_flutter/configs/endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

final optHeader = {
  'content-type': 'application/json',
  'accept': 'application/json'
};

class ModelResponse {
  dynamic message;
  bool success;
  ModelResponse({required this.message, required this.success});
}

class ApiResponse {
  int statusCode;
  Map<String, dynamic> data;
  ApiResponse({required this.data, this.statusCode = -1});
}

class Api {
  static int requestTimeoutms = 20000;
  var client = InterceptedClient.build(
    requestTimeout: Duration(milliseconds: requestTimeoutms),
    interceptors: [],
  );
  Api._internal();

  static final _singleton = Api._internal();

  factory Api() => _singleton;

  Future<ApiResponse> postWithoutToken(String path,
      {Map<String, dynamic> data = const {}}) async {
    ApiResponse res = ApiResponse(data: {}, statusCode: -1);
    try {
      final response = await client.post(
        "${Endpoints.ipBackend}$path".toUri(),
        body: jsonEncode(data),
        headers: optHeader,
      );
      res.statusCode = response.statusCode;
      res.data = jsonDecode(response.body) as Map<String, dynamic>? ?? {};
      return res;
    } catch (e) {
      // ignore: avoid_print
      print(e);
      return res;
    }
  }

  Future<ApiResponse> getWithoutToken(String path, {queryParameters}) async {
    ApiResponse res = ApiResponse(data: {}, statusCode: -1);
    try {
      final response = await client.get(
        "${Endpoints.ipBackend}$path".toUri(),
        params: queryParameters,
        headers: optHeader,
      );
      res.statusCode = response.statusCode;
      res.data = jsonDecode(response.body) as Map<String, dynamic>? ?? {};

      return res;
    } catch (e) {
      // ignore: avoid_print
      print(e);
      return res;
    }
  }

  Future<ApiResponse> post(String path,
      {Map<String, dynamic> data = const {}}) async {
    ApiResponse res = ApiResponse(data: {}, statusCode: -1);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token != null) {
        optHeader['Authorization'] = 'Bearer $token';
      } else {
        ModelResponse brp = await AuthorizeRequest();
        if (brp.success) {
          optHeader['Authorization'] = 'Bearer ${brp.message}';
        } else {
          optHeader['Authorization'] = 'Bearer $token';
        }
      }
      final response = await client.post(
        "${Endpoints.ipBackend}$path".toUri(),
        body: jsonEncode(data),
        headers: optHeader,
      );
      if (response.statusCode == 401) {
        ModelResponse brp = await AuthorizeRequest();
        if (brp.success) {
          optHeader['Authorization'] = 'Bearer ${brp.message}';
          final response2 = await client.post(
            "${Endpoints.ipBackend}$path".toUri(),
            body: jsonEncode(data),
            headers: optHeader,
          );
          res.statusCode = response2.statusCode;
          res.data = jsonDecode(response2.body) as Map<String, dynamic>? ?? {};
        } else {
          optHeader['Authorization'] = 'Bearer $token';
        }
      } else {
        res.statusCode = response.statusCode;
        res.data = jsonDecode(response.body) as Map<String, dynamic>? ?? {};
      }

      return res;
    } catch (e) {
      print(e);
      return res;
    }
  }

  Future<ApiResponse> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    ApiResponse res = ApiResponse(data: {}, statusCode: -1);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token != null) {
        optHeader['Authorization'] = 'Bearer $token';
      } else {
        ModelResponse brp = await AuthorizeRequest();
        if (brp.success) {
          optHeader['Authorization'] = 'Bearer ${brp.message}';
        } else {
          optHeader['Authorization'] = 'Bearer $token';
        }
      }
      final response = await client.get(
        "${Endpoints.ipBackend}$path".toUri(),
        params: queryParameters,
        headers: optHeader,
      );

      if (response.statusCode == 401) {
        ModelResponse brp = await AuthorizeRequest();
        if (brp.success) {
          optHeader['Authorization'] = 'Bearer ${brp.message}';
          final response2 = await client.get(
            "${Endpoints.ipBackend}$path".toUri(),
            params: queryParameters,
            headers: optHeader,
          );
          res.statusCode = response2.statusCode;
          res.data = jsonDecode(response2.body) as Map<String, dynamic>? ?? {};
        } else {
          optHeader['Authorization'] = 'Bearer $token';
        }
      } else {
        res.statusCode = response.statusCode;
        res.data = jsonDecode(response.body) as Map<String, dynamic>? ?? {};
      }
      return res;
    } catch (e) {
      // ignore: avoid_print
      print('Error get: $e');
      return res;
    }
  }

  Future<ModelResponse> AuthorizeRequest() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? email = prefs.getString('email');
      String? password = prefs.getString('password');
      var url = Uri.parse('${Endpoints.ipBackend}/users/signin');
      http.Response responseVal = await http.post(
        url,
        body: {
          'user': {'email': email, 'password': password}
        },
      );

      if (responseVal.statusCode == 201 || responseVal.statusCode == 200) {
        Map<String, dynamic>? data = jsonDecode(responseVal.body);
        prefs.setString("token", data?['token'] ?? "");
        return ModelResponse(
            message: data?['token'] ?? "",
            success: data?['token'] != null ? true : false);
      } else {
        return ModelResponse(message: "Failed to authorize", success: false);
      }
    } catch (err) {
      return ModelResponse(message: err, success: false);
    }
  }

  Future<ApiResponse> putWithoutToken(String path,
      {Map<String, dynamic> data = const {}}) async {
    ApiResponse res = ApiResponse(data: {}, statusCode: -1);
    try {
      final response = await client.put(
        "${Endpoints.ipBackend}$path".toUri(),
        body: jsonEncode(data),
        headers: optHeader,
      );
      res.statusCode = response.statusCode;
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 202) {
        res.data = jsonDecode(response.body) as Map<String, dynamic>? ?? {};
        return res;
      } else {
        return Future.error(
          "Error while fetching.",
          StackTrace.fromString(response.body),
        );
      }
    } catch (e) {
      print(e);
      return res;
    }
  }
}
