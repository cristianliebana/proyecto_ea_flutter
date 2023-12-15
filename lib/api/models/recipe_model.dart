class Recipe {
  String? id;
  String? product;
  String? recipe;

  Recipe({
    this.id,
    this.product,
    this.recipe,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['_id'],
      product: json['product'],
      recipe: json['recipe'],
    );
  }
}
