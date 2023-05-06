import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'src/authentication.dart';

class Participate extends StatefulWidget {
  const Participate({Key? key}) : super(key: key);

  @override
  _ParticipateState createState() => _ParticipateState();
}

class _ParticipateState extends State<Participate> {
  final _codeController = TextEditingController();
  final _usernameController = TextEditingController();

  String? quizName;
  String? quizDescription;
  String? quizCode;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<ApplicationState>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Participate in a Quiz'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          TextFormField(
            controller: _codeController,
            decoration: const InputDecoration(
              hintText: 'Enter code',
              labelText: 'Enter quiz code',
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              border: OutlineInputBorder(),
              alignLabelWithHint: false,
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () async {
              final String code = _codeController.text;
              final quizRef = FirebaseFirestore.instance
                  .collection('quizes')
                  .where('code', isEqualTo: code);
              final quizSnapshot = await quizRef.get();
              if (quizSnapshot.size == 1) {
                final quizData = quizSnapshot.docs.first.data();
                setState(() {
                  quizName = quizData['name'].toString();
                  quizDescription = quizData['description'].toString();
                  quizCode = quizData['code'].toString();
                });
              } else {
                // Quiz not found or duplicate codes found
                setState(() {
                  quizName = null;
                  quizDescription = null;
                });
              }
            },
            child: const Text('Submit'),
          ),
          const SizedBox(height: 24),
          Text('Or browse available quizzes'),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('quizes')
                  .where('active', isEqualTo: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                final List<QueryDocumentSnapshot> documents =
                    snapshot.data!.docs;

                return ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (BuildContext context, int index) {
                    final document = documents[index];
                    return ListTile(
                      title: Text(document['name'].toString()),
                      subtitle: Text(document['description'].toString()),
                      trailing: Icon(Icons.play_arrow),
                      onTap: () {
                        if (appState.loggedIn) {
                          context.push('/startquizp/${document['code']}/${{
                            appState.userName
                          }}');
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Create an Account?'),
                                content: const Text(
                                    'Would you like to create an account to save your progress and track your scores?'),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Continue as Guest'),
                                    onPressed: () {
                                      // ignore: inference_failure_on_function_invocation
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text('Enter Username'),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextFormField(
                                                  controller:
                                                      _usernameController,
                                                  decoration:
                                                      const InputDecoration(
                                                    hintText: 'Username',
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    // Add a new participant to the "participants" collection
                                                    FirebaseFirestore.instance
                                                        .collection(
                                                            'participants')
                                                        .add({
                                                      'username':
                                                          _usernameController
                                                              .text,
                                                      'quizCode':
                                                          document['code'],
                                                    });
                                                    context.push(
                                                        '/startquizp/${document['code']}/${{
                                                      _usernameController.text
                                                    }}');
                                                  },
                                                  child:
                                                      const Text('Start Quiz'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('Create Account'),
                                    onPressed: () {
                                      context.push('/sign-in');
                                      //Navigator.of(context).pop();
                                      // Add your navigation code here
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
          if (quizName != null && quizDescription != null) ...[
            const SizedBox(height: 24),
            Text(
              'Quiz: $quizName',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              quizDescription!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Create an Account?'),
                      content: const Text(
                          'Would you like to create an account to save your progress and track your scores?'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Continue as Guest'),
                          onPressed: () {
                            // ignore: inference_failure_on_function_invocation
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Enter Username'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextFormField(
                                        controller: _usernameController,
                                        decoration: const InputDecoration(
                                          hintText: 'Username',
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () {
                                          // Add a new participant to the "participants" collection
                                          FirebaseFirestore.instance
                                              .collection('participants')
                                              .add({
                                            'username':
                                                _usernameController.text,
                                            'quizCode': quizCode,
                                          });

                                          context.push(
                                              '/startquizp/$quizCode/${{
                                            _usernameController.text
                                          }}');
                                        },
                                        child: const Text('Start Quiz'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        TextButton(
                          child: const Text('Create Account'),
                          onPressed: () {
                            // Navigate to create account screen
                            context.push('/sign-in');
                            // Add your navigation code here
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Start Quiz'),
            ),
          ],
        ],
      ),
    );
  }
}
