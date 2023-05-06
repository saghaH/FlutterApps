import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

class ModifyQuiz extends StatefulWidget {
  const ModifyQuiz({Key? key, required this.quizId}) : super(key: key);

  final String quizId;
  @override
  _ModifyQuizState createState() => _ModifyQuizState();
}

class _ModifyQuizState extends State<ModifyQuiz> {
  int _numberOfQuestions = 0;
  final _questionController = TextEditingController();
  final _pointsController = TextEditingController();
  final _timeController = TextEditingController();
  final _answer1Controller = TextEditingController();
  final _answer2Controller = TextEditingController();
  final _answer3Controller = TextEditingController();
  final _answer4Controller = TextEditingController();
  List<bool> _checkboxValues = [false, false, false, false];
  get quizId => widget.quizId;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<ApplicationState>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modify Quiz'),
      ),
      body: Center(
          child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!appState.showQuestionForm)
              Column(
                children: [
                  const Text('How many questions in your quiz?'),
                  const SizedBox(height: 16),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _numberOfQuestions = int.tryParse(value) ?? 0;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _numberOfQuestions > 0
                        ? () async {
                            // Retrieve the quiz document with the given quizId code
                            final quizSnapshot = await FirebaseFirestore
                                .instance
                                .collection('quizes')
                                .where('code', isEqualTo: quizId)
                                .get();

                            if (quizSnapshot.docs.isNotEmpty) {
                              // If a quiz document with the given code exists, update it with the new 'numberquest' field value
                              final quizDoc = quizSnapshot.docs.first;
                              await quizDoc.reference
                                  .update({'numberquest': _numberOfQuestions});

                              // Call the appState.addQuestions() function to update the app's state and add the questions to the quiz
                              appState.addQuestions();
                            } else {
                              // If no quiz document with the given code exists, log an error message
                              print('Quiz with code $quizId not found');
                            }
                          }
                        : null,
                    child: const Text('Add Questions'),
                  ),
                ],
              ),
            if (appState.showQuestionForm)
              // Display quiz information
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('quizes')
                    .where('code', isEqualTo: quizId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  final data = snapshot.data!;
                  if (data.size == 0) {
                    return const Text('Quiz not found');
                  }

                  final quizData =
                      data.docs.first.data() as Map<String, dynamic>;
                  //int numberQuest = quizData['numberquest'] as int;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        quizData['name'].toString(),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        quizData['description'].toString(),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  );
                },
              ),
            if (appState.showQuestionForm)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Question ${appState.compteur}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _questionController,
                      decoration: const InputDecoration(
                        //hintText: 'Question',
                        labelText: 'Question',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Points',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _pointsController,
                      decoration: const InputDecoration(
                        //hintText: 'Question',
                        labelText: 'Points',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Time',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _timeController,
                      decoration: const InputDecoration(
                        //hintText: 'Question',
                        labelText: 'Time',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Answers',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: _checkboxValues[0],
                          onChanged: (value) {
                            setState(() {
                              _checkboxValues[0] = value!;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _answer1Controller,
                            decoration: const InputDecoration(
                              hintText: 'Answer 1',
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: _checkboxValues[1],
                          onChanged: (value) {
                            setState(() {
                              _checkboxValues[1] = value!;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _answer2Controller,
                            decoration: const InputDecoration(
                              hintText: 'Answer 2',
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: _checkboxValues[2],
                          onChanged: (value) {
                            setState(() {
                              _checkboxValues[2] = value!;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _answer3Controller,
                            decoration: const InputDecoration(
                              hintText: 'Answer 3',
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: _checkboxValues[3],
                          onChanged: (value) {
                            setState(() {
                              _checkboxValues[3] = value!;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _answer4Controller,
                            decoration: const InputDecoration(
                              hintText: 'Answer 4',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        final newQuestionData = {
                          'points': int.parse(_pointsController.text),
                          'question': _questionController.text,
                          'time': int.parse(_timeController.text),
                          'quizId': quizId
                        };

                        final newAnswerDataList = [
                          {
                            'answer': _answer1Controller.text,
                            'correct': _checkboxValues[0]
                          },
                          {
                            'answer': _answer2Controller.text,
                            'correct': _checkboxValues[1]
                          },
                          {
                            'answer': _answer3Controller.text,
                            'correct': _checkboxValues[2]
                          },
                          {
                            'answer': _answer4Controller.text,
                            'correct': _checkboxValues[3]
                          },
                        ];

                        final questionRef = FirebaseFirestore.instance
                            .collection('Questions')
                            .doc();
                        await questionRef.set(newQuestionData);
                        final answerCollectionRef =
                            await questionRef.collection('Answers');
                        final answerRef = answerCollectionRef.doc();
                        for (final newAnswerData in newAnswerDataList) {
                          final answerRef = answerCollectionRef.doc();
                          await answerRef.set(newAnswerData);
                        }
                        appState.incrementation();
                        // Clear text controllers
                        _pointsController.clear();
                        _questionController.clear();
                        _timeController.clear();
                        _answer1Controller.clear();
                        _answer2Controller.clear();
                        _answer3Controller.clear();
                        _answer4Controller.clear();
                        _checkboxValues = [false, false, false, false];

                        // Update state
                        setState(() {});
                      },
                      child: appState.compteur <= _numberOfQuestions
                          ? Text('Add Question')
                          : null,
                    ),
                  ],
                ),
              ),
            if (appState.showQuestionForm)
              ElevatedButton(
                  onPressed: () async {
                    final quizRef = FirebaseFirestore.instance
                        .collection('quizes')
                        .where('code', isEqualTo: quizId)
                        .limit(1);
                    final quizSnapshot = await quizRef.get();
                    if (quizSnapshot.docs.isNotEmpty) {
                      final quizDoc = quizSnapshot.docs.first;
                      await quizDoc.reference.update({'final': true});
                    }
                    appState.Updatedone();
                    appState.reinitialiser();
                    Navigator.pop(context);
                  },
                  child: Text('Finalize quiz'))
          ],
        ),
      )),
    );
  }
}
