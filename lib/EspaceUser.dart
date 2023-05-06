// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'src/authentication.dart';

class EspaceUser extends StatelessWidget {
  const EspaceUser({Key? key, required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<ApplicationState>(context);
    if (!appState.loggedIn) {
      // Navigate to main screen if user is not logged in
      context.push('/');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Hello $userName'),
        backgroundColor: Colors.deepPurple[300], // Set app bar background color
        toolbarTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 149, 117, 205),
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            AuthFunc(
              loggedIn: appState.loggedIn,
              signOut: () {
                FirebaseAuth.instance.signOut();
              },
            ),
            ListTile(
              leading: Icon(Icons.play_arrow_outlined),
              title: Text('Participate in a quiz'),
              onTap: () {
                context.push('/participate');
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Flexible(
            fit: FlexFit.loose,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('quizes')
                  .where('userId', isEqualTo: appState.userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return LinearProgressIndicator();
                }

                final data = snapshot.data!;
                if (data.size == 0) {
                  return Text('No quizzes found');
                }

                final quizList =
                    snapshot.data!.docs.map((quiz) => quiz.data()).toList();

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 16),
                      Text(
                        'Your existing quizzes',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: quizList.length,
                          itemBuilder: (context, index) {
                            final quiz =
                                quizList[index] as Map<String, dynamic>;
                            return ListTile(
                              title: Text(quiz['name'].toString()),
                              subtitle: Text(quiz['description'].toString()),
                              leading: const Icon(Icons.help),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () async {
                                      QuerySnapshot snapshot =
                                          await FirebaseFirestore.instance
                                              .collection('quizes')
                                              .where('code',
                                                  isEqualTo: quiz['code'])
                                              .get();
                                      List<DocumentSnapshot> docs =
                                          snapshot.docs;
                                      for (DocumentSnapshot doc in docs) {
                                        await doc.reference.delete();
                                      }
                                    },
                                  ),
                                  IgnorePointer(
                                    ignoring: quiz['final'] ==
                                        true, // ignore touch events if quiz is final
                                    child: Opacity(
                                      opacity: quiz['final'] == true
                                          ? 0.5
                                          : 1.0, // reduce opacity if quiz is final
                                      child: IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: quiz['final'] == true
                                            ? null
                                            : () {
                                                context.push(
                                                    '/modifyquiz/${quiz['code']}');
                                              },
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.play_arrow),
                                    onPressed: () async {
                                      await FirebaseFirestore.instance
                                          .collection('quizes')
                                          .where('code',
                                              isEqualTo: quiz['code'])
                                          .get()
                                          .then((querySnapshot) {
                                        querySnapshot.docs.forEach((doc) {
                                          doc.reference
                                              .update({'active': true});
                                        });
                                      });
                                      await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Quiz activé'),
                                            content: Text(
                                                'Le quiz a été activé avec succès!'),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('OK'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                              // onTap: () {
                              //  context.go('/quiz/${quiz['quizId']}');
                              // },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 20.0),
            child: SizedBox(
              height: 50.0,
              child: ElevatedButton(
                onPressed: () {
                  context.push('/addquiz');
                },
                child: const ListTile(
                  title: Text('Create a Quiz'),
                  trailing: Icon(Icons.add),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
