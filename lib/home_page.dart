import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'app_state.dart';
import 'src/authentication.dart';
import 'src/widgets.dart';
import 'profile_form.dart';
import 'EspaceUser.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Consumer<ApplicationState>(
            builder: (context, appState, _) => !appState.loggedIn
                ? Scaffold(
                    appBar: AppBar(
                      title: Text('Welcome to your quiz App !'),
                    ),
                    body: Column(
                      // wrap Scaffold and SizedBox in Column widget
                      children: [
                        const SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/HomeP.gif',
                            height: 500,
                          ),
                        ),
                        const SizedBox(height: 50),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment
                              .baseline, // Ajout de cette ligne
                          textBaseline:
                              TextBaseline.alphabetic, // Ajout de cette ligne
                          children: [
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: AuthFunc(
                                loggedIn: appState.loggedIn,
                                signOut: () {
                                  FirebaseAuth.instance.signOut();
                                },
                              ),
                            ),
                            SizedBox(
                                width:
                                    16.0), // Ajout d'un espace de 16.0 de largeur entre les deux éléments
                            Flexible(
                              child: Container(
                                width:
                                    200, // set the width to increase the size
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () {
                                    context.push('/participate');
                                  },
                                  child: const Text(
                                    'Play Now',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                : appState.profileSet
                    ? EspaceUser(userName: appState.userName)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppBar(
                            title: Text('Continue configuring your profile !'),
                          ),
                          ProfileForm(),
                          AuthFunc(
                            loggedIn: appState.loggedIn,
                            signOut: () {
                              FirebaseAuth.instance.signOut();
                            },
                          ),
                        ],
                      ),
          ),
        ),
      ),
    );
  }
}
