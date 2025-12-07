import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:genui_firebase_ai/genui_firebase_ai.dart';
import 'firebase_options.dart';
import 'workout_catalog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Workout Planner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'AI Workout Planner'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _textEditingController = TextEditingController();
  late final GenUiConversation conversation;
  final _surfaceIds = <String>[];

  void _onSurfaceAdded(SurfaceAdded surface) {
    _surfaceIds.add(surface.surfaceId);
    setState(() {});
  }

  void _onSurfaceDeleted(SurfaceRemoved surface) {
    _surfaceIds.remove(surface.surfaceId);
    setState(() {});
  }

  void _onEvent(UserActionEvent event) {
    final eventName = event.name;
    final context = event.context;

    String prompt;

    switch (eventName) {
      case 'workout_start':
        final workoutTitle = context['workoutTitle'] as String?;
        prompt = 'Start a workout session for ${workoutTitle ?? "the workout"}. Show the first exercise as a WorkoutSessionCard with exercise 1 of the total exercises, include sets, reps, and rest time.';
        break;

      case 'exercise_complete':
        final exerciseNum = context['exerciseNumber'] as int?;
        final exercise = context['exercise'] as String?;
        prompt = 'User completed exercise ${exerciseNum ?? "current"} ($exercise). Show the next exercise in the workout as a WorkoutSessionCard, or if finished, show a completion message with their progress dashboard.';
        break;

      case 'skip_exercise':
        prompt = 'User skipped the current exercise. Show the next exercise in the workout session as a WorkoutSessionCard.';
        break;

      case 'show_progress':
        prompt = 'Show my progress dashboard with stats, current streak, weekly progress, and achievements.';
        break;

      case 'show_schedule':
        prompt = 'Show this week\'s workout schedule with all 7 days.';
        break;

      case 'create_workout':
        prompt = 'Show me a menu of different workout types I can choose from (upper body, lower body, core, full body, etc.) as a NavigationMenu.';
        break;

      case 'show_home':
        prompt = 'Show the main menu with options for: creating a workout, viewing progress, seeing schedule, and starting a quick workout. Use a NavigationMenu.';
        break;

      default:
        prompt = 'User selected: ${context['label'] ?? eventName}. Generate the appropriate screen for this action.';
    }

    conversation.sendRequest(UserMessage.text(prompt));
  }

  Future<void> _sendMessage(String text) async {
    final message = text.trim();
    if (message.isNotEmpty) {
      return conversation.sendRequest(UserMessage.text(message));
    }
  }

  @override
  void initState() {
    super.initState();
    final catalog = WorkoutCatalog.getCatalog();

    final genUiManager = GenUiManager(catalog: catalog);

    genUiManager.onSubmit.listen((message) {
      try {
        final jsonData = jsonDecode(message.text) as Map<String, dynamic>;
        if (jsonData.containsKey('userAction')) {
          final eventData = jsonData['userAction'] as Map<String, dynamic>;
          final event = UserActionEvent.fromMap(eventData);
          _onEvent(event);
        }
      } catch (e) {
        conversation.sendRequest(message);
      }
    });

    final generator = FirebaseAiContentGenerator(
      catalog: catalog,
      systemInstruction: '''
You are a fitness coach AI. You have 4 custom widgets:

1. **WorkoutPlanCard** - Complete workout plan
   - title, description, difficulty, duration
   - exercises: list with name, sets, reps
   - startButtonText

2. **WorkoutSessionCard** - Active workout screen
   - currentExercise, exerciseNumber, totalExercises
   - sets, reps, restTime, description

3. **ProgressDashboard** - Stats dashboard
   - totalWorkouts, currentStreak
   - weeklyGoal, weeklyProgress

4. **NavigationMenu** - Navigation menu
   - title
   - options: list with label and action

## Usage:

Workout request → WorkoutPlanCard with 3-5 bodyweight exercises
Progress request → ProgressDashboard with stats
Menu request → NavigationMenu with options (actions: show_progress, show_schedule, create_workout, show_home)
Session request → WorkoutSessionCard showing current exercise

Keep it simple!
''',
    );
    conversation = GenUiConversation(
      genUiManager: genUiManager,
      contentGenerator: generator,
      onSurfaceAdded: (value) => _onSurfaceAdded(value),
      onSurfaceDeleted: (value) => _onSurfaceDeleted(value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _surfaceIds.length,
              itemBuilder: (context, index) {
                final id = _surfaceIds[index];
                return GenUiSurface(host: conversation.host, surfaceId: id);
              },
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textEditingController,
                      decoration: InputDecoration(
                        hintText: 'Ask for a workout plan...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (text) {
                        _sendMessage(text);
                        _textEditingController.clear();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      _sendMessage(_textEditingController.text);
                      _textEditingController.clear();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
