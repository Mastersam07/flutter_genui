import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:genui_firebase_ai/genui_firebase_ai.dart';
import 'firebase_options.dart';

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
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
    final catalog = CoreCatalogItems.asCatalog();
    final generator = FirebaseAiContentGenerator(
      catalog: catalog,
      systemInstruction: '''
You are an expert in creating workout plans using only body weight exercises.
No cardio, free weight or other sports. Each workout plan should be 3 to 5 different exercises,
each with a number of sets and repetitions.

When i send you a message, generate new UI that displays the workout plan you created in response
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
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textEditingController,
                      decoration: InputDecoration(
                        hintText: 'Enter your message',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
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
