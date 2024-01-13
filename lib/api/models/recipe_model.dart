class Recipe {
  String? id;
  String? product;
  String? recipe;
  String? recipeURL;
  String? title;

  Recipe({
    this.id,
    this.product,
    this.recipe,
    this.recipeURL,
    this.title,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['_id'],
      product: json['product'],
      recipe: json['recipe'],
      recipeURL: json['recipeURL'],
      title: json['title'],
    );
  }
}
