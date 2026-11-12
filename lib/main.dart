
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const TriviaApp());
}

class TriviaApp extends StatelessWidget {
  const TriviaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trivia Showdown',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: const TriviaScreen(),
    );
  }
}

class TriviaQuestion {
  final String question;
  final String correctAnswer;
  final List<String> options;

  TriviaQuestion({
    required this.question,
    required this.correctAnswer,
    required this.options,
  });

  factory TriviaQuestion.fromJson(Map<String, dynamic> json) {
    final correct = cleanText(json['correct_answer'] as String);

    final wrong = (json['incorrect_answers'] as List)
        .map((answer) => cleanText(answer as String))
        .toList();

    final choices = [...wrong, correct]..shuffle();

    return TriviaQuestion(
      question: cleanText(json['question'] as String),
      correctAnswer: correct,
      options: choices,
    );
  }
}

// Cleans HTML characters returned by the trivia API.
String cleanText(String text) {
  return text
      .replaceAll('&quot;', '"')
      .replaceAll('&#039;', "'")
      .replaceAll('&#39;', "'")
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&eacute;', 'é')
      .replaceAll('&ldquo;', '"')
      .replaceAll('&rdquo;', '"')
      .replaceAll('&lsquo;', "'")
      .replaceAll('&rsquo;', "'")
      .replaceAll('&lrm;', '')
      .replaceAll('&rlm;', '')
      .replaceAll('&#8206;', '')
      .replaceAll('&#8207;', '')
      .replaceAll('&nbsp;', ' ');
}

class TriviaScreen extends StatefulWidget {
  const TriviaScreen({super.key});

  @override
  State<TriviaScreen> createState() => _TriviaScreenState();
}

class _TriviaScreenState extends State<TriviaScreen> {
  List<TriviaQuestion> questions = [];

  int currentQuestion = 0;
  int score = 0;

  String? selectedAnswer;
  String? errorMessage;

  bool loading = true;
  bool syncing = false;
  bool synced = false;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  // Gets five trivia questions from the API.
  Future<void> fetchQuestions() async {
    setState(() {
      loading = true;
      errorMessage = null;
      questions = [];
      currentQuestion = 0;
      score = 0;
      selectedAnswer = null;
      synced = false;
      syncing = false;
    });

    try {
      final url = Uri.parse(
        'https://opentdb.com/api.php?amount=5&category=9&difficulty=easy&type=multiple',
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'HTTP error: ${response.statusCode}',
        );
      }

      final data = jsonDecode(response.body)
          as Map<String, dynamic>;

      if (data['response_code'] != 0) {
        throw Exception(
          'Trivia API could not return questions.',
        );
      }

      final results = data['results'] as List<dynamic>;

      if (results.length != 5) {
        throw Exception(
          'Expected five trivia questions.',
        );
      }

      final loadedQuestions = results
          .map(
            (item) => TriviaQuestion.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();

      if (!mounted) return;

      setState(() {
        questions = loadedQuestions;
        loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage =
            'Could not load questions. $error';
      });
    }
  }

  // Checks the answer and updates the score.
  void chooseAnswer(String answer) {
    if (selectedAnswer != null) return;

    setState(() {
      selectedAnswer = answer;

      if (answer ==
          questions[currentQuestion].correctAnswer) {
        score++;
      }
    });
  }

  // Moves to the next question.
  void nextQuestion() {
    setState(() {
      currentQuestion++;
      selectedAnswer = null;
    });
  }

  // Simulates sending the final score to a server.
  Future<void> syncScore() async {
    if (syncing || synced) return;

    final payload = {
      'score': score,
      'total': questions.length,
      'activity': 'Trivia Showdown',
    };

    setState(() {
      syncing = true;
    });

    // No real backend request is made.
    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (!mounted) return;

    setState(() {
      syncing = false;
      synced = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Simulated score sync: $payload',
        ),
      ),
    );
  }

  // Creates the answer buttons.
  Widget buildAnswerButton(
    String answer,
    TriviaQuestion question,
  ) {
    Color? backgroundColor;

    if (selectedAnswer != null) {
      if (answer == question.correctAnswer) {
        backgroundColor = Colors.green.shade200;
      } else if (answer == selectedAnswer) {
        backgroundColor = Colors.red.shade200;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: selectedAnswer == null
              ? () => chooseAnswer(answer)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            disabledBackgroundColor: backgroundColor,
            foregroundColor: Colors.black87,
            disabledForegroundColor: Colors.black87,
            padding: const EdgeInsets.all(16),
          ),
          child: Text(
            answer,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trivia Showdown'),
        backgroundColor: Colors.deepPurple.shade100,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: buildContent(),
        ),
      ),
    );
  }

  Widget buildContent() {
    // Loading screen.
    if (loading) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 15),
          Text('Loading trivia questions...'),
        ],
      );
    }

    // Error screen.
    if (errorMessage != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            errorMessage!,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: fetchQuestions,
            child: const Text('Try Again'),
          ),
        ],
      );
    }

    // Final score screen.
    if (currentQuestion >= questions.length) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.emoji_events,
            size: 65,
            color: Colors.deepPurple,
          ),
          const SizedBox(height: 15),
          const Text(
            'Round Complete!',
            style: TextStyle(fontSize: 26),
          ),
          const SizedBox(height: 15),
          Text(
            'Final Score: $score / ${questions.length}',
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 25),
          ElevatedButton(
            onPressed: syncing || synced
                ? null
                : syncScore,
            child: Text(
              syncing
                  ? 'Simulating Sync...'
                  : synced
                      ? 'Simulation Complete'
                      : 'Simulate Score Sync',
            ),
          ),
          if (synced)
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                'Score submission simulated. No cloud data was saved.',
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: fetchQuestions,
            child: const Text('Play Again'),
          ),
        ],
      );
    }

    // Current question screen.
    final question = questions[currentQuestion];

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Question ${currentQuestion + 1} of ${questions.length}',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: (currentQuestion + 1) /
                questions.length,
          ),
          const SizedBox(height: 15),
          Text(
            'Score: $score',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 25),
          Text(
            question.question,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Display all four answer choices.
          for (final answer in question.options)
            buildAnswerButton(answer, question),

          // Show feedback after an answer is selected.
          if (selectedAnswer != null) ...[
            const SizedBox(height: 15),
            Text(
              selectedAnswer == question.correctAnswer
                  ? 'Correct!'
                  : 'Incorrect! Correct answer: ${question.correctAnswer}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: nextQuestion,
              child: Text(
                currentQuestion ==
                        questions.length - 1
                    ? 'See Final Score'
                    : 'Next Question',
              ),
            ),
          ],
        ],
      ),
    );
  }
}
