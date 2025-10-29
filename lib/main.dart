import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/quiz_provider.dart';
import 'screens/home_screen.dart';
import 'background_video.dart';
import 'sound_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key}); // Исправлено: добавлен параметр key

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    SoundService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => QuizProvider(),
      child: MaterialApp(
        title: 'IQ Test Pro',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const BackgroundVideo(child: HomeScreen()), // Исправлено: добавлен const
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}