import 'package:flutter/material.dart';
import 'package:proyecto_flutter/api/services/openai_services.dart';
import 'package:proyecto_flutter/api/services/recipe_service.dart';
import 'package:proyecto_flutter/api/services/user_service.dart';
import 'package:proyecto_flutter/api/utils/http_api.dart';

class ChatBotPage extends StatefulWidget {
  final String productName;

  const ChatBotPage({Key? key, required this.productName}) : super(key: key);

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  String response = "";
  late TextEditingController _controller;
  bool loading = false;
  Map<String, dynamic> userData = {};
  RecipeService recipeService = RecipeService();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.productName);
    loadRecipe();
    obtenerDatosUsuario();
  }

  Future<void> obtenerDatosUsuario() async {
    ApiResponse response = await UserService.getUserById();
    setState(() {
      userData = response.data;
    });
  }

  // Future<void> loadRecipe() async {
  //   setState(() {
  //     loading = true; // Mostrar el indicador de carga
  //   });

  //   var res = await sendTextCompletionRequest(
  //       "Hazme una receta simple y ecológica con ${widget.productName}");

  //   setState(() {
  //     response = res["choices"][0]["text"];
  //     loading =
  //         false; // Ocultar el indicador de carga después de cargar la receta
  //   });
  // }

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

      // Guarda la receta
      await RecipeService.createRecipe(
        userData['_id'], // Supongo que 'userId' está en 'userData'
        widget.productName,
        response,
      );
    } catch (error) {
      setState(() {
        loading = false;
      });
      print('Error al cargar la receta: $error');
      // Manejar el error según sea necesario
    }
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
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Container(
              //   width: 400,
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(10),
              //     color: Theme.of(context).colorScheme.onPrimary,
              //   ),
              //   child: TextField(
              //     controller: _controller,
              //     maxLines: null,
              //     cursorColor: Colors.white,
              //     style: TextStyle(color: Colors.white),
              //     decoration: InputDecoration(
              //       contentPadding: EdgeInsets.all(5.0),
              //       border: InputBorder.none,
              //     ),
              //   ),
              // ),
              SizedBox(
                height: 60,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: () async {
                  await loadRecipe(); // Llama a loadRecipe cuando se presiona el botón
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: loading
                      ? CircularProgressIndicator() // Muestra el indicador de carga si está cargando
                      : Text(
                          "¡A cocinar!",
                          style: TextStyle(
                            fontSize: 24,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                ),
              ),
              Container(
                width: 500,
                child: Text(
                  response,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
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
