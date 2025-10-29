import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/quiz_provider.dart';
import './result_screen.dart';
import '../background_video.dart';
import '../sound_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  QuizScreenState createState() => QuizScreenState();
}

class QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  late AnimationController _answerAnimationController;
  int? _selectedAnswerIndex;
  bool _isAnswering = false;

  @override
  void initState() {
    super.initState();
    _answerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _selectedAnswerIndex = null;
    _isAnswering = false;
  }

  @override
  void dispose() {
    _answerAnimationController.dispose();
    super.dispose();
  }

  void _onAnswerSelected(int index, QuizProvider quizProvider) async {
    if (_isAnswering) return;
    
    await SoundService.playAnswerSound();
    
    setState(() {
      _isAnswering = true;
      _selectedAnswerIndex = index;
    });
    
    _answerAnimationController.forward().then((_) {
      quizProvider.answerQuestion(index);
      _answerAnimationController.reset();
      
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _selectedAnswerIndex = null;
            _isAnswering = false;
          });
        }
      });
      
      if (quizProvider.isTestComplete) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ResultScreen()),
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);

    if (quizProvider.isTestComplete) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                quizProvider.selectedLanguage == 'ru' 
                  ? 'Подсчет результатов...' 
                  : 'Ergebnisse werden berechnet...',
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }

    final question = quizProvider.currentQuestionData;
    final progress = (quizProvider.currentQuestion + 1) / quizProvider.questions.length;

    return BackgroundVideo(
      withSound: false,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildProgressHeader(progress, quizProvider),
                const SizedBox(height: 30),
                
                _buildQuestionCard(question, quizProvider),
                const SizedBox(height: 20),
                
                Expanded(
                  child: _buildAnswersGrid(question, quizProvider),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressHeader(double progress, QuizProvider quizProvider) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              quizProvider.selectedLanguage == 'ru' 
                ? 'Вопрос ${quizProvider.currentQuestion + 1}/${quizProvider.questions.length}'
                : 'Frage ${quizProvider.currentQuestion + 1}/${quizProvider.questions.length}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * progress,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.purple],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              )
              .animate()
              .scaleX(duration: 500.ms, curve: Curves.easeOut),
            ],
          ),
        ),
      ],
    )
    .animate()
    .fadeIn(duration: 400.ms);
  }

  Widget _buildQuestionCard(Map<String, dynamic> question, QuizProvider quizProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue, Colors.purple],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(30, 136, 229, 0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            question['question'][quizProvider.selectedLanguage],
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    )
    .animate()
    .scale(duration: 600.ms, curve: Curves.elasticOut)
    .fadeIn();
  }

  Widget _buildAnswersGrid(Map<String, dynamic> question, QuizProvider quizProvider) {
    final answers = question['answers'][quizProvider.selectedLanguage];
    
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.3,
      ),
      itemCount: answers.length,
      itemBuilder: (context, index) {
        final isSelected = _selectedAnswerIndex == index;
        final answerColor = _getAnswerColor(index);
        
        return GestureDetector(
          onTap: () => _onAnswerSelected(index, quizProvider),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: _withOpacity(answerColor, isSelected ? 0.9 : 1.0),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: _withOpacity(answerColor, 0.6),
                    blurRadius: 25,
                    spreadRadius: 5,
                    offset: const Offset(0, 8),
                  )
                else
                  const BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.15),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
              ],
              border: isSelected
                  ? Border.all(color: Colors.white, width: 3)
                  : Border.all(color: Colors.transparent, width: 0),
            ),
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: isSelected ? 18 : 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: Colors.white,
                      ),
                      child: Text(
                        answers[index],
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: EdgeInsets.all(isSelected ? 8 : 6),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? const Color.fromRGBO(255, 255, 255, 0.4)
                          : const Color.fromRGBO(255, 255, 255, 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isSelected ? 16 : 14,
                      ),
                    ),
                  ),
                ),
                
                if (isSelected)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: const RadialGradient(
                          center: Alignment.center,
                          radius: 0.8,
                          colors: [
                            Color.fromRGBO(255, 255, 255, 0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          )
          .animate(delay: (index * 100).ms)
          .fadeIn(duration: 500.ms)
          .slideY(begin: 1.0, curve: Curves.easeOut),
        );
      },
    );
  }

  Color _getAnswerColor(int index) {
    const colors = <Color>[
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.pink,
    ];
    return colors[index % colors.length];
  }

  Color _withOpacity(Color color, double opacity) {
    return color.withAlpha((opacity * 255).round());
  }
}