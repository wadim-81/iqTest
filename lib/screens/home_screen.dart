import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/quiz_provider.dart';
import './quiz_screen.dart';
import '../background_video.dart';
import '../sound_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);

    return BackgroundVideo(
      withSound: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTitle(context, quizProvider),
                const SizedBox(height: 40),
                _buildLanguageSelector(context, quizProvider),
                const SizedBox(height: 60),
                _buildStartButton(context, quizProvider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, QuizProvider quizProvider) {
    return Column(
      children: [
        const Icon(
          Icons.psychology_rounded,
          size: 80,
          color: Colors.amber,
        ),
        const SizedBox(height: 20),
        Text(
          quizProvider.selectedLanguage == 'ru' ? 'IQ Тест' : 'IQ Test',
          style: const TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          quizProvider.selectedLanguage == 'ru'
              ? 'Проверьте свои интеллектуальные способности'
              : 'Testen Sie Ihre intellektuellen Fähigkeiten',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.5);
  }

  Widget _buildLanguageSelector(BuildContext context, QuizProvider quizProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, 0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            quizProvider.selectedLanguage == 'ru'
                ? 'Выберите язык'
                : 'Sprache auswählen',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLanguageButton('RU', 'ru', quizProvider),
              _buildLanguageButton('DE', 'de', quizProvider),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.5);
  }

  Widget _buildLanguageButton(
      String text, String language, QuizProvider quizProvider) {
    final isSelected = quizProvider.selectedLanguage == language;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: ElevatedButton(
          onPressed: () async {
            await SoundService.playLanguageSelectSound();
            quizProvider.setLanguage(language);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Colors.blue[600] : Colors.grey[300],
            foregroundColor: isSelected ? Colors.white : Colors.grey[700],
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

 Widget _buildStartButton(BuildContext context, QuizProvider quizProvider) {
  return AnimatedBuilder(
    animation: _pulseController,
    builder: (context, child) {
      final scale = 0.95 + (_pulseController.value * 0.1);
      return Transform.scale(
        scale: scale,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => _handleStartButtonTap(quizProvider),
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            height: _isPressed ? 70 : 80,
            width: _isPressed ? 220 : 230,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isPressed
                    ? [Colors.green.shade600, Colors.green.shade900]
                    : [Colors.greenAccent.shade400, Colors.green.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
               const BoxShadow( // Добавлен const для конструктора BoxShadow
  color: Color.fromRGBO(0, 0, 0, 0.4),
  offset: Offset(0, 6),
  blurRadius: 12,
),
                BoxShadow(
                  // Исправлено: заменен withOpacity на Color.fromRGBO
                  color: const Color.fromRGBO(105, 240, 174, 0.8), 
                  blurRadius: _isPressed ? 10 : 25,
                  spreadRadius: _isPressed ? 2 : 6,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 8,
                  left: 20,
                  right: 20,
                  child: Container(
                    height: 25,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(255, 255, 255, 0.25),
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
                Text(
                  quizProvider.selectedLanguage == 'ru'
                      ? 'НАЧАТЬ ТЕСТ'
                      : 'TEST STARTEN',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        color: Colors.black45,
                        offset: Offset(1, 2),
                        blurRadius: 4,
                      ),
                      Shadow(
                        color: Colors.greenAccent,
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.5);
}

  // Исправлено: вынесен асинхронный код в отдельный метод с проверкой mounted
  void _handleStartButtonTap(QuizProvider quizProvider) async {
    setState(() => _isPressed = false);
    await SoundService.playStartSound();
    await Future.delayed(const Duration(milliseconds: 120));
    
    // Проверяем mounted перед использованием контекста
    if (!mounted) return;
    
    quizProvider.resetTest();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QuizScreen()),
    );
  }
}