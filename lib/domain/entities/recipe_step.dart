import 'package:project/domain/entities/recipe.dart';

class RecipeStep {
  final int? id;
  final int? recipeId;
  final int stepNumber;
  final String instruction;
  final int? durationSeconds;

  RecipeStep({
    this.id,
    this.recipeId,
    required this.stepNumber,
    required this.instruction,
    this.durationSeconds,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recipe_id': recipeId,
      'step_number': stepNumber,
      'instruction': instruction,
      'duration_seconds': durationSeconds,
    };
  }

  factory RecipeStep.fromMap(Map<String, dynamic> map) {
    return RecipeStep(
      id: map['id'],
      recipeId: map['recipe_id'],
      stepNumber: map['step_number'],
      instruction: map['instruction'],
      durationSeconds: map['duration_seconds'],
    );
  }
}