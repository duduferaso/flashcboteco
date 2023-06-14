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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FlapCard',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const FlashcardApp(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('pt', ''),
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

  Config(this.btcorrect, this.btincorrect);
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
  late Config buttonConfig;
  String currentLanguage = 'pt';
  late Map<String, List<Question>> questionsMap;

  int correctCount = 0;
  int incorrectCount = 0;

  late Timer _timer;
  int _secondsRemaining = 20;

  @override
  void initState() {
    super.initState();
    loadQuestions();
    loadConfig();
    _startTimer();
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
      buttonConfig = Config(config[0]['btcorrect'], config[0]['btincorrect']);
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
              title: const Text('Fim das perguntas'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Respostas corretas: $correctCount'),
                  Text('Respostas incorretas: $incorrectCount'),
                  Image.asset('lib/gif/need.gif')
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Fecha o diálogo
                    _secondsRemaining = 20;
                    setState(() {
                      flashcard!.currentIndex = 0;
                      correctCount = 0;
                      incorrectCount = 0;
                    });
                  },
                  child: const Text('Reiniciar'),
                ),
              ],
            ),
          );
        } else {
          // Incrementa os contadores de acordo com o índice selecionado
          if (index == 0) {
            flashcard!.nextQuestion();
            showAnswer = false;
            _secondsRemaining = 20;
            incorrectCount++; // Incrementa o contador de respostas incorretas

            if (incorrectCount % 3 == 0 && incorrectCount > 0) {
              // Exibe a mensagem de erro após 3 respostas incorretas
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Você errou 3 perguntas!'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Todos devem beber, saúde!'),
                      const SizedBox(height: 40),
                      Image.asset('lib/gif/ah.gif'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Fecha o diálogo
                        _secondsRemaining = 20;
                      },
                      child: const Text('Continuar'),
                    ),
                  ],
                ),
              );
            }
          } else if (index == 1) {
            flashcard!.nextQuestion();
            showAnswer = false;
            _secondsRemaining = 20;
            correctCount++; // Incrementa o contador de respostas corretas
            if (correctCount % 3 == 0 && correctCount > 0) {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Você acertou 3 perguntas!'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Espertinho, saúde!'),
                      const SizedBox(height: 40),
                      Image.asset('lib/gif/graveto.gif'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Fecha o diálogo
                        _secondsRemaining = 20;
                      },
                      child: const Text('Continuar'),
                    ),
                  ],
                ),
              );
            }
          }
        }
      }
      _selectedIndex = index;
    });
  }

  void _toggleLanguage() {
    setState(() {
      _secondsRemaining = 20;
      currentLanguage = currentLanguage == 'pt' ? 'en' : 'pt';
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
            // Text('Correct: $correctCount'),
            // Text('$_secondsRemaining s'),
            // Text('Incorrect: $incorrectCount'),
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
          ? SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => showAnswer = true),
                        child: Container(
                          width: 600,
                          height: 500,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.green,
                                spreadRadius: 5,
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              )
                            ],
                          ),
                          child: Center(
                            child: Text(
                              showAnswer
                                  ? flashcard!.currentQuestion.answer
                                  : flashcard!.currentQuestion.question,
                              style: const TextStyle(fontSize: 20),
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
            )
          : const Center(child: CircularProgressIndicator()),
      bottomNavigationBar: BottomAppBar(
        color: Colors.green,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () => _onItemTapped(0),
              icon: Icon(Icons.close),
              color: Colors.white,
            ),
            IconButton(
              onPressed: () => _onItemTapped(1),
              icon: Icon(Icons.check),
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
