import 'package:flutter/foundation.dart';

class QuizProvider with ChangeNotifier {
  String selectedLanguage = 'ru';
  List<int?> userAnswers = List.filled(15, null); // Измените на 15
  int currentQuestionIndex = 0;
  bool _testComplete = false;

  final List<Map<String, dynamic>> questions = [
    {
      'question': {
        'ru': 'Какое число должно быть следующим в последовательности: 2, 6, 12, 20, 30, ?',
        'de': 'Welche Zahl sollte in der Sequenz folgen: 2, 6, 12, 20, 30, ?'
      },
      'answers': {
        'ru': ['42', '40', '36', '44'],
        'de': ['42', '40', '36', '44']
      },
      'correctAnswer': 0
    },
    {
      'question': {
        'ru': 'Найдите лишнее слово: Яблоко, Банан, Апельсин, Морковь',
        'de': 'Finden Sie das überflüssige Wort: Apfel, Banane, Orange, Karotte'
      },
      'answers': {
        'ru': ['Яблоко', 'Банан', 'Апельсин', 'Морковь'],
        'de': ['Apfel', 'Banane', 'Orange', 'Karotte']
      },
      'correctAnswer': 3
    },
    {
      'question': {
        'ru': 'Если все ZAP являются MAP, и некоторые MAP являются TAP, то...',
        'de': 'Wenn alle ZAP MAP sind und einige MAP TAP sind, dann...'
      },
      'answers': {
        'ru': ['Все TAP являются ZAP', 'Некоторые ZAP являются TAP', 'Некоторые TAP являются ZAP', 'Все MAP являются ZAP'],
        'de': ['Alle TAP sind ZAP', 'Einige ZAP sind TAP', 'Einige TAP sind ZAP', 'Alle MAP sind ZAP']
      },
      'correctAnswer': 2
    },
    {
      'question': {
        'ru': 'Выберите противоположное слово: ХОЛОДНЫЙ',
        'de': 'Wählen Sie das gegenteilige Wort: KALT'
      },
      'answers': {
        'ru': ['Горячий', 'Теплый', 'Ледяной', 'Мерзлый'],
        'de': ['Heiß', 'Warm', 'Eisig', 'Gefroren']
      },
      'correctAnswer': 0
    },
    {
      'question': {
        'ru': 'Какая фигура следующая в последовательности? ◯ △ □ ◯ △ ?',
        'de': 'Welche Form folgt in der Sequenz? ◯ △ □ ◯ △ ?'
      },
      'answers': {
        'ru': ['□', '△', '◯', '☆'],
        'de': ['□', '△', '◯', '☆']
      },
      'correctAnswer': 0
    },
    {
      'question': {
        'ru': 'Решите: 7 × 8 - 12 ÷ 4 × 6',
        'de': 'Lösen Sie: 7 × 8 - 12 ÷ 4 × 6'
      },
      'answers': {
        'ru': ['44', '50', '38', '42'],
        'de': ['44', '50', '38', '42']
      },
      'correctAnswer': 0
    },
    {
      'question': {
        'ru': 'Найдите синоним слова "БЫСТРЫЙ"',
        'de': 'Finden Sie das Synonym für "SCHNELL"'
      },
      'answers': {
        'ru': ['Скорый', 'Медленный', 'Осторожный', 'Тихий'],
        'de': ['Rasch', 'Langsam', 'Vorsichtig', 'Leise']
      },
      'correctAnswer': 0
    },
    {
      'question': {
        'ru': 'Какое слово не относится к группе?',
        'de': 'Welches Wort gehört nicht zur Gruppe?'
      },
      'answers': {
        'ru': ['Стул', 'Стол', 'Диван', 'Телевизор'],
        'de': ['Stuhl', 'Tisch', 'Sofa', 'Fernseher']
      },
      'correctAnswer': 3
    },
    {
      'question': {
        'ru': 'Продолжите последовательность: A, C, E, G, ?',
        'de': 'Setzen Sie die Sequenz fort: A, C, E, G, ?'
      },
      'answers': {
        'ru': ['I', 'H', 'J', 'K'],
        'de': ['I', 'H', 'J', 'K']
      },
      'correctAnswer': 0
    },
    {
      'question': {
        'ru': 'Сколько углов у шестиугольника?',
        'de': 'Wie viele Ecken hat ein Sechseck?'
      },
      'answers': {
        'ru': ['6', '5', '7', '8'],
        'de': ['6', '5', '7', '8']
      },
      'correctAnswer': 0
    },
    // НОВЫЕ ВОПРОСЫ
    {
      'question': {
        'ru': 'Какое число следующее в последовательности: 1, 1, 2, 3, 5, 8, ?',
        'de': 'Welche Zahl folgt in der Sequenz: 1, 1, 2, 3, 5, 8, ?'
      },
      'answers': {
        'ru': ['13', '10', '11', '12'],
        'de': ['13', '10', '11', '12']
      },
      'correctAnswer': 0
    },
    {
      'question': {
        'ru': 'Найдите антоним слова "СВЕТЛЫЙ"',
        'de': 'Finden Sie das Antonym für "HELL"'
      },
      'answers': {
        'ru': ['Темный', 'Яркий', 'Белый', 'Чистый'],
        'de': ['Dunkel', 'Hell', 'Weiß', 'Sauber']
      },
      'correctAnswer': 0
    },
    {
      'question': {
        'ru': 'Решите: (15 - 5) × 2 + 8 ÷ 4',
        'de': 'Lösen Sie: (15 - 5) × 2 + 8 ÷ 4'
      },
      'answers': {
        'ru': ['22', '20', '24', '18'],
        'de': ['22', '20', '24', '18']
      },
      'correctAnswer': 0
    },
    {
      'question': {
        'ru': 'Какая фигура лишняя?',
        'de': 'Welche Form ist überflüssig?'
      },
      'answers': {
        'ru': ['Треугольник', 'Квадрат', 'Круг', 'Прямоугольник'],
        'de': ['Dreieck', 'Quadrat', 'Kreis', 'Rechteck']
      },
      'correctAnswer': 2
    },
    {
      'question': {
        'ru': 'Продолжите последовательность: 2, 4, 8, 16, ?',
        'de': 'Setzen Sie die Sequenz fort: 2, 4, 8, 16, ?'
      },
      'answers': {
        'ru': ['32', '24', '20', '18'],
        'de': ['32', '24', '20', '18']
      },
      'correctAnswer': 0
    }
  ];

  // Геттер для текущего вопроса
  Map<String, dynamic> get currentQuestionData => questions[currentQuestionIndex];

  // Геттер для проверки завершения теста
  bool get isTestComplete => _testComplete;

  // Геттер для номера текущего вопроса
  int get currentQuestion => currentQuestionIndex;

  void setLanguage(String language) {
    selectedLanguage = language;
    notifyListeners();
  }

  void setUserAnswer(int questionIndex, int answerIndex) {
    if (questionIndex >= 0 && questionIndex < userAnswers.length) {
      userAnswers[questionIndex] = answerIndex;
      notifyListeners();
    }
  }

  // Метод для ответа на вопрос и перехода к следующему
  void answerQuestion(int answerIndex) {
    setUserAnswer(currentQuestionIndex, answerIndex);
    
    // Проверяем, был ли это последний вопрос
    if (currentQuestionIndex >= questions.length - 1) {
      _testComplete = true;
    } else {
      currentQuestionIndex++;
    }
    notifyListeners();
  }

  int calculateScore() {
    int correctAnswers = 0;
    for (int i = 0; i < questions.length; i++) {
      if (userAnswers[i] == questions[i]['correctAnswer']) {
        correctAnswers++;
      }
    }
    return (correctAnswers / questions.length * 100).round();
  }

  void resetTest() {
    userAnswers = List.filled(questions.length, null); // Автоматически подстроится под новое количество
    currentQuestionIndex = 0;
    _testComplete = false;
    notifyListeners();
  }

  void nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      currentQuestionIndex++;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (currentQuestionIndex > 0) {
      currentQuestionIndex--;
      notifyListeners();
    }
  }

  bool get isLastQuestion => currentQuestionIndex == questions.length - 1;
  bool get isFirstQuestion => currentQuestionIndex == 0;
}