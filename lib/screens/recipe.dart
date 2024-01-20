import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyecto_flutter/api/models/recipe_model.dart';
import 'package:proyecto_flutter/api/services/recipe_service.dart'; // Cambiado para importar el servicio de recetas
import 'package:proyecto_flutter/api/services/user_service.dart';
import 'package:proyecto_flutter/api/utils/http_api.dart';
import 'package:proyecto_flutter/utils/constants.dart';

class RecipeScreen extends StatefulWidget {
  @override
  _RecipeScreenState createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  List<Recipe> recipes = [];
  Map<String, dynamic> userData = {};
  late ScrollController _scrollController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    obtenerDatosUsuario();
  }

  Future<void> obtenerDatosUsuario() async {
    ApiResponse response = await UserService.getUserById();
    setState(() {
      userData = response.data;
      print(userData['_id']);
      loadUserRecipes(userData['_id']);
    });
  }

  Future<void> loadUserRecipes(String? userId) async {
    if (userId != null) {
      final List<Recipe> userRecipes =
          await RecipeService.getUserRecipes(userId);
      setState(() {
        recipes = userRecipes;
        print(recipes);
      });
    } else {
      print('UserId is null.');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis recetas publicadas'.tr,
            style: TextStyle(color: Theme.of(context).colorScheme.primary)),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            SearchBar(),
            Container(
              height: MediaQuery.of(context).size.height,
              child: CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return RecipesVerticalItem(recipe: recipes[index]);
                      },
                      childCount: recipes.length,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05), // Responsive horizontal padding
      child: Column(
        children: [
          SizedBox(height: screenHeight * 0.03), // Responsive height
          Padding(
            padding: EdgeInsets.only(),
            child: TextField(
              style: TextStyle(
                fontSize: screenWidth * 0.035, // Responsive font size
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.primary,
              ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: screenWidth * 0.05), // Responsive padding
                filled: true,
                fillColor: Theme.of(context).colorScheme.onPrimary,
                prefixIcon: IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.primary,
                    size: screenWidth * 0.06, // Responsive icon size
                  ),
                ),
                hintStyle: TextStyle(
                  fontSize: screenWidth * 0.035, // Responsive font size
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.primary,
                ),
                hintText: 'Busca en tus recetas'.tr,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RecipesVerticalItem extends StatelessWidget {
  final Recipe recipe;

  const RecipesVerticalItem({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        // Display a dialog on tap
        Get.defaultDialog(
          title: "Detalles de la Receta",
          backgroundColor: Theme.of(context).colorScheme.primary,
          titleStyle: TextStyle(
            color: Theme.of(context).primaryColor,
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Image.network(
                  recipe.recipeURL ?? '',
                  height: screenHeight * 0.25,
                  width: screenWidth * 0.5,
                  fit: BoxFit.cover,
                ),
                Text(
                  "${recipe.recipe}",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(
            left: screenWidth * 0.04,
            top: screenHeight * 0.02,
            right: screenWidth * 0.04),
        width: screenWidth / 1.5,
        height: screenHeight / 4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
        ),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                image: DecorationImage(
                  image:
                      recipe.recipeURL != null && recipe.recipeURL!.isNotEmpty
                          ? NetworkImage(recipe.recipeURL!)
                          : AssetImage('assets/images/placeholder.png')
                              as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: screenWidth - 20, // Limit the width, subtracting the left and right padding/margin
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      recipe.title ?? '',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: screenWidth * 0.04,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
