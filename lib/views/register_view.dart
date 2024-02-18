import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/firebase_options.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    // TODO: implement initState
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Register'),
        ),
        body: FutureBuilder(
          future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          ),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return Column(children: [
                  TextField(
                    controller: _email,
                    autocorrect: false,
                    enableSuggestions: false,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                        hintText: 'Please enter your email here'),
                  ),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: const InputDecoration(
                        hintText: 'Please enter your password here'),
                  ),
                  TextButton(
                      onPressed: () async {
                        final email = _email.text;
                        final password = _password.text;

                        try {
                          final userCredentials = await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                                  email: email, password: password);
                          print(userCredentials);
                        } on FirebaseAuthException catch (e) {
                          print(e.code);
                          if (e.code == 'weak-password') {
                            print('Weak password');
                          } else if (e.code == 'invalid-email') {
                            print('Invalid email');
                          } else if (e.code == 'email-already-in-use') {
                            print('Email already in use');
                          }
                        }
                      },
                      child: const Text('Register')),
                  TextButton(
                      onPressed: () async {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            '/login/', (route) => false);
                      },
                      child: const Text('Already registered? Login here.'))
                ]);
              default:
                return const Text('Loading...');
            }
          },
        ));
  }
}
