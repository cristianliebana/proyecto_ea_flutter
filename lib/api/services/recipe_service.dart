import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proyecto_flutter/api/models/recipe_model.dart';
import 'package:proyecto_flutter/api/utils/http_api.dart';

class RecipeService {
  static Future<ApiResponse> createRecipe(String userId, String product,
      String recipe, String recipeURL, String title) async {
    ApiResponse response = ApiResponse(data: {}, statusCode: 404);
    try {
      response = await Api().postWithoutToken(
        '/recipes/createrecipe',
        data: {
          'userId': userId,
          'product': product,
          'recipe': recipe,
          'recipeURL': recipeURL,
          'title': title,
        },
      );
      return response;
    } catch (error) {
      return response;
    }
  }

  static Future<List<Recipe>> getUserRecipes(String userId) async {
    ApiResponse response = ApiResponse(data: {}, statusCode: 404);
    response = await Api().get('/recipes/readuserrecipe/$userId');

    if (response.statusCode == 200) {
      List<Recipe> recipesList = [];
      List<dynamic> recipesData = response.data['docs'];
      for (var recipeData in recipesData) {
        Recipe recipe = Recipe.fromJson(recipeData);
        recipesList.add(recipe);
      }
      return recipesList;
    } else {
      print('Error en la solicitud: ${response.statusCode}');
      return [];
    }
  }
}
