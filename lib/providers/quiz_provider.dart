import 'package:flutter/foundation.dart';
import 'dart:math';

class QuizProvider with ChangeNotifier {
  String selectedLanguage = 'ru';
  List<int?> userAnswers = [];
  int currentQuestionIndex = 0;
  bool _testComplete = false;
  final Random _random = Random();

  // Исходные вопросы (не перемешанные)
  final List<Map<String, dynamic>> _originalQuestions = [
    {
      'question': {
        'ru': 'Какое число должно быть следующим в последовательности: 2, 6, 12, 20, 30, ?',
        'de': 'Welche Zahl sollte in der Sequenz folgen: 2, 6, 12, 20, 30, ?'
      },
      'answers': {
        'ru': ['42', '40', '36', '44'],
        'de': ['42', '40', '36', '44']
      },
      'correctAnswer': 0,
      'explanation': {
        'ru': 'Разность между числами: 4, 6, 8, 10 → следующая разность 12 → 30 + 12 = 42',
        'de': 'Differenz zwischen Zahlen: 4, 6, 8, 10 → nächste Differenz 12 → 30 + 12 = 42'
      }
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
      'correctAnswer': 3,
      'explanation': {
        'ru': 'Морковь - это овощ, остальные - фрукты',
        'de': 'Karotte ist ein Gemüse, die anderen sind Früchte'
      }
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
      'correctAnswer': 1,
      'explanation': {
        'ru': 'Если все ZAP - MAP и некоторые MAP - TAP, то некоторые ZAP могут быть TAP',
        'de': 'Wenn alle ZAP MAP sind und einige MAP TAP sind, dann können einige ZAP TAP sein'
      }
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
      'correctAnswer': 0,
      'explanation': {
        'ru': 'Прямая противоположность "холодного" - "горячий"',
        'de': 'Das direkte Gegenteil von "kalt" ist "heiß"'
      }
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
      'correctAnswer': 0,
      'explanation': {
        'ru': 'Последовательность: ◯ △ □ повторяется',
        'de': 'Sequenz: ◯ △ □ wiederholt sich'
      }
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
      'correctAnswer': 2,
      'explanation': {
        'ru': '7×8=56, 12÷4=3, 3×6=18, 56-18=38',
        'de': '7×8=56, 12÷4=3, 3×6=18, 56-18=38'
      }
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
      'correctAnswer': 0,
      'explanation': {
        'ru': '"Скорый" - прямой синоним слова "быстрый"',
        'de': '"Rasch" ist ein direktes Synonym für "schnell"'
      }
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
      'correctAnswer': 3,
      'explanation': {
        'ru': 'Телевизор - электроника, остальное - мебель',
        'de': 'Fernseher ist Elektronik, der Rest ist Möbel'
      }
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
      'correctAnswer': 0,
      'explanation': {
        'ru': 'Буквы через одну: A, C, E, G, I',
        'de': 'Buchstaben jede zweite: A, C, E, G, I'
      }
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
      'correctAnswer': 0,
      'explanation': {
        'ru': 'Шестиугольник имеет 6 углов',
        'de': 'Ein Sechseck hat 6 Ecken'
      }
    },
    {
      'question': {
        'ru': 'Какое число следующее в последовательности: 1, 1, 2, 3, 5, 8, ?',
        'de': 'Welche Zahl folgt in der Sequenz: 1, 1, 2, 3, 5, 8, ?'
      },
      'answers': {
        'ru': ['13', '10', '11', '12'],
        'de': ['13', '10', '11', '12']
      },
      'correctAnswer': 0,
      'explanation': {
        'ru': 'Последовательность Фибоначчи: 1+1=2, 1+2=3, 2+3=5, 3+5=8, 5+8=13',
        'de': 'Fibonacci-Folge: 1+1=2, 1+2=3, 2+3=5, 3+5=8, 5+8=13'
      }
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
      'correctAnswer': 0,
      'explanation': {
        'ru': 'Прямой антоним "светлого" - "темный"',
        'de': 'Das direkte Antonym von "hell" ist "dunkel"'
      }
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
      'correctAnswer': 0,
      'explanation': {
        'ru': '(15-5)=10, 10×2=20, 8÷4=2, 20+2=22',
        'de': '(15-5)=10, 10×2=20, 8÷4=2, 20+2=22'
      }
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
      'correctAnswer': 2,
      'explanation': {
        'ru': 'Круг - единственная фигура без углов',
        'de': 'Kreis ist die einzige Form ohne Ecken'
      }
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
      'correctAnswer': 0,
      'explanation': {
        'ru': 'Каждое число умножается на 2: 2×2=4, 4×2=8, 8×2=16, 16×2=32',
        'de': 'Jede Zahl wird mit 2 multipliziert: 2×2=4, 4×2=8, 8×2=16, 16×2=32'
      }
    }
  ];

  // Перемешанные вопросы (это то, что видит пользователь)
  List<Map<String, dynamic>> questions = [];

  QuizProvider() {
    _shuffleQuestions();
  }

  // Метод для перемешивания вопросов и ответов
  void _shuffleQuestions() {
    // Создаем копию оригинальных вопросов
    questions = List<Map<String, dynamic>>.from(_originalQuestions);
    
    // Перемешиваем порядок вопросов
    questions.shuffle(_random);
    
    // Для каждого вопроса перемешиваем варианты ответов
    for (var question in questions) {
      _shuffleAnswers(question);
    }
    
    // Инициализируем userAnswers после перемешивания
    userAnswers = List.filled(questions.length, null);
  }

  // Метод для перемешивания ответов в одном вопросе
  void _shuffleAnswers(Map<String, dynamic> question) {
    final originalCorrectIndex = question['correctAnswer'];
    final languages = ['ru', 'de'];
    
    // Создаем список индексов ответов
    final answerCount = question['answers']['ru'].length;
    final indices = List<int>.generate(answerCount, (i) => i);
    indices.shuffle(_random);
    
    // Создаем новые списки ответов для каждого языка
    final newAnswers = <String, List<String>>{};
    
    for (final language in languages) {
      final originalAnswers = List<String>.from(question['answers'][language]);
      final shuffledAnswers = <String>[];
      
      for (final index in indices) {
        shuffledAnswers.add(originalAnswers[index]);
      }
      
      newAnswers[language] = shuffledAnswers;
    }
    
    // Находим новый индекс правильного ответа
    final newCorrectIndex = indices.indexOf(originalCorrectIndex);
    
    // Обновляем вопрос
    question['answers'] = newAnswers;
    question['correctAnswer'] = newCorrectIndex;
  }

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

  // Метод для расчета IQ баллов (100 + за каждый правильный ответ)
  int calculateIQScore() {
    int correctAnswers = 0;
    for (int i = 0; i < questions.length; i++) {
      if (userAnswers[i] == questions[i]['correctAnswer']) {
        correctAnswers++;
      }
    }
    // Базовый IQ 100 + 2 балла за каждый правильный ответ
    return 100 + (correctAnswers * 2);
  }

  void resetTest() {
    // Перемешиваем вопросы заново при сбросе теста
    _shuffleQuestions();
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

  // Метод для получения количества правильных ответов
  int get correctAnswersCount {
    int count = 0;
    for (int i = 0; i < questions.length; i++) {
      if (userAnswers[i] == questions[i]['correctAnswer']) {
        count++;
      }
    }
    return count;
  }

  // Метод для проверки, ответил ли пользователь на все вопросы
  bool get allQuestionsAnswered {
    return !userAnswers.any((answer) => answer == null);
  }

  // Отладочный метод для проверки подсчета очков
  void debugScoreCalculation() {
    int correct = 0;
    List<int> correctIndices = [];
    
    for (int i = 0; i < questions.length; i++) {
      if (userAnswers[i] == questions[i]['correctAnswer']) {
        correct++;
        correctIndices.add(i + 1);
      }
    }
    
    if (kDebugMode) {
      print('=== DEBUG SCORE CALCULATION ===');
      print('Всего вопросов: ${questions.length}');
      print('Правильных ответов: $correct');
      print('Правильные вопросы: $correctIndices');
      print('Процент: ${(correct / questions.length * 100).round()}%');
      print('IQ Score: ${100 + (correct * 2)}');
      print('userAnswers: $userAnswers');
      print('===============================');
    }
  }
}