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
    final generator = FirebaseAiContentGenerator(
      catalog: catalog,
      systemInstruction: '''
You are an expert in creating workout plans using only body weight exercises.
No cardio, free weight or other sports. Each workout plan should be 3 to 5 different exercises,
each with a number of sets and repetitions.

When I send you a message, generate a new WorkoutPlanCard UI that displays the workout plan you created.
The WorkoutPlanCard should include:
- A title for the workout
- A brief description
- Difficulty level (beginner, intermediate, or advanced)
- Estimated duration
- A list of exercises with their name, sets, reps, optional description, and optional rest time

Always use the WorkoutPlanCard widget to display workout plans.
''',
    );
    conversation = GenUiConversation(
      genUiManager: GenUiManager(catalog: catalog),
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
