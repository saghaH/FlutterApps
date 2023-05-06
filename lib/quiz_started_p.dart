import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuizStartedP extends StatefulWidget {
  final String quizId;
  final String Username;

  const QuizStartedP({Key? key, required this.quizId, required this.Username})
      : super(key: key);

  @override
  _QuizStartedPState createState() => _QuizStartedPState();
}

class _QuizStartedPState extends State<QuizStartedP> {
  late List<QueryDocumentSnapshot> _questions = [];
  late List<List<QueryDocumentSnapshot>> _answerDocsList = [];
  late DocumentReference<Object?>? _selectedAnswerRef = null;
  late List<Map<String, dynamic>> _selectedAnswers = [];
  late int _currentIndex = 0;
  late Timer _timer;
  late int _timeLeft = 0;
  late int score = 0;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    final questionsSnapshot = await FirebaseFirestore.instance
        .collection('Questions')
        .where('quizId', isEqualTo: widget.quizId)
        .get();

    for (final question in questionsSnapshot.docs) {
      final answersSnapshot =
          await question.reference.collection('Answers').get();
      setState(() {
        _questions.add(question);
        _answerDocsList.add(answersSnapshot.docs);
      });
    }
    _startTimer();
  }

  void _startTimer() {
    _timeLeft = _questions[_currentIndex].get('time') as int;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _moveToNextQuestion();
        }
      });
    });
  }

  Future<void> _moveToNextQuestion() async {
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      _timeLeft = _questions[_currentIndex].get('time') as int;
      //_selectedAnswerRef = null;
      final selectedAnswer =
          _selectedAnswerRef == null ? null : _selectedAnswerRef!.id;

      final questionId = _questions[_currentIndex - 1].id;
      final questionDoc =
          FirebaseFirestore.instance.collection('Questions').doc(questionId);
      final snapshot = await questionDoc.get();
      final pts = snapshot['points'] as int;
      final answerDocs = questionDoc.collection('Answers');

      final correctAnswerDoc = await answerDocs
          .where('correct', isEqualTo: true)
          .get()
          .then((querySnapshot) {
        return querySnapshot.docs.first;
      });

      final correctAnswerId = correctAnswerDoc.id;
      if (correctAnswerId == selectedAnswer) {
        score = score + pts;
      } else {
        final correctAnswerText = correctAnswerDoc.get('answer').toString();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text("Incorrect. The correct answer was '$correctAnswerText'."),
          duration: Duration(seconds: 2),
        ));
      }

      final quizSubmissionRef =
          FirebaseFirestore.instance.collection('QuizSubmissions').doc();
      await quizSubmissionRef.set({
        'username': widget.Username,
        'quizId': widget.quizId,
        'questionId': _questions[_currentIndex].id,
        'selectedAnswers': selectedAnswer,
      });
    } else {
      _timer.cancel();
      final selectedAnswer =
          _selectedAnswerRef == null ? null : _selectedAnswerRef!.id;
      final quizSubmissionRef =
          FirebaseFirestore.instance.collection('QuizSubmissions').doc();
      await quizSubmissionRef.set({
        'username': widget.Username,
        'quizId': widget.quizId,
        'questionId': _questions[_currentIndex].id,
        'selectedAnswers': selectedAnswer,
      });
      // ignore: inference_failure_on_function_invocation, use_build_context_synchronously
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Quiz Ended'),
          content: Text('Good job your score is $score'),
          actions: [
            TextButton(
              onPressed: () {
                context.push('/participate');
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz ${widget.quizId}'),
        centerTitle: true,
      ),
      body: Center(
        child: _questions.isEmpty
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Question ${_currentIndex + 1}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    _questions[_currentIndex].get('question').toString(),
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Time left: $_timeLeft seconds',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Column(
                    children: _answerDocsList[_currentIndex]
                        .map((answerDoc) => Container(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 1,
                                    blurRadius: 2,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: RadioListTile(
                                title: Text(
                                  answerDoc.get('answer').toString(),
                                  style: TextStyle(fontSize: 18.0),
                                ),
                                value: answerDoc.reference,
                                groupValue: _selectedAnswerRef,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedAnswerRef =
                                        value as DocumentReference;
                                  });
                                },
                              ),
                            ))
                        .toList(),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _moveToNextQuestion,
                    child: Text('Next question'),
                  ),
                ],
              ),
      ),
    );
  }
}
