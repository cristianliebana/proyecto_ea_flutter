import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:proyecto_flutter/widget/nav_bar.dart';

class DallEPage extends StatefulWidget {
  const DallEPage({Key? key}) : super(key: key);

  @override
  State<DallEPage> createState() => _DallEPageState();
}

class _DallEPageState extends State<DallEPage> {
  var apiKey1 = "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";
  TextEditingController controller = TextEditingController();
  Uint8List? imageBytes;
  bool isLoading = false;

  void generateImage(prompt) async {
    setState(() {
      isLoading = true;
    });
    final apiKey = apiKey1;
    final uri = Uri.parse('https://api.openai.com/v1/images/generations');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey'
    };
    final body = jsonEncode({
      'prompt': '$prompt',
      'model': 'dall-e-2',
      "size": "256x256",
      'quality': 'standard',
      "response_format": "b64_json",
      'n': 1,
    });

    try {
      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final imageBase64 = responseData['data'][0]['b64_json'];
        //print('Image Base64: $imageBase64');

        final decodedBytes = base64Decode(imageBase64);
        setState(() {
          imageBytes = Uint8List.fromList(decodedBytes);
          isLoading = false;
        });
      } else {
        print('Failed to generate image: ${response.body}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Inside your _MySecondState class
@override
Widget build(BuildContext context) {
  return Scaffold(
    bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 6),
    body: Container(
      margin: EdgeInsets.all(20),
      child: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: 40,
              ),
              Text(
                "¡Genera tu foto!",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 40,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    )
                  : imageBytes != null
                      ? Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.memory(
                              imageBytes!,
                              width: 400,
                              height: 400,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Container(),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextField(
                controller: controller,
                maxLines: 6,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.onPrimary,
                  hintText: "Introduce una descripción de tu imagen",
                  hintStyle: TextStyle(
                    color: Colors.white60,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    primary: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    if (!isLoading) {
                      generateImage(controller.text);
                    }
                  },
                  child: Text(
                    isLoading ? "Generando..." : "Generar imagen",
                    style: TextStyle(
                      fontSize: 19,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              )
            ],
          ),
        ],
      ),
    ),
  );
}
}
