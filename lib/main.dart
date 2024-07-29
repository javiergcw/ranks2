/* import 'package:flutter/material.dart';
import 'package:rank_usa/dto/list_question.dart';
import 'dart:math';

import 'package:rank_usa/dto/quiz_question.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: QuizPage(),
    );
  }
}

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentQuestionIndex = 0;
  List<QuizQuestion> quizQuestions = getQuizQuestions();
  bool answered = false;
  bool correct = false;

  List<String> getOptions(QuizQuestion currentQuestion) {
    List<String> options = quizQuestions.map((q) => q.correctAnswer).toList();
    options.remove(currentQuestion.correctAnswer);
    options.shuffle();
    return options.take(3).toList() + [currentQuestion.correctAnswer]
      ..shuffle();
  }

  void checkAnswer(String selectedAnswer, String correctAnswer) {
    setState(() {
      answered = true;
      correct = selectedAnswer == correctAnswer;
    });
  }

  void nextQuestion() {
    setState(() {
      if (currentQuestionIndex < quizQuestions.length - 1) {
        currentQuestionIndex++;
      } else {
        currentQuestionIndex = 0; // Reset quiz or show results
      }
      answered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    QuizQuestion currentQuestion = quizQuestions[currentQuestionIndex];
    List<String> options = getOptions(currentQuestion);

    return Scaffold(
      appBar: AppBar(
        title: Text('Military Ranks Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              currentQuestion.question,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.0),
            Container(
                height: 100,
                width: 100,
                child: Image.asset(currentQuestion.imagePath)),
            SizedBox(height: 20.0),
            ...options.map((option) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                ),
                child: ElevatedButton(
                  onPressed: answered
                      ? null
                      : () =>
                          checkAnswer(option, currentQuestion.correctAnswer),
                  child: Text(option),
                ),
              );
            }).toList(),
            if (answered)
              Column(
                children: [
                  Text(
                    correct
                        ? 'Correct!'
                        : 'Incorrect! The correct answer is ${currentQuestion.correctAnswer}.',
                    style: TextStyle(
                      color: correct ? Colors.green : Colors.red,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: nextQuestion,
                    child: const Text('Next Question'),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}
 */

import 'package:flutter/material.dart';
import 'package:rank_usa/dto/list_question.dart';
import 'dart:async';

import 'package:rank_usa/dto/quiz_question.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LevelSelectionPage(),
    );
  }
}

class LevelSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Level'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizPage(isTimed: false),
                  ),
                );
              },
              child: const Text('No Time Limit'),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => TimeSelectionDialog(),
                );
              },
              child: const Text('Time Limit'),
            ),
          ],
        ),
      ),
    );
  }
}

class TimeSelectionDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Time per Question'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          6,
          (index) => ListTile(
            title: Text('${(index + 1) * 10} seconds'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      QuizPage(isTimed: true, timeLimit: (index + 1) * 10),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class QuizPage extends StatefulWidget {
  final bool isTimed;
  final int? timeLimit;

  QuizPage({required this.isTimed, this.timeLimit});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentQuestionIndex = 0;
  List<QuizQuestion> quizQuestions = getQuizQuestions();
  bool answered = false;
  bool correct = false;
  Timer? timer;
  int remainingTime = 0;
  int score = 0;
  List<String> incorrectAnswers = [];
  List<String> options = [];

  @override
  void initState() {
    super.initState();
    generateOptions();
    if (widget.isTimed) {
      startTimer();
    }
  }

  void generateOptions() {
    options = getOptions(quizQuestions[currentQuestionIndex]);
  }

  void startTimer() {
    setState(() {
      remainingTime = widget.timeLimit!;
    });
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--;
        } else {
          timer.cancel();
          markAnswer(false);
        }
      });
    });
  }

  void checkAnswer(String selectedAnswer, String correctAnswer) {
    timer?.cancel();
    markAnswer(selectedAnswer == correctAnswer);
  }

  void markAnswer(bool isCorrect) {
    setState(() {
      answered = true;
      correct = isCorrect;
      if (isCorrect) {
        score++;
      } else {
        incorrectAnswers.add(quizQuestions[currentQuestionIndex].question);
      }
    });
  }

  void nextQuestion() {
    setState(() {
      if (currentQuestionIndex < quizQuestions.length - 1) {
        currentQuestionIndex++;
      } else {
        showResults();
        return;
      }
      answered = false;
      generateOptions();
      if (widget.isTimed) {
        startTimer();
      }
    });
  }

  void showResults() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsPage(
          score: score,
          incorrectAnswers: incorrectAnswers,
          quizQuestions: quizQuestions,
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    QuizQuestion currentQuestion = quizQuestions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Military Ranks Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              currentQuestion.question,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.0),
            Container(
              height: 100,
              width: 100,
              child: Image.asset(currentQuestion.imagePath),
            ),
            SizedBox(height: 20.0),
            if (widget.isTimed)
              Text(
                'Time remaining: $remainingTime seconds',
                style: TextStyle(fontSize: 16.0, color: Colors.red),
              ),
            ...options.map((option) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ElevatedButton(
                  onPressed: answered
                      ? null
                      : () =>
                          checkAnswer(option, currentQuestion.correctAnswer),
                  child: Text(option),
                ),
              );
            }).toList(),
            if (answered)
              Column(
                children: [
                  Text(
                    correct
                        ? 'Correct!'
                        : 'Incorrect! The correct answer is ${currentQuestion.correctAnswer}.',
                    style: TextStyle(
                      color: correct ? Colors.green : Colors.red,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: nextQuestion,
                    child: const Text('Next Question'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  List<String> getOptions(QuizQuestion currentQuestion) {
    List<String> options = quizQuestions.map((q) => q.correctAnswer).toList();
    options.remove(currentQuestion.correctAnswer);
    options.shuffle();
    return options.take(3).toList() + [currentQuestion.correctAnswer]
      ..shuffle();
  }
}

class ResultsPage extends StatelessWidget {
  final int score;
  final List<String> incorrectAnswers;
  final List<QuizQuestion> quizQuestions; // Añadido para recibir las preguntas

  ResultsPage({
    required this.score,
    required this.incorrectAnswers,
    required this.quizQuestions, // Añadido para recibir las preguntas
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Results'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Your Score: $score',
              style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
