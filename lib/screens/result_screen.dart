import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/quiz_provider.dart';
import './home_screen.dart';
import '../background_video.dart';
import '../sound_service.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BackgroundVideo(
      withSound: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _ResultContent(),
      ),
    );
  }
}

class _ResultContent extends StatefulWidget {
  const _ResultContent();

  @override
  _ResultContentState createState() => _ResultContentState();
}

class _ResultContentState extends State<_ResultContent> {
  late int _displayedScore;
  bool _showDetails = false;
  bool _showQuestions = false;
  int? _selectedQuestionIndex;
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToBottom = false;
  bool _completionSoundPlayed = false;

  @override
  void initState() {
    super.initState();
    _displayedScore = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnimations();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _startAnimations() {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final finalScore = quizProvider.calculateScore();
    
    Future.delayed(const Duration(milliseconds: 500), () {
      void updateScore() {
        if (mounted) {
          setState(() {
            _displayedScore += 1;
            if (_displayedScore > finalScore) {
              _displayedScore = finalScore;
            }
          });
          if (_displayedScore < finalScore) {
            Future.delayed(const Duration(milliseconds: 30), updateScore);
          } else {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                setState(() {
                  _showDetails = true;
                });
                _scrollToBottom(delay: 300);
                
                if (!_completionSoundPlayed) {
                  _playCompletionSound();
                  _completionSoundPlayed = true;
                }
              }
            });
          }
        }
      }
      updateScore();
    });
  }

  void _playCompletionSound() {
    SoundService.playStartSound();
  }

  void _onQuestionTap(int index) async {
    await SoundService.playToggleSound();
    setState(() {
      _selectedQuestionIndex = _selectedQuestionIndex == index ? null : index;
    });
  }

  void _scrollToBottom({int delay = 0}) {
    if (_hasScrolledToBottom) return;
    
    Future.delayed(Duration(milliseconds: delay), () {
      if (!mounted) return;
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 4000),
            curve: Curves.easeInOut,
          ).then((_) {
            _hasScrolledToBottom = true;
          });
        }
      });
    });
  }

  void _handleBackButton(QuizProvider quizProvider) async {
    await SoundService.playBackSound();
    
    if (!mounted) return;
    
    quizProvider.resetTest();
    
    if (!mounted) return;
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    final score = quizProvider.calculateScore();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildHeader(quizProvider),
            const SizedBox(height: 20),
            
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildResultCard(score, quizProvider),
                    const SizedBox(height: 20),
                    
                    if (_showDetails) _buildDetails(quizProvider, score),
                    
                    if (_showQuestions) 
                      _buildQuestionsReview(quizProvider),
                    
                    const SizedBox(height: 20),
                    
                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 20,
                    ),
                  ],
                ),
              ),
            ),
            
            _buildRestartButton(quizProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(QuizProvider quizProvider) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, 0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _handleBackButton(quizProvider),
          ),
          const SizedBox(width: 10),
          Text(
            quizProvider.selectedLanguage == 'ru' ? 'Результат' : 'Ergebnis',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
        ],
      ),
    )
    .animate()
    .fadeIn(duration: 400.ms)
    .slideX(begin: -1.0);
  }

  Widget _buildResultCard(int score, QuizProvider quizProvider) {
    String getIQLevel() {
      if (score >= 130) return quizProvider.selectedLanguage == 'ru' ? 'Гений' : 'Genie';
      if (score >= 115) return quizProvider.selectedLanguage == 'ru' ? 'Высокий' : 'Hoch';
      if (score >= 85) return quizProvider.selectedLanguage == 'ru' ? 'Средний' : 'Durchschnitt';
      return quizProvider.selectedLanguage == 'ru' ? 'Ниже среднего' : 'Unterdurchschnittlich';
    }

    Color getScoreColor() {
      if (score >= 130) return Colors.green;
      if (score >= 115) return Colors.blue;
      if (score >= 85) return Colors.orange;
      return Colors.red;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue, Colors.purple],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(33, 150, 243, 0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            score >= 100 ? Icons.emoji_events : Icons.psychology,
            size: 80,
            color: Colors.amber,
          )
          .animate()
          .scale(duration: 800.ms, curve: Curves.elasticOut),
          
          const SizedBox(height: 20),
          
          Text(
            quizProvider.selectedLanguage == 'ru' ? 'Тест завершен!' : 'Test abgeschlossen!',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          )
          .animate()
          .fadeIn(delay: 300.ms),
          
          const SizedBox(height: 30),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 255, 255, 0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.3)),
            ),
            child: Column(
              children: [
                Text(
                  quizProvider.selectedLanguage == 'ru' ? 'Ваш результат:' : 'Ihr Ergebnis:',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$_displayedScore',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: getScoreColor(),
                  ),
                ),
                
                const SizedBox(height: 10),
                
                Text(
                  getIQLevel(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          )
          .animate()
          .fadeIn(delay: 700.ms)
          .slideY(begin: 1.0),
        ],
      ),
    )
    .animate()
    .fadeIn(duration: 600.ms);
  }

  Widget _buildDetails(QuizProvider quizProvider, int percentage) {
    // ИСПРАВЛЕНИЕ: используем correctAnswersCount вместо деления процента на 10
    final correctAnswers = quizProvider.correctAnswersCount;
    final totalQuestions = quizProvider.questions.length;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, 0.95),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            quizProvider.selectedLanguage == 'ru' ? 'Статистика:' : 'Statistik:',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
          ),
          const SizedBox(height: 20),
          
          _buildProgressStats(quizProvider, correctAnswers, totalQuestions),
          const SizedBox(height: 20),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  quizProvider.selectedLanguage == 'ru' ? 'Правильные ответы:' : 'Richtige Antworten:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[900],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green[500],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$correctAnswers/$totalQuestions',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  quizProvider.selectedLanguage == 'ru' ? 'Процент успеха:' : 'Erfolgsquote:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[900],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue[500],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$percentage%',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await SoundService.playToggleSound();
                setState(() {
                  _showQuestions = !_showQuestions;
                  _selectedQuestionIndex = null;
                  _hasScrolledToBottom = false;
                });
                
                if (_showQuestions) {
                  _scrollToBottom(delay: 500);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[500],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_showQuestions ? Icons.visibility_off : Icons.visibility),
                  const SizedBox(width: 8),
                  Text(
                    _showQuestions 
                      ? (quizProvider.selectedLanguage == 'ru' ? 'Скрыть вопросы' : 'Fragen ausblenden')
                      : (quizProvider.selectedLanguage == 'ru' ? 'Показать вопросы' : 'Fragen anzeigen'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    )
    .animate()
    .fadeIn()
    .slideY(begin: 1.0);
  }

  Widget _buildQuestionsReview(QuizProvider quizProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, 0.95),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            quizProvider.selectedLanguage == 'ru' ? 'Обзор вопросов:' : 'Fragenübersicht:',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
          ),
          const SizedBox(height: 15),
          
          ..._buildQuestionList(quizProvider),
        ],
      ),
    )
    .animate()
    .fadeIn()
    .slideY(begin: 1.0);
  }

  List<Widget> _buildQuestionList(QuizProvider quizProvider) {
    List<Widget> questionWidgets = [];
    
    for (int i = 0; i < quizProvider.questions.length; i++) {
      final questionData = quizProvider.questions[i];
      final userAnswerIndex = quizProvider.userAnswers[i];
      final correctAnswerIndex = questionData['correctAnswer'];
      final language = quizProvider.selectedLanguage;
      
      final questionText = questionData['question'][language];
      final userAnswerText = userAnswerIndex != null 
          ? questionData['answers'][language][userAnswerIndex]
          : (quizProvider.selectedLanguage == 'ru' ? 'Не ответил' : 'Nicht geantwortet');
      final correctAnswerText = questionData['answers'][language][correctAnswerIndex];
      final isCorrect = userAnswerIndex == correctAnswerIndex;

      questionWidgets.add(
        GestureDetector(
          onTap: () => _onQuestionTap(i),
          child: _buildQuestionItem(
            quizProvider,
            i + 1,
            questionText,
            userAnswerText,
            correctAnswerText,
            isCorrect,
            isSelected: _selectedQuestionIndex == i,
          ),
        )
        .animate(delay: (i * 100).ms)
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.5, curve: Curves.easeOut),
      );
      
      if (i < quizProvider.questions.length - 1) {
        questionWidgets.add(const SizedBox(height: 15));
      }
    }
    
    return questionWidgets;
  }

  Widget _buildQuestionItem(
    QuizProvider quizProvider, 
    int number, 
    String question, 
    String userAnswer, 
    String correctAnswer, 
    bool isCorrect,
    {bool isSelected = false}
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.amber.shade600 : (isCorrect ? Colors.green[200]! : Colors.red[200]!),
          width: isSelected ? 3 : 1,
        ),
        boxShadow: isSelected ? [
          const BoxShadow(
            color: Color.fromRGBO(255, 193, 7, 0.3),
            blurRadius: 15,
            spreadRadius: 3,
            offset: Offset(0, 5),
          ),
        ] : [
          const BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isSelected ? 35 : 30,
                height: isSelected ? 35 : 30,
                decoration: BoxDecoration(
                  color: isCorrect ? Colors.green[500] : Colors.red[500],
                  shape: BoxShape.circle,
                  boxShadow: isSelected ? [
                    const BoxShadow(
                      color: Color.fromRGBO(255, 193, 7, 0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ] : null,
                ),
                child: Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isSelected ? 16 : 14,
                    ),
                    child: Text('$number'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: double.infinity,
                      ),
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: isSelected ? 18 : 16,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                        child: Text(
                          question,
                          overflow: TextOverflow.visible,
                          softWrap: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: double.infinity,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isCorrect ? Icons.check : Icons.close,
                            color: isCorrect ? Colors.green : Colors.red,
                            size: isSelected ? 18 : 16,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              quizProvider.selectedLanguage == 'ru' 
                                ? 'Ваш ответ: ' 
                                : 'Ihre Antwort: ',
                              style: TextStyle(
                                fontSize: isSelected ? 15 : 14,
                                color: Colors.grey[700],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                fontSize: isSelected ? 15 : 14,
                                fontWeight: FontWeight.w600,
                                color: isCorrect ? Colors.green[700] : Colors.red[700],
                              ),
                              child: Text(
                                userAnswer,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    if (!isCorrect) ...[
                      const SizedBox(height: 5),
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: double.infinity,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check,
                              color: Colors.green,
                              size: isSelected ? 18 : 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                quizProvider.selectedLanguage == 'ru' 
                                  ? 'Правильный ответ: ' 
                                  : 'Richtige Antwort: ',
                                style: TextStyle(
                                  fontSize: isSelected ? 15 : 14,
                                  color: Colors.grey[700],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: TextStyle(
                                  fontSize: isSelected ? 15 : 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green[700],
                                ),
                                child: Text(
                                  correctAnswer,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          
          if (isSelected) ...[
            const SizedBox(height: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isCorrect 
                        ? (quizProvider.selectedLanguage == 'ru' 
                            ? 'Правильный ответ! 🎉' 
                            : 'Richtige Antwort! 🎉')
                        : (quizProvider.selectedLanguage == 'ru' 
                            ? 'Правильный ответ показан выше' 
                            : 'Richtige Antwort oben angezeigt'),
                      style: TextStyle(
                        color: Colors.amber[800],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.5),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressStats(QuizProvider quizProvider, int correct, int total) {
    final percentage = correct / total;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            quizProvider.selectedLanguage == 'ru' ? 'Прогресс:' : 'Fortschritt:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          
          Container(
            height: 16,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * percentage,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.green, Colors.blue],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(percentage * 100).round()}% ${quizProvider.selectedLanguage == 'ru' ? 'выполнено' : 'abgeschlossen'}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                quizProvider.selectedLanguage == 'ru' ? '$correct из $total' : '$correct von $total',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRestartButton(QuizProvider quizProvider) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(33, 150, 243, 0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _handleRestartButton(quizProvider),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.refresh_rounded),
            const SizedBox(width: 8),
            Text(
              quizProvider.selectedLanguage == 'ru' 
                ? 'Пройти еще раз' 
                : 'Nochmal versuchen',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      )
      .animate(delay: 1500.ms)
      .fadeIn()
      .slideY(begin: 1.0),
    );
  }

 void _handleRestartButton(QuizProvider quizProvider) async {
  await SoundService.playRestartSound();
  
  if (!mounted) return;
  
  quizProvider.resetTest(); // Теперь этот метод автоматически перемешивает вопросы
  
  if (!mounted) return;
  
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => const BackgroundVideo(withSound: false, child: HomeScreen())),
    (Route<dynamic> route) => false,
  );
}}