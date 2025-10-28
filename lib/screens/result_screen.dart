import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/quiz_provider.dart';
import './home_screen.dart';
import '../background_video.dart';

class ResultScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BackgroundVideo(
      withSound: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _ResultContent(),
      ),
    );
  }
}

class _ResultContent extends StatefulWidget {
  @override
  __ResultContentState createState() => __ResultContentState();
}

class __ResultContentState extends State<_ResultContent> {
  late int _displayedScore;
  bool _showDetails = false;
  bool _showQuestions = false;
  int? _selectedQuestionIndex; // Для анимации выделения вопроса

  @override
  void initState() {
    super.initState();
    _displayedScore = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnimations();
    });
  }

  void _startAnimations() {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final finalScore = quizProvider.calculateScore();
    
    Future.delayed(Duration(milliseconds: 500), () {
      void updateScore() {
        if (mounted) {
          setState(() {
            _displayedScore += 1;
            if (_displayedScore > finalScore) {
              _displayedScore = finalScore;
            }
          });
          if (_displayedScore < finalScore) {
            Future.delayed(Duration(milliseconds: 30), updateScore);
          } else {
            Future.delayed(Duration(milliseconds: 500), () {
              if (mounted) {
                setState(() {
                  _showDetails = true;
                });
              }
            });
          }
        }
      }
      updateScore();
    });
  }

  void _onQuestionTap(int index) {
    setState(() {
      _selectedQuestionIndex = _selectedQuestionIndex == index ? null : index;
    });
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
            SizedBox(height: 20),
            
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildResultCard(score, quizProvider),
                    SizedBox(height: 20),
                    
                    if (_showDetails) _buildDetails(quizProvider),
                    
                    if (_showQuestions) 
                      _buildQuestionsReview(quizProvider),
                    
                    SizedBox(height: 20),
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
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
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
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              quizProvider.resetTest();
              Navigator.pop(context);
            },
          ),
          SizedBox(width: 10),
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
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade600, Colors.purple.shade600],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
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
          
          SizedBox(height: 20),
          
          Text(
            quizProvider.selectedLanguage == 'ru' ? 'Тест завершен!' : 'Test abgeschlossen!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          )
          .animate()
          .fadeIn(delay: 300.ms),
          
          SizedBox(height: 30),
          
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text(
                  quizProvider.selectedLanguage == 'ru' ? 'Ваш результат:' : 'Ihr Ergebnis:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '$_displayedScore',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: getScoreColor(),
                  ),
                ),
                
                SizedBox(height: 10),
                
                Text(
                  getIQLevel(),
                  style: TextStyle(
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

  Widget _buildDetails(QuizProvider quizProvider) {
    final correctAnswers = quizProvider.calculateScore() ~/ 10;
    final totalQuestions = quizProvider.questions.length;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
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
          SizedBox(height: 20),
          
          _buildProgressStats(quizProvider, correctAnswers, totalQuestions),
          SizedBox(height: 20),
          
          Container(
            padding: EdgeInsets.all(16),
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
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green[500],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$correctAnswers/$totalQuestions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          
          Container(
            padding: EdgeInsets.all(16),
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
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue[500],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${quizProvider.calculateScore()}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 20),
          
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _showQuestions = !_showQuestions;
                  _selectedQuestionIndex = null; // Сброс выделения при скрытии/показе
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[500],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_showQuestions ? Icons.visibility_off : Icons.visibility),
                  SizedBox(width: 8),
                  Text(
                    _showQuestions 
                      ? (quizProvider.selectedLanguage == 'ru' ? 'Скрыть вопросы' : 'Fragen ausblenden')
                      : (quizProvider.selectedLanguage == 'ru' ? 'Показать вопросы' : 'Fragen anzeigen'),
                    style: TextStyle(
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
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
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
          SizedBox(height: 15),
          
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
        questionWidgets.add(SizedBox(height: 15));
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
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.amber.shade600 : (isCorrect ? Colors.green[200]! : Colors.red[200]!),
          width: isSelected ? 3 : 1,
        ),
        boxShadow: isSelected ? [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 3,
            offset: Offset(0, 5),
          ),
        ] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
                duration: Duration(milliseconds: 300),
                width: isSelected ? 35 : 30,
                height: isSelected ? 35 : 30,
                decoration: BoxDecoration(
                  color: isCorrect ? Colors.green[500] : Colors.red[500],
                  shape: BoxShape.circle,
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ] : null,
                ),
                child: Center(
                  child: AnimatedDefaultTextStyle(
                    duration: Duration(milliseconds: 300),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isSelected ? 16 : 14,
                    ),
                    child: Text('$number'),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: isSelected ? 18 : 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                      child: Text(question),
                    ),
                    SizedBox(height: 10),
                    
                    Row(
                      children: [
                        Icon(
                          isCorrect ? Icons.check : Icons.close,
                          color: isCorrect ? Colors.green : Colors.red,
                          size: isSelected ? 18 : 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          quizProvider.selectedLanguage == 'ru' 
                            ? 'Ваш ответ: ' 
                            : 'Ihre Antwort: ',
                          style: TextStyle(
                            fontSize: isSelected ? 15 : 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        AnimatedDefaultTextStyle(
                          duration: Duration(milliseconds: 300),
                          style: TextStyle(
                            fontSize: isSelected ? 15 : 14,
                            fontWeight: FontWeight.w600,
                            color: isCorrect ? Colors.green[700] : Colors.red[700],
                          ),
                          child: Text(userAnswer),
                        ),
                      ],
                    ),
                    
                    if (!isCorrect) ...[
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            Icons.check,
                            color: Colors.green,
                            size: isSelected ? 18 : 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            quizProvider.selectedLanguage == 'ru' 
                              ? 'Правильный ответ: ' 
                              : 'Richtige Antwort: ',
                            style: TextStyle(
                              fontSize: isSelected ? 15 : 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          AnimatedDefaultTextStyle(
                            duration: Duration(milliseconds: 300),
                            style: TextStyle(
                              fontSize: isSelected ? 15 : 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.green[700],
                            ),
                            child: Text(correctAnswer),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          
          // Анимация появления дополнительной информации при выделении
          if (isSelected) ...[
            SizedBox(height: 10),
            AnimatedContainer(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeOut,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber[700], size: 20),
                  SizedBox(width: 8),
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
      padding: EdgeInsets.all(16),
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
          SizedBox(height: 12),
          
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
                    gradient: LinearGradient(
                      colors: [Colors.green.shade600, Colors.blue.shade600],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          
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
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          quizProvider.resetTest();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => BackgroundVideo(withSound: false, child: HomeScreen())),
            (Route<dynamic> route) => false,
          );
        },
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
            Icon(Icons.refresh_rounded),
            SizedBox(width: 8),
            Text(
              quizProvider.selectedLanguage == 'ru' 
                ? 'Пройти еще раз' 
                : 'Nochmal versuchen',
              style: TextStyle(
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
}