import 'dart:convert';
import 'package:http/http.dart' as http;

String apiKey = "";

Future sendTextCompletionRequest(String message) async {
  String baseUrl = "https://api.openai.com/v1/completions";
  Map<String, String> headers = {
    "Content-Type": "application/json",
    "Authorization": "Bearer $apiKey"
  };
  var res = await http.post(Uri.parse(baseUrl),
      headers: headers,
      body: json.encode({
        "model": "gpt-3.5-turbo-instruct",
        "prompt": message,
        "max_tokens": 200,
        "temperature": 0,
        "top_p": 1,
        "n": 1,
        "stream": false,
        "logprobs": null,
      }));
  if (res.statusCode == 200) {
    // return jsonDecode(res.body);
    String decodedBody = utf8.decode(res.bodyBytes);
    return jsonDecode(decodedBody);
  } else {
    print("Error: ${res.statusCode}");
    print("Respuesta: ${res.body}");
    // Manejar el error según tus necesidades
  }
}
