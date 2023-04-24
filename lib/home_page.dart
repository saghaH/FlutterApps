import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6A1B9A),
              Color(0xFF8E24AA),
              Color(0xFFBA68C8),
            ],
          ),
        ),
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
                          ],
                        ),
                      ],
                    ),
                  )
                : appState.profileSet
                    ? EspaceUser()
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
