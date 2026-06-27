class RecipeIngredient {
  const RecipeIngredient({required this.name, required this.grams});

  final String name;
  final int grams;
}

class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.slot,
    required this.emoji,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.ingredients,
    this.steps = const [],
    this.fitsGoal = true,
  });

  final String id;
  final String name;
  final String slot;
  final String emoji;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final List<RecipeIngredient> ingredients;
  final List<String> steps;
  final bool fitsGoal;
}
