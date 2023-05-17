import 'dart:convert';

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
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    final jsonContent =
        await rootBundle.loadString('lib/question/general.json');
    print('teste' + jsonContent);
    final questionsMap = json.decode(jsonContent) as Map<String, dynamic>;
    final questions = (questionsMap['pt'] as List<dynamic>)
        .map((questionMap) =>
            Question(questionMap['question'], questionMap['answer']))
        .toList();
    setState(() {
      flashcard = Flashcard(questions);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
      ),
      body: flashcard != null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => setState(() => showAnswer = true),
                  child: Container(
                    width: 600,
                    height: 500,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
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
                    flashcard!.currentQuestion.answer,
                    style: const TextStyle(fontSize: 16),
                  ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
