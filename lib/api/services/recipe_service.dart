import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proyecto_flutter/api/models/recipe_model.dart';

class RecipeService {
  static const String baseUrl =
      "/recipes"; // Reemplaza con la URL de tu backend

  static Future<void> createRecipe(
      String userId, String product, String recipe) async {
    final Uri url = Uri.parse('http://localhost:9090/recipes/createrecipe');

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'userId': userId,
          'product': product,
          'recipe': recipe,
        }),
      );
      print(response);
      if (response.statusCode == 201) {
        print('Receta creada exitosamente');
      } else {
        print(
            'Error al crear la receta. Código de estado: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> getAllRecipes() async {
    final Uri url = Uri.parse('$baseUrl/readall');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> recipes = jsonDecode(response.body);
        print('Recetas obtenidas: $recipes');
      } else {
        print(
            'Error al obtener las recetas. Código de estado: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  static Future<List<Recipe>> getUserRecipes(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/recipes/user/$userId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<Recipe> recipes =
          data.map((recipeData) => Recipe.fromJson(recipeData)).toList();
      return recipes;
    } else {
      throw Exception('Failed to load recipes');
    }
  }
}
