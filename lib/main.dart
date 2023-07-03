import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = MaterialColor(
      0xFF2E7D32, // Valor da cor primária
      <int, Color>{
        50: Color(0xFFE8F5E9),
        100: Color(0xFFC8E6C9),
        200: Color(0xFFA5D6A7),
        300: Color(0xFF81C784),
        400: Color(0xFF66BB6A),
        500: Color(0xFF4CAF50),
        600: Color(0xFF43A047),
        700: Color(0xFF388E3C),
        800: Color(0xFF2E7D32),
        900: Color(0xFF1B5E20),
      },
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FlapCard',
      theme: ThemeData(
        primarySwatch: primaryColor,
      ),
      home: const FlashcardApp(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('pt', ''),
        const Locale('es', ''),
      ],
    );
  }
}

class Question {
  final String question;
  final String answer;

  Question(this.question, this.answer);
}

class Config {
  final String btcorrect;
  final String btincorrect;
  final String btnanswercorrect;
  final String btnanswerincorrect;
  final String btnfim;
  final String btnrestart;
  final String btncontinue;
  final String btnincorrectthree;
  final String btncorrectthree;
  final String btncheers;
  final String btnsmarty;
  final String btnplay;

  Config(
      this.btcorrect,
      this.btincorrect,
      this.btnanswercorrect,
      this.btnanswerincorrect,
      this.btnfim,
      this.btnrestart,
      this.btncontinue,
      this.btncorrectthree,
      this.btnincorrectthree,
      this.btncheers,
      this.btnsmarty,
      this.btnplay);
}

class Flashcard {
  final List<Question> questions;
  int currentIndex = 0;

  Flashcard(this.questions);

  Question get currentQuestion => questions[currentIndex];

  void nextQuestion() {
    currentIndex = (currentIndex + 1) % questions.length;
  }
}

class FlashcardApp extends StatefulWidget {
  const FlashcardApp({Key? key}) : super(key: key);

  @override
  _FlashcardAppState createState() => _FlashcardAppState();
}

class _FlashcardAppState extends State<FlashcardApp> {
  Flashcard? flashcard;
  bool showAnswer = false;
  int _selectedIndex = 0;
  late Config buttonConfig = Config(
      'Correto',
      'Incorreto',
      'Respostar corretas:',
      'Respostas incorretas:',
      'Fim das perguntas',
      'Reiniciar',
      'Continuar',
      'Você acertou 3 perguntas!',
      'Você errou 3 perguntas!',
      'Todos devem beber, saúde',
      'Espertinho, saúde!',
      'Jogar');
  String currentLanguage = 'pt';
  late Map<String, List<Question>> questionsMap;

  int correctCount = 0;
  int incorrectCount = 0;

  late Timer _timer;
  int _secondsRemaining = 20;

  @override
  void initState() {
    super.initState();
    loadConfig();
    loadQuestions();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 0),
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'lib/img/fundo_ini.png',
                    width: 300,
                    height: 300,
                  ),
                  Positioned(
                    bottom: 30,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _secondsRemaining = 20;
                        _startTimer();
                      },
                      child: Text('Jogar'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 25,
                        ),
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        primary: Colors.green[800], // Cor do botão
                        onPrimary: Colors.white, // Cor do texto do botão
                      ),
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: IconButton(
                      onPressed: () {
                        _toggleLanguage();
                      },
                      icon: const Icon(
                        Icons.language,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          contentPadding: const EdgeInsets.all(20),
        ),
      );
    });
  }

  Future<void> loadQuestions() async {
    final jsonContent =
        await rootBundle.loadString('lib/question/general.json');
    final jsonMap = json.decode(jsonContent) as Map<String, dynamic>;
    questionsMap = jsonMap.map((key, value) {
      final questions = (value as List<dynamic>).map((questionMap) {
        if (questionMap is Map<String, dynamic>) {
          return Question(questionMap['question'], questionMap['answer']);
        } else {
          throw ArgumentError('Invalid question format');
        }
      }).toList();
      return MapEntry(key, questions);
    });

    setState(() {
      flashcard = Flashcard(questionsMap[currentLanguage]!);
    });
  }

  Future<void> loadConfig() async {
    final jsonContent = await rootBundle.loadString('lib/question/config.json');
    final configMap = json.decode(jsonContent) as Map<String, dynamic>;
    final config = configMap[currentLanguage];
    setState(() {
      buttonConfig = Config(
          config[0]['btcorrect'],
          config[0]['btincorrect'],
          config[0]['btnanswercorrect'],
          config[0]['btnanswerincorrect'],
          config[0]['btnfim'],
          config[0]['btnrestart'],
          config[0]['btncontinue'],
          config[0]['btncorrectthree'],
          config[0]['btnincorrectthree'],
          config[0]['btncheers'],
          config[0]['btnsmarty'],
          config[0]['btnplay']);
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer.cancel();
        setState(() {
          showAnswer = true;
        });
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      if (flashcard != null) {
        final isLastQuestion =
            flashcard!.currentIndex == flashcard!.questions.length - 1;

        if (isLastQuestion) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: buttonConfig != null
                  ? Text('${buttonConfig.btnfim}')
                  : const Text(''),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${buttonConfig.btnanswercorrect}: $correctCount'),
                  Text('${buttonConfig.btnanswerincorrect}: $incorrectCount'),
                  Image.asset('lib/gif/need.gif')
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Fecha o diálogo
                    setState(() {
                      flashcard!.currentIndex = 0;
                      correctCount = 0;
                      incorrectCount = 0;
                    });
                    _secondsRemaining = 20;
                  },
                  child: buttonConfig != null
                      ? Text('${buttonConfig.btnrestart}')
                      : const Text(''),
                ),
              ],
            ),
          );
        } else {
          if (index == 0) {
            flashcard!.nextQuestion();
            showAnswer = false;
            _secondsRemaining = 20;
            incorrectCount++;
            if (incorrectCount % 3 == 0 && incorrectCount > 0) {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: buttonConfig != null
                      ? Text('${buttonConfig.btnincorrectthree}')
                      : const Text(''),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      buttonConfig != null
                          ? Text('${buttonConfig.btncheers}')
                          : const Text(''),
                      const SizedBox(height: 40),
                      Image.asset('lib/gif/ah.gif'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _secondsRemaining = 20;
                      },
                      child: buttonConfig != null
                          ? Text('${buttonConfig.btncontinue}')
                          : const Text(''),
                    ),
                  ],
                ),
              );
            }
          } else if (index == 1) {
            flashcard!.nextQuestion();
            showAnswer = false;
            _secondsRemaining = 20;
            correctCount++;
            if (correctCount % 3 == 0 && correctCount > 0) {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: buttonConfig != null
                      ? Text('${buttonConfig.btncorrectthree}')
                      : const Text(''),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      buttonConfig != null
                          ? Text('${buttonConfig.btnsmarty}')
                          : const Text(''),
                      const SizedBox(height: 40),
                      Image.asset('lib/gif/graveto.gif'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        _secondsRemaining = 20;
                        Navigator.pop(context);
                      },
                      child: buttonConfig != null
                          ? Text('${buttonConfig.btncontinue}')
                          : const Text(''),
                    ),
                  ],
                ),
              );
            }
          }
        }
      }
      if (_timer == null || !_timer.isActive) {
        _startTimer();
      }
      _selectedIndex = index;
    });
  }

  void _toggleLanguage() {
    setState(() {
      _secondsRemaining = 20;
      currentLanguage = currentLanguage == 'pt'
          ? 'en'
          : (currentLanguage == 'en' ? 'es' : 'pt');
      loadConfig();
    });

    setState(() {
      flashcard = Flashcard(questionsMap[currentLanguage]!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${buttonConfig.btcorrect}: $correctCount'),
            Text('$_secondsRemaining s'),
            Text('${buttonConfig.btincorrect}: $incorrectCount'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _toggleLanguage(),
            icon: const Icon(Icons.language),
          ),
        ],
      ),
      body: flashcard != null
          ? GestureDetector(
              onTap: () => setState(() => showAnswer = true),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 500,
                          height: 600,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                showAnswer
                                    ? 'lib/img/carta.png'
                                    : 'lib/img/carta_fund.png',
                              ),
                              fit: BoxFit.fill,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(130.0),
                            child: Center(
                              child: Text(
                                showAnswer
                                    ? flashcard!.currentQuestion.answer
                                    : flashcard!.currentQuestion.question,
                                style: TextStyle(
                                  fontSize: 30,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black, // Cor da sombra
                                      offset: Offset(3, 4),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (showAnswer)
                          Text(
                            flashcard!.currentQuestion.question,
                            style: const TextStyle(fontSize: 16),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
      bottomNavigationBar: BottomAppBar(
        color: Colors.green[900],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () => _onItemTapped(0),
              icon: Icon(Icons.close),
              color: Colors.red,
            ),
            IconButton(
              onPressed: () => _onItemTapped(1),
              icon: Icon(Icons.check),
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}
