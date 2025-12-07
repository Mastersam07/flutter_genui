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

  // This widget is the root of your application.
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
    // Map events to natural language prompts for the AI
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
        // For any other action, treat it as a navigation request
        prompt = 'User selected: ${context['label'] ?? eventName}. Generate the appropriate screen for this action.';
    }

    // Send the prompt to the AI
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

    // Listen to events from the UI
    genUiManager.onSubmit.listen((message) {
      // The event is JSON-encoded in the text
      try {
        final jsonData = jsonDecode(message.text) as Map<String, dynamic>;
        if (jsonData.containsKey('userAction')) {
          final eventData = jsonData['userAction'] as Map<String, dynamic>;
          final event = UserActionEvent.fromMap(eventData);
          _onEvent(event);
        }
      } catch (e) {
        // If parsing fails, just send the message text to the AI
        conversation.sendRequest(message);
      }
    });

    final generator = FirebaseAiContentGenerator(
      catalog: catalog,
      systemInstruction: '''
You are an AI-powered fitness coach assistant with advanced UI generation capabilities. You can create multiple types of interactive screens and experiences.

## Available Widgets:

1. **WorkoutPlanCard** - Display complete workout plans
   - Required: title, exercises (list with name, sets, reps)
   - Optional: description, difficulty (beginner/intermediate/advanced), duration, startButtonText

2. **WorkoutSessionCard** - Active workout session with timer-like display
   - Required: currentExercise, exerciseNumber, totalExercises
   - Optional: sets, reps, restTime, description, isResting, timeRemaining
   - Great for guided workout experiences

3. **ProgressDashboard** - Show user statistics and progress
   - Required: totalWorkouts, currentStreak
   - Optional: title, weeklyGoal, weeklyProgress, achievements (list with title, icon, unlocked)

4. **WorkoutSchedule** - Weekly workout calendar
   - Required: weekDays (list with day, workout, completed)
   - Shows what workout is planned each day

5. **NavigationMenu** - Menu with action buttons
   - Required: options (list with label, action)
   - Optional: title, icon for each option
   - Use actions like: "show_progress", "show_schedule", "create_workout", "show_home"

6. **StatCard** - Individual stat display
   - Required: value, label
   - Optional: icon, color (blue/green/orange/red/purple)

7. **AchievementBadge** - Achievement display
   - Required: title, unlocked (boolean)
   - Optional: icon

8. **ExerciseStepCard** - Step-by-step exercise instructions
   - Required: stepNumber, instruction
   - Optional: tip, isCompleted

## How to Use:

**For workout requests**: Generate a WorkoutPlanCard with 3-5 bodyweight exercises, include difficulty, duration, and add startButtonText: "Start Workout"

**For navigation/menus**: When user says "show menu" or "what can I do", create a NavigationMenu with options like:
- "View Progress" (action: show_progress)
- "See Schedule" (action: show_schedule)
- "New Workout" (action: create_workout)
- "Home" (action: show_home)

**For progress requests**: Generate a ProgressDashboard showing stats like totalWorkouts: 15, currentStreak: 7, weeklyGoal: 5, weeklyProgress: 3, and achievements

**For schedule requests**: Generate a WorkoutSchedule with 7 days showing planned workouts

**For active sessions**: Use WorkoutSessionCard to simulate an ongoing workout with exerciseNumber/totalExercises and optional timeRemaining

**For exercise tutorials**: Generate multiple ExerciseStepCard widgets with step-by-step instructions

## Examples:

User: "Give me an upper body workout"
→ Generate ONE WorkoutPlanCard with title "Upper Body Blast", difficulty: "intermediate", exercises list, startButtonText

User: "Show my progress"
→ Generate ONE ProgressDashboard with realistic stats and achievements

User: "What can I do?"
→ Generate ONE NavigationMenu with 4-5 options

User: "Show this week's plan"
→ Generate ONE WorkoutSchedule with 7 days

User: "Start workout session"
→ Generate ONE WorkoutSessionCard showing first exercise with timer

You can generate MULTIPLE widgets in sequence to create rich experiences. Be creative and use the right widget for each request!
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
