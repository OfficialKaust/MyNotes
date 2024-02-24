import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/firebase_options.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_service.dart';
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
        body: Column(children: [
          TextField(
            controller: _email,
            autocorrect: false,
            enableSuggestions: false,
            keyboardType: TextInputType.emailAddress,
            decoration:
                const InputDecoration(hintText: 'Please enter your email here'),
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
                  await AuthService.firebase().createUser(
                    email: email,
                    password: password,
                  );
                  final user = AuthService.firebase().currentUser;
                  await AuthService.firebase().sendEmailVerification();
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pushNamed(verifyEmailRoute);
                } on WeakPasswordAuthException {
                  // ignore: use_build_context_synchronously
                  showErrorDialog(context, 'Weak password');
                } on InvalidEmailAuthException {
                  // ignore: use_build_context_synchronously
                  showErrorDialog(context, 'Invalid email');
                } on EmailAlreadyInUseException {
                  // ignore: use_build_context_synchronously
                  showErrorDialog(context, 'Email already in use');
                } on GenericAuthException {
                  // ignore: use_build_context_synchronously
                  await showErrorDialog(
                    context,
                    'Authentication error',
                  );
                }
              },
              child: const Text('Register')),
          TextButton(
              onPressed: () async {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(loginRoute, (route) => false);
              },
              child: const Text('Already registered? Login here.'))
        ]));
  }
}
