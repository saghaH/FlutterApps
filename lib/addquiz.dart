import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class AddQuizPage extends StatefulWidget {
  const AddQuizPage({Key? key}) : super(key: key);

  @override
  _AddQuizPageState createState() => _AddQuizPageState();
}

class _AddQuizPageState extends State<AddQuizPage> {
  final _formKey = GlobalKey<FormState>();
  final _quizNameController = TextEditingController();
  final _quizCategoryController = TextEditingController();
  final _quizDescriptionController = TextEditingController();

  late final String _userId;

  @override
  void initState() {
    super.initState();
    _getUserId();
  }

  Future<void> _getUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
    }
  }

  @override
  void dispose() {
    _quizNameController.dispose();
    _quizCategoryController.dispose();
    _quizDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quiz Name',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quizNameController,
                decoration: const InputDecoration(
                  labelText: 'Quiz name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a quiz name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              Text(
                'Quiz Category',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _quizCategoryController,
                decoration: const InputDecoration(
                  labelText: 'Quiz category',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a quiz category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              Text(
                'Quiz Description',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _quizDescriptionController,
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: 'Quiz description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a quiz description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Generate a 6-digit code
                    final random = Random();
                    final code = List.generate(6, (index) => random.nextInt(10))
                        .join('');

                    // Add the quiz to Firestore
                    final quizRef =
                        FirebaseFirestore.instance.collection('quizes');
                    await quizRef.add({
                      'name': _quizNameController.text,
                      'category': _quizCategoryController.text,
                      'description': _quizDescriptionController.text,
                      'code': code,
                      'active': false,
                      'final': false,
                      'date': DateTime.now(),
                      'userId': _userId,
                    });

                    // Navigate back to the previous screen
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add quiz'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
