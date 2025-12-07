import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

/// Advanced catalog with navigation and interactive widgets
class WorkoutCatalog {
  static Catalog getCatalog() => CoreCatalogItems.asCatalog().copyWith([
        workoutPlanCard,
        workoutSessionCard,
        exerciseStepCard,
        progressDashboard,
        navigationMenu,
        statCard,
        achievementBadge,
        workoutSchedule,
      ]);

  // ========== WORKOUT PLAN CARD ==========
  static final workoutPlanCard = CatalogItem(
    name: 'WorkoutPlanCard',
    dataSchema: S.object(
      properties: {
        'title': S.string(description: 'The title of the workout plan'),
        'description': S.string(description: 'Brief description'),
        'difficulty': S.string(
          description: 'Difficulty level',
          enumValues: ['beginner', 'intermediate', 'advanced'],
        ),
        'duration': S.string(description: 'Estimated duration'),
        'exercises': S.list(
          description: 'List of exercises',
          items: S.object(
            properties: {
              'name': S.string(description: 'Exercise name'),
              'sets': S.integer(description: 'Number of sets'),
              'reps': S.string(description: 'Number of repetitions'),
              'description': S.string(description: 'Form tips'),
              'restTime': S.string(description: 'Rest time between sets'),
            },
            required: ['name', 'sets', 'reps'],
          ),
        ),
        'startButtonText': S.string(
          description: 'Text for start button (e.g., "Start Workout")',
        ),
      },
      required: ['title', 'exercises'],
    ),
    widgetBuilder: (itemContext) => _buildWorkoutPlan(
      buildChild: itemContext.buildChild,
      context: itemContext.buildContext,
      data: itemContext.data,
      dispatchEvent: itemContext.dispatchEvent,
      id: itemContext.id,
      dataContext: itemContext.dataContext,
    ),
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
    final startButtonText = json['startButtonText'] as String?;

    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(description,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.grey[700])),
            ],
            if (duration != null || difficulty != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (duration != null) ...[
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(duration,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey[600])),
                    const SizedBox(width: 16),
                  ],
                  if (difficulty != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
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
              ),
            ],
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
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
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
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
                                context, Icons.fitness_center, '$sets sets'),
                            _buildInfoChip(context, Icons.repeat, '$reps reps'),
                            if (restTime != null)
                              _buildInfoChip(context, Icons.timer, restTime),
                          ],
                        ),
                        if (desc != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            desc,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
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
            if (startButtonText != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    dispatchEvent(
                      UserActionEvent(
                        name: 'workout_start',
                        sourceComponentId: id,
                        context: {'workoutTitle': title},
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: Text(startButtonText),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ========== WORKOUT SESSION CARD ==========
  static final workoutSessionCard = CatalogItem(
    name: 'WorkoutSessionCard',
    dataSchema: S.object(
      properties: {
        'currentExercise': S.string(description: 'Current exercise name'),
        'exerciseNumber': S.integer(description: 'Exercise number (e.g., 1)'),
        'totalExercises': S.integer(description: 'Total exercises'),
        'sets': S.integer(description: 'Number of sets'),
        'reps': S.string(description: 'Number of reps'),
        'restTime': S.string(description: 'Rest time'),
        'description': S.string(description: 'Exercise description'),
        'isResting': S.boolean(description: 'Whether currently resting'),
        'timeRemaining': S.string(description: 'Time remaining in current phase'),
      },
      required: ['currentExercise', 'exerciseNumber', 'totalExercises'],
    ),
    widgetBuilder: (itemContext) => _buildWorkoutSession(
      buildChild: itemContext.buildChild,
      context: itemContext.buildContext,
      data: itemContext.data,
      dispatchEvent: itemContext.dispatchEvent,
      id: itemContext.id,
      dataContext: itemContext.dataContext,
    ),
  );

  static Widget _buildWorkoutSession({
    required Object data,
    required String id,
    required ChildBuilderCallback buildChild,
    required DispatchEventCallback dispatchEvent,
    required BuildContext context,
    required DataContext dataContext,
  }) {
    final json = data as Map<String, Object?>;
    final currentExercise = json['currentExercise'] as String;
    final exerciseNumber = json['exerciseNumber'] as int;
    final totalExercises = json['totalExercises'] as int;
    final sets = json['sets'] as int?;
    final reps = json['reps'] as String?;
    final restTime = json['restTime'] as String?;
    final description = json['description'] as String?;
    final isResting = json['isResting'] as bool? ?? false;
    final timeRemaining = json['timeRemaining'] as String?;

    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 6,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isResting
                ? [Colors.blue[400]!, Colors.blue[600]!]
                : [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primaryContainer
                  ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Exercise $exerciseNumber/$totalExercises',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isResting ? 'REST' : 'EXERCISE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                currentExercise,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: 12),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              if (sets != null && reps != null)
                Row(
                  children: [
                    _buildSessionInfo(Icons.fitness_center, '$sets sets'),
                    const SizedBox(width: 16),
                    _buildSessionInfo(Icons.repeat, '$reps reps'),
                    if (restTime != null) ...[
                      const SizedBox(width: 16),
                      _buildSessionInfo(Icons.timer, restTime),
                    ],
                  ],
                ),
              if (timeRemaining != null) ...[
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    timeRemaining,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        dispatchEvent(
                          UserActionEvent(
                            name: 'exercise_complete',
                            sourceComponentId: id,
                            context: {
                              'exercise': currentExercise,
                              'exerciseNumber': exerciseNumber,
                            },
                          ),
                        );
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Complete'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.white,
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      dispatchEvent(
                        UserActionEvent(
                          name: 'skip_exercise',
                          sourceComponentId: id,
                          context: {
                            'exercise': currentExercise,
                            'exerciseNumber': exerciseNumber,
                          },
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      foregroundColor: Colors.white,
                    ),
                    child: const Icon(Icons.skip_next),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========== EXERCISE STEP CARD ==========
  static final exerciseStepCard = CatalogItem(
    name: 'ExerciseStepCard',
    dataSchema: S.object(
      properties: {
        'stepNumber': S.integer(description: 'Step number'),
        'instruction': S.string(description: 'Step instruction'),
        'tip': S.string(description: 'Optional tip'),
        'isCompleted': S.boolean(description: 'Whether step is completed'),
      },
      required: ['stepNumber', 'instruction'],
    ),
    widgetBuilder: (itemContext) => _buildExerciseStep(
      buildChild: itemContext.buildChild,
      context: itemContext.buildContext,
      data: itemContext.data,
      dispatchEvent: itemContext.dispatchEvent,
      id: itemContext.id,
      dataContext: itemContext.dataContext,
    ),
  );

  static Widget _buildExerciseStep({
    required Object data,
    required String id,
    required ChildBuilderCallback buildChild,
    required DispatchEventCallback dispatchEvent,
    required BuildContext context,
    required DataContext dataContext,
  }) {
    final json = data as Map<String, Object?>;
    final stepNumber = json['stepNumber'] as int;
    final instruction = json['instruction'] as String;
    final tip = json['tip'] as String?;
    final isCompleted = json['isCompleted'] as bool? ?? false;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green
                    : Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white)
                    : Text(
                        '$stepNumber',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    instruction,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                  ),
                  if (tip != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      tip,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== PROGRESS DASHBOARD ==========
  static final progressDashboard = CatalogItem(
    name: 'ProgressDashboard',
    dataSchema: S.object(
      properties: {
        'title': S.string(description: 'Dashboard title'),
        'totalWorkouts': S.integer(description: 'Total workouts completed'),
        'currentStreak': S.integer(description: 'Current workout streak'),
        'weeklyGoal': S.integer(description: 'Weekly workout goal'),
        'weeklyProgress': S.integer(description: 'Workouts completed this week'),
        'achievements': S.list(
          description: 'List of achievements',
          items: S.object(
            properties: {
              'title': S.string(description: 'Achievement title'),
              'icon': S.string(description: 'Icon name'),
              'unlocked': S.boolean(description: 'Whether unlocked'),
            },
            required: ['title', 'unlocked'],
          ),
        ),
      },
      required: ['totalWorkouts', 'currentStreak'],
    ),
    widgetBuilder: (itemContext) => _buildProgressDashboard(
      buildChild: itemContext.buildChild,
      context: itemContext.buildContext,
      data: itemContext.data,
      dispatchEvent: itemContext.dispatchEvent,
      id: itemContext.id,
      dataContext: itemContext.dataContext,
    ),
  );

  static Widget _buildProgressDashboard({
    required Object data,
    required String id,
    required ChildBuilderCallback buildChild,
    required DispatchEventCallback dispatchEvent,
    required BuildContext context,
    required DataContext dataContext,
  }) {
    final json = data as Map<String, Object?>;
    final title = json['title'] as String? ?? 'Your Progress';
    final totalWorkouts = json['totalWorkouts'] as int;
    final currentStreak = json['currentStreak'] as int;
    final weeklyGoal = json['weeklyGoal'] as int?;
    final weeklyProgress = json['weeklyProgress'] as int?;
    final achievements = json['achievements'] as List<dynamic>?;

    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildStatContainer(
                    context,
                    Icons.fitness_center,
                    totalWorkouts.toString(),
                    'Total Workouts',
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatContainer(
                    context,
                    Icons.local_fire_department,
                    currentStreak.toString(),
                    'Day Streak',
                    Colors.orange,
                  ),
                ),
              ],
            ),
            if (weeklyGoal != null && weeklyProgress != null) ...[
              const SizedBox(height: 20),
              Text(
                'Weekly Progress',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: weeklyProgress / weeklyGoal,
                  minHeight: 12,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$weeklyProgress / $weeklyGoal workouts this week',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
            if (achievements != null && achievements.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Achievements',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: achievements.map((achievement) {
                  final achMap = achievement as Map<String, Object?>;
                  final achTitle = achMap['title'] as String;
                  final iconName = achMap['icon'] as String?;
                  final unlocked = achMap['unlocked'] as bool;
                  return _buildAchievementBadge(
                    context,
                    achTitle,
                    iconName,
                    unlocked,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ========== NAVIGATION MENU ==========
  static final navigationMenu = CatalogItem(
    name: 'NavigationMenu',
    dataSchema: S.object(
      properties: {
        'title': S.string(description: 'Menu title'),
        'options': S.list(
          description: 'Menu options',
          items: S.object(
            properties: {
              'label': S.string(description: 'Option label'),
              'icon': S.string(description: 'Icon name'),
              'action': S.string(description: 'Action identifier'),
            },
            required: ['label', 'action'],
          ),
        ),
      },
      required: ['options'],
    ),
    widgetBuilder: (itemContext) => _buildNavigationMenu(
      buildChild: itemContext.buildChild,
      context: itemContext.buildContext,
      data: itemContext.data,
      dispatchEvent: itemContext.dispatchEvent,
      id: itemContext.id,
      dataContext: itemContext.dataContext,
    ),
  );

  static Widget _buildNavigationMenu({
    required Object data,
    required String id,
    required ChildBuilderCallback buildChild,
    required DispatchEventCallback dispatchEvent,
    required BuildContext context,
    required DataContext dataContext,
  }) {
    final json = data as Map<String, Object?>;
    final title = json['title'] as String?;
    final options = json['options'] as List<dynamic>;

    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
            ],
            ...options.map((option) {
              final optionMap = option as Map<String, Object?>;
              final label = optionMap['label'] as String;
              final iconName = optionMap['icon'] as String?;
              final action = optionMap['action'] as String;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      dispatchEvent(
                        UserActionEvent(
                          name: action,
                          sourceComponentId: id,
                          context: {'label': label},
                        ),
                      );
                    },
                    icon: Icon(_getIconData(iconName ?? 'fitness_center')),
                    label: Text(label),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ========== STAT CARD ==========
  static final statCard = CatalogItem(
    name: 'StatCard',
    dataSchema: S.object(
      properties: {
        'value': S.string(description: 'Stat value'),
        'label': S.string(description: 'Stat label'),
        'icon': S.string(description: 'Icon name'),
        'color': S.string(
          description: 'Color name',
          enumValues: ['blue', 'green', 'orange', 'red', 'purple'],
        ),
      },
      required: ['value', 'label'],
    ),
    widgetBuilder: (itemContext) => _buildStatCard(
      buildChild: itemContext.buildChild,
      context: itemContext.buildContext,
      data: itemContext.data,
      dispatchEvent: itemContext.dispatchEvent,
      id: itemContext.id,
      dataContext: itemContext.dataContext,
    ),
  );

  static Widget _buildStatCard({
    required Object data,
    required String id,
    required ChildBuilderCallback buildChild,
    required DispatchEventCallback dispatchEvent,
    required BuildContext context,
    required DataContext dataContext,
  }) {
    final json = data as Map<String, Object?>;
    final value = json['value'] as String;
    final label = json['label'] as String;
    final iconName = json['icon'] as String?;
    final colorName = json['color'] as String?;

    final color = _getColorFromName(colorName ?? 'blue');

    return _buildStatContainer(
      context,
      _getIconData(iconName ?? 'star'),
      value,
      label,
      color,
    );
  }

  // ========== ACHIEVEMENT BADGE ==========
  static final achievementBadge = CatalogItem(
    name: 'AchievementBadge',
    dataSchema: S.object(
      properties: {
        'title': S.string(description: 'Achievement title'),
        'icon': S.string(description: 'Icon name'),
        'unlocked': S.boolean(description: 'Whether unlocked'),
      },
      required: ['title', 'unlocked'],
    ),
    widgetBuilder: (itemContext) => _buildAchievementBadgeWidget(
      buildChild: itemContext.buildChild,
      context: itemContext.buildContext,
      data: itemContext.data,
      dispatchEvent: itemContext.dispatchEvent,
      id: itemContext.id,
      dataContext: itemContext.dataContext,
    ),
  );

  static Widget _buildAchievementBadgeWidget({
    required Object data,
    required String id,
    required ChildBuilderCallback buildChild,
    required DispatchEventCallback dispatchEvent,
    required BuildContext context,
    required DataContext dataContext,
  }) {
    final json = data as Map<String, Object?>;
    final title = json['title'] as String;
    final iconName = json['icon'] as String?;
    final unlocked = json['unlocked'] as bool;

    return _buildAchievementBadge(context, title, iconName, unlocked);
  }

  // ========== WORKOUT SCHEDULE ==========
  static final workoutSchedule = CatalogItem(
    name: 'WorkoutSchedule',
    dataSchema: S.object(
      properties: {
        'weekDays': S.list(
          description: 'Schedule for each day of the week',
          items: S.object(
            properties: {
              'day': S.string(description: 'Day name'),
              'workout': S.string(description: 'Workout name or "Rest"'),
              'completed': S.boolean(description: 'Whether completed'),
            },
            required: ['day', 'workout'],
          ),
        ),
      },
      required: ['weekDays'],
    ),
    widgetBuilder: (itemContext) => _buildWorkoutSchedule(
      buildChild: itemContext.buildChild,
      context: itemContext.buildContext,
      data: itemContext.data,
      dispatchEvent: itemContext.dispatchEvent,
      id: itemContext.id,
      dataContext: itemContext.dataContext,
    ),
  );

  static Widget _buildWorkoutSchedule({
    required Object data,
    required String id,
    required ChildBuilderCallback buildChild,
    required DispatchEventCallback dispatchEvent,
    required BuildContext context,
    required DataContext dataContext,
  }) {
    final json = data as Map<String, Object?>;
    final weekDays = json['weekDays'] as List<dynamic>;

    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Week\'s Schedule',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 16),
            ...weekDays.map((dayData) {
              final dayMap = dayData as Map<String, Object?>;
              final day = dayMap['day'] as String;
              final workout = dayMap['workout'] as String;
              final completed = dayMap['completed'] as bool? ?? false;
              final isRest = workout.toLowerCase() == 'rest';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: completed
                        ? Colors.green[50]
                        : isRest
                            ? Colors.grey[100]
                            : Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: completed
                          ? Colors.green
                          : isRest
                              ? Colors.grey[300]!
                              : Colors.blue[200]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        completed
                            ? Icons.check_circle
                            : isRest
                                ? Icons.beach_access
                                : Icons.fitness_center,
                        color: completed
                            ? Colors.green
                            : isRest
                                ? Colors.grey[600]
                                : Colors.blue[700],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              day,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              workout,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    decoration: completed
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                            ),
                          ],
                        ),
                      ),
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

  // ========== HELPER METHODS ==========

  static Widget _buildInfoChip(
      BuildContext context, IconData icon, String label) {
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

  static Widget _buildSessionInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.white70),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  static Widget _buildStatContainer(BuildContext context, IconData icon,
      String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  static Widget _buildAchievementBadge(
      BuildContext context, String title, String? iconName, bool unlocked) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: unlocked ? Colors.amber[100] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: unlocked ? Colors.amber : Colors.grey[400]!,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            _getIconData(iconName ?? 'emoji_events'),
            size: 32,
            color: unlocked ? Colors.amber[700] : Colors.grey[500],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: unlocked ? Colors.amber[900] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
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

  static Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'red':
        return Colors.red;
      case 'purple':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  static IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'fitness_center':
        return Icons.fitness_center;
      case 'timer':
        return Icons.timer;
      case 'favorite':
        return Icons.favorite;
      case 'star':
        return Icons.star;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'calendar_today':
        return Icons.calendar_today;
      case 'assessment':
        return Icons.assessment;
      case 'play_arrow':
        return Icons.play_arrow;
      case 'home':
        return Icons.home;
      case 'schedule':
        return Icons.schedule;
      default:
        return Icons.fitness_center;
    }
  }
}
