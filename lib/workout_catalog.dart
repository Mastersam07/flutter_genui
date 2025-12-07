import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

class WorkoutCatalog {
  static Catalog getCatalog() =>
      CoreCatalogItems.asCatalog().copyWith([workoutPlanCard]);

  static final workoutPlanCard = CatalogItem(
    name: 'WorkoutPlanCard',
    dataSchema: _workoutPlanSchema,
    widgetBuilder: (itemContext) => _buildWorkoutPlan(
      buildChild: itemContext.buildChild,
      context: itemContext.buildContext,
      data: itemContext.data,
      dispatchEvent: itemContext.dispatchEvent,
      id: itemContext.id,
      dataContext: itemContext.dataContext,
    ),
  );

  static final _workoutPlanSchema = S.object(
    properties: {
      'title': S.string(description: 'The title of the workout plan'),
      'description': S.string(
        description: 'Brief description of the workout plan',
      ),
      'difficulty': S.string(
        description: 'Difficulty level: beginner, intermediate, or advanced',
        enumValues: ['beginner', 'intermediate', 'advanced'],
      ),
      'duration': S.string(
        description: 'Estimated duration (e.g., "20 minutes", "30-45 minutes")',
      ),
      'exercises': S.list(
        description: 'List of exercises in this workout',
        items: S.object(
          properties: {
            'name': S.string(description: 'Exercise name'),
            'sets': S.integer(description: 'Number of sets'),
            'reps': S.string(
              description:
                  'Number of repetitions (can be a number or range like "10-12")',
            ),
            'description': S.string(
              description: 'Brief description or form tips',
            ),
            'restTime': S.string(
              description:
                  'Rest time between sets (e.g., "30 seconds", "1 minute")',
            ),
          },
          required: ['name', 'sets', 'reps'],
        ),
      ),
    },
    required: ['title', 'exercises'],
  );

  static Widget _buildWorkoutPlan({
    required Object data,
    required String id,
    required ChildBuilderCallback buildChild,
    required DispatchEventCallback dispatchEvent,
    required BuildContext context,
    required DataContext dataContext,
  }) {
    final json = data as Map<String, Object?>;
    final title = json['title'] as String;
    final description = json['description'] as String?;
    final difficulty = json['difficulty'] as String?;
    final duration = json['duration'] as String?;
    final exercises = json['exercises'] as List<dynamic>?;

    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
              ),
            ],
            if (duration != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    duration,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
            if (difficulty != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(difficulty),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  difficulty.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            // Exercises list
            if (exercises != null)
              ...exercises.asMap().entries.map((entry) {
                final index = entry.key;
                final exercise = entry.value as Map<String, Object?>;
                final name = exercise['name'] as String;
                final sets = exercise['sets'] as int;
                final reps = exercise['reps'] as String;
                final desc = exercise['description'] as String?;
                final restTime = exercise['restTime'] as String?;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                name,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildInfoChip(
                              context,
                              Icons.fitness_center,
                              '$sets sets',
                            ),
                            _buildInfoChip(context, Icons.repeat, '$reps reps'),
                            if (restTime != null) ...[
                              _buildInfoChip(context, Icons.timer, restTime),
                            ],
                          ],
                        ),
                        if (desc != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            desc,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.grey[700],
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  static Widget _buildInfoChip(
    BuildContext context,
    IconData icon,
    String label,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  static Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
      case 'easy':
        return Colors.green;
      case 'intermediate':
      case 'medium':
        return Colors.orange;
      case 'advanced':
      case 'hard':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
