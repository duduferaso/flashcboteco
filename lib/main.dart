import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
  final String buttoncorrect;
  final String buttonincorrect;

  Config(this.buttoncorrect, this.buttonincorrect);
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

  int correctCount = 0;
  int incorrectCount = 0;

  late Timer _timer;
  int _secondsRemaining = 20;

  @override
  void initState() {
    super.initState();
    loadQuestions();
    _startTimer();
  }

  Future<void> loadQuestions() async {
    final jsonContent =
        await rootBundle.loadString('lib/question/general.json');
    final questionsMap = json.decode(jsonContent) as Map<String, dynamic>;
    final questions = (questionsMap['pt'] as List<dynamic>)
        .map((questionMap) =>
            Question(questionMap['question'], questionMap['answer']))
        .toList();
    setState(() {
      flashcard = Flashcard(questions);
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
          // Exibe a mensagem de fim e reinicia os contadores
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Fim das perguntas'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Respostas corretas: $correctCount'),
                  Text('Respostas incorretas: $incorrectCount'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Fecha o diálogo
                    _secondsRemaining = 20;
                    setState(() {
                      flashcard!.currentIndex =
                          0; // Reinicia o índice das perguntas
                      correctCount =
                          0; // Reinicia o contador de respostas corretas
                      incorrectCount =
                          0; // Reinicia o contador de respostas incorretas
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
          } else if (index == 1) {
            flashcard!.nextQuestion();
            showAnswer = false;
            _secondsRemaining = 20;
            correctCount++; // Incrementa o contador de respostas corretas
          }
        }
      }
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Correct: $correctCount'),
            Text('$_secondsRemaining s'),
            Text('Incorrect: $incorrectCount'),
          ],
        ),
      ),
      body: flashcard != null
          ? Align(
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
            )
          : const Center(child: CircularProgressIndicator()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.close), label: 'Incorrect'),
          BottomNavigationBarItem(icon: Icon(Icons.check), label: 'Correct'),
        ],
      ),
    );
  }
}
