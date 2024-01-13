import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:proyecto_flutter/api/services/cloudinary_service.dart';
import 'package:proyecto_flutter/api/services/openai_services.dart';
import 'package:proyecto_flutter/api/services/recipe_service.dart';
import 'package:proyecto_flutter/api/services/user_service.dart';
import 'package:proyecto_flutter/api/utils/http_api.dart';
import 'package:http/http.dart' as http;

class ChatBotPage extends StatefulWidget {
  final String productName;

  const ChatBotPage({Key? key, required this.productName}) : super(key: key);

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class RecipeInfo {
  final String title;
  final String ingredients;
  final String steps;

  RecipeInfo(
      {required this.title, required this.ingredients, required this.steps});
}

class _ChatBotPageState extends State<ChatBotPage> {
  String response = "";
  late TextEditingController _controller;
  bool loading = false;
  Uint8List? imageBytes;
  Map<String, dynamic> userData = {};
  RecipeService recipeService = RecipeService();
  //RecipeInfo recipeInfo = RecipeInfo(title: '', ingredients: '', steps: '');
  String title = "";
  String ingredients = "";
  String steps = "";

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.productName);
    loadRecipe();
    obtenerDatosUsuario();
  }

  String? _imageUrl = '';
  String? getImageUrl() {
    return _imageUrl;
  }

  Future<void> obtenerDatosUsuario() async {
    ApiResponse response = await UserService.getUserById();
    setState(() {
      userData = response.data;
    });
  }

  Future<void> generateImage(prompt) async {
    setState(() {
      loading = true;
    });
    var apiKey = "";
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
          loading = false;
        });
      } else {
        print('Failed to generate image: ${response.body}');
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _uploadGeneratedImage(Uint8List? imageBytes) async {
    try {
      if (imageBytes == null || imageBytes.isEmpty) {
        // Manejar el caso cuando imageBytes es nulo o vacío
        print('Error: imageBytes está nulo o vacío.');
        return;
      }

      // Crear una instancia de CloudinaryServices
      final cloudinaryServices = CloudinaryServices();

      // Subir la imagen a Cloudinary usando CloudinaryServices
      final uploadedUrl = await cloudinaryServices.uploadImageFromBytes(
        imageBytes,
      );
      print("URL de Cloudinary: $uploadedUrl");

      if (uploadedUrl != null) {
        // Si uploadedUrl no es nulo, actualizar la interfaz de usuario
        setState(() {
          _imageUrl = uploadedUrl;
        });
      } else {
        // Manejar el caso cuando uploadedUrl es nulo
        print('Error: uploadedUrl es nulo.');
      }
    } catch (error) {
      // Manejar errores generales
      print('Error en la carga de la imagen generada: $error');
    }
  }

  Future<void> loadRecipe() async {
    setState(() {
      loading = true;
    });

    try {
      var res = await sendTextCompletionRequest(
          "Hazme una receta simple y ecológica con ${widget.productName}");

      setState(() {
        response = res["choices"][0]["text"];
        loading = false;
      });

      // Separar la respuesta en título, ingredientes y pasos
      RecipeInfo recipeInfo = parseRecipe(response);

      // Ahora puedes acceder a title, ingredients y steps en recipeInfo
      print("Título: ${recipeInfo.title}");
      print("Ingredientes: ${recipeInfo.ingredients}");
      print("Pasos: ${recipeInfo.steps}");
      title = recipeInfo.title;
      ingredients = recipeInfo.ingredients;
      steps = recipeInfo.steps;
      await generateImage(recipeInfo.title);
      await _uploadGeneratedImage(imageBytes);
      // Guarda la receta
      await RecipeService.createRecipe(
        userData['_id'], // Supongo que 'userId' está en 'userData'
        widget.productName,
        response,
        _imageUrl ?? '',
        title,
      );
    } catch (error) {
      setState(() {
        loading = false;
      });
      print('Error al cargar la receta: $error');
      // Manejar el error según sea necesario
    }
  }

  Future<void> reloadRecipe() async {
    setState(() {
      loading = true;
    });

    try {
      RecipeInfo recipeInfo1 = parseRecipe(response);
      var res = await sendTextCompletionRequest(
          "Hazme una receta simple y ecológica con ${widget.productName} y que sea totalmente diferente a ${recipeInfo1.title}");

      setState(() {
        response = res["choices"][0]["text"];
        loading = false;
      });

      // Separar la respuesta en título, ingredientes y pasos
      RecipeInfo recipeInfo = parseRecipe(response);

      // Ahora puedes acceder a title, ingredients y steps en recipeInfo
      print("Título: ${recipeInfo.title}");
      print("Ingredientes: ${recipeInfo.ingredients}");
      print("Pasos: ${recipeInfo.steps}");
      title = recipeInfo.title;
      ingredients = recipeInfo.ingredients;
      steps = recipeInfo.steps;
      await generateImage(recipeInfo.title);
      await _uploadGeneratedImage(imageBytes);
      await RecipeService.createRecipe(
        userData['_id'], // Supongo que 'userId' está en 'userData'
        widget.productName,
        response,
        _imageUrl ?? '',
        title,
      );
    } catch (error) {
      setState(() {
        loading = false;
      });
      print('Error al cargar la receta: $error');
      // Manejar el error según sea necesario
    }
  }

  RecipeInfo parseRecipe(String response) {
    List<String> lines = response.split('\n');

    String title = "";
    String ingredients = "";
    String steps = "";

    bool isIngredientsSection = false;

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();

      if (line.isNotEmpty) {
        // Si la línea no está vacía, se asume que es parte del contenido
        if (title.isEmpty) {
          title = line;
        } else if (!isIngredientsSection) {
          ingredients += line + '\n';

          // Si la próxima línea está vacía, indica que los ingredientes han terminado
          if (i + 1 < lines.length && lines[i + 1].trim().isEmpty) {
            isIngredientsSection = true;
          }
        } else {
          steps += line + '\n';
        }
      }
    }

    return RecipeInfo(
      title: title,
      ingredients: ingredients.trim(),
      steps: steps.trim(),
    );
  }

  Widget _buildAppBarReloadButton() {
    return Container(
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(Icons.refresh, color: Theme.of(context).colorScheme.primary),
        onPressed: () async {
          await reloadRecipe();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Producto: ${widget.productName}',
          style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        actions: [_buildAppBarReloadButton()],
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 60,
              ),
              if (imageBytes != null && !loading)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                        10.0), // Ajusta el radio según tus necesidades
                    child: Image.memory(
                      imageBytes!,
                      width:
                          400, // Puedes ajustar el ancho según tus necesidades
                      height:
                          400, // Puedes ajustar la altura según tus necesidades
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              SizedBox(
                height: 30,
              ),
              if (loading)
                Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ) // Mostrar el indicador de carga mientras se está generando la imagen
              else if (imageBytes != null)
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          left: 20), // Márgenes a la izquierda y derecha
                      child: Text(
                        "${title}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      child: Text(
                        "${ingredients}",
                        style: TextStyle(
                          fontSize: 24,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      margin: EdgeInsets.only(
                          left: 20), // Márgenes a la izquierda y derecha
                      child: Text(
                        "${steps}",
                        style: TextStyle(
                          fontSize: 22,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
