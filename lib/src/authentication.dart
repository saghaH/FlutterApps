import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'widgets.dart';

class AuthFunc extends StatelessWidget {
  const AuthFunc({
    Key? key,
    required this.loggedIn,
    required this.signOut,
    this.enableFreeSwag = false,
  }) : super(key: key);

  final bool loggedIn;
  final void Function() signOut;
  final bool enableFreeSwag;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, bottom: 8),
      child: loggedIn
          ? ElevatedButton(
              onPressed: signOut,
              child: const Text('Log Out'),
            )
          : Container(
              width: 200, // set the width to increase the size
              height: 50,
              child: StyledButton(
                onPressed: () {
                  !loggedIn ? context.push('/sign-in') : signOut();
                },
                child: const Text(
                  'Join the fun!',
                ),
              ),
            ),
    );
  }
}
