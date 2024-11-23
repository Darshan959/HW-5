import 'dart:async';
import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/api_service.dart';

class QuizScreen extends StatefulWidget {
  final int numQuestions;
  final String category;
  final String difficulty;
  final String type;

  const QuizScreen({
    super.key,
    required this.numQuestions,
    required this.category,
    required this.difficulty,
    required this.type,
  });

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _loading = true;
  bool _answered = false;
  String _feedbackText = "";
  late Timer _timer;
  int _timeLeft = 15;

  final List<Map<String, String>> _questionFeedback = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await ApiService.fetchQuestions(
        widget.numQuestions,
        widget.category,
        widget.difficulty,
        widget.type,
      );
      setState(() {
        _questions = questions;
        _loading = false;
        _startTimer();
      });
    } catch (e) {
      print(e);
    }
  }

  void _startTimer() {
    _timeLeft = 15;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _submitAnswer(""); // Mark as incorrect if no answer is selected
          timer.cancel();
        }
      });
    });
  }

  void _submitAnswer(String selectedAnswer) {
    _timer.cancel();
    setState(() {
      _answered = true;
      final correctAnswer = _questions[_currentQuestionIndex].correctAnswer;

      if (selectedAnswer == correctAnswer) {
        _score++;
        _feedbackText = "Correct!";
        _questionFeedback.add({
          'question': _questions[_currentQuestionIndex].question,
          'selected': selectedAnswer,
          'correct': correctAnswer,
          'status': 'Correct'
        });
      } else if (selectedAnswer.isEmpty) {
        _feedbackText = "Time's up!";
        _questionFeedback.add({
          'question': _questions[_currentQuestionIndex].question,
          'selected': 'No Answer',
          'correct': correctAnswer,
          'status': 'Missed'
        });
      } else {
        _feedbackText = "Incorrect!";
        _questionFeedback.add({
          'question': _questions[_currentQuestionIndex].question,
          'selected': selectedAnswer,
          'correct': correctAnswer,
          'status': 'Incorrect'
        });
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      _answered = false;
      _feedbackText = "";
      _currentQuestionIndex++;

      if (_currentQuestionIndex < _questions.length) {
        _startTimer();
      }
    });
  }

  Widget _buildSummaryScreen() {
    return Scaffold(
      appBar: AppBar(title: Text("Quiz Summary")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quiz Finished!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('Your Score: $_score/${_questions.length}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _questionFeedback.length,
                itemBuilder: (context, index) {
                  final feedback = _questionFeedback[index];
                  return Card(
                    elevation: 4,
                    child: ListTile(
                      title: Text(feedback['question']!),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Your Answer: ${feedback['selected']}"),
                          Text("Correct Answer: ${feedback['correct']}"),
                          Text("Status: ${feedback['status']}"),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pop(context), // Back to Setup Screen
                  child: Text("Back to Setup"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(
                          numQuestions: widget.numQuestions,
                          category: widget.category,
                          difficulty: widget.difficulty,
                          type: widget.type,
                        ),
                      ),
                    );
                  },
                  child: Text("Retake Quiz"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentQuestionIndex >= _questions.length) {
      return _buildSummaryScreen();
    }

    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(title: Text("Quiz App")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _questions.length,
              backgroundColor: Colors.grey[300],
              color: Theme.of(context).hintColor,
            ),
            SizedBox(height: 16),
            Text('Score: $_score', style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Text('Time Left: $_timeLeft seconds',
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  question.question,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            SizedBox(height: 16),
            ...question.options.map((option) {
              return ElevatedButton(
                onPressed: _answered ? null : () => _submitAnswer(option),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  textStyle: TextStyle(fontSize: 16),
                ),
                child: Text(option),
              );
            }),
            SizedBox(height: 16),
            if (_answered)
              Text(
                _feedbackText,
                style: TextStyle(
                  fontSize: 18,
                  color:
                      _feedbackText == "Correct!" ? Colors.green : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            if (_answered)
              ElevatedButton(
                onPressed: _nextQuestion,
                child: Text("Next Question"),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
