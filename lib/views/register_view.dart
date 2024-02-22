import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/firebase_options.dart';
import 'package:mynotes/utilities/show_error_dialog.dart';

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
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
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
                          await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                            email: email,
                            password: password,
                          );
                          final user = FirebaseAuth.instance.currentUser;
                          await user?.sendEmailVerification();
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pushNamed(verifyEmailRoute);
                        } on FirebaseAuthException catch (e) {
                          // devtools.log(e.code);
                          if (e.code == 'weak-password') {
                            // ignore: use_build_context_synchronously
                            showErrorDialog(context, 'Weak password');
                          } else if (e.code == 'invalid-email') {
                            // ignore: use_build_context_synchronously
                            showErrorDialog(context, 'Invalid email');
                          } else if (e.code == 'email-already-in-use') {
                            // ignore: use_build_context_synchronously
                            showErrorDialog(context, 'Email already in use');
                          } else {
                            // ignore: use_build_context_synchronously
                            showErrorDialog(context, 'Error: ${e.code}');
                          }
                        } catch (e) {
                          // ignore: use_build_context_synchronously
                          showErrorDialog(context, e.toString());
                        }
                      },
                      child: const Text('Register')),
                  TextButton(
                      onPressed: () async {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            loginRoute, (route) => false);
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
