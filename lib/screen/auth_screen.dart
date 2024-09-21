import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:kp_music/providers/auth_provider.dart';
import 'package:kp_music/screen/home_screen.dart';

class AuthScreen extends ConsumerStatefulWidget {
  final AudioPlayer audioPlayer;
  const AuthScreen({super.key, required this.audioPlayer});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    if (auth.isSuccess) {
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  HomeScreen(audioPlayer: widget.audioPlayer)),
        );
      });
    }

    return Scaffold(
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Welcome",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (!_isLogin)
                    TextFormField(
                      controller: auth.nameController,
                      decoration: const InputDecoration(
                        labelText: "Name",
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a Name';
                        }
                        return null;
                      },
                      onSaved: (newValue) =>
                          auth.nameController.text = newValue!,
                    ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: auth.emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      }
                      if (!RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    onSaved: (newValue) =>
                        auth.emailController.text = newValue!,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: auth.passwordController,
                    decoration: const InputDecoration(
                      labelText: "Password",
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (!RegExp(
                              r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
                          .hasMatch(value)) {
                        return 'Password must contain at least\n one uppercase letter\n one lowercase letter\n one number \n one special character';
                      }
                      return null;
                    },
                    onSaved: (newValue) =>
                        auth.passwordController.text = newValue!,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_isLogin) {
                        ref.read(authProvider.notifier).login(context);
                      } else {
                        ref.read(authProvider.notifier).signup(context);
                      }
                    },
                    child: auth.isLoading
                        ? const CircularProgressIndicator() // Show loading indicator when isLoading is true
                        : Text(
                            _isLogin
                                ? "Login"
                                : "Sign Up", // Adjust the text based on the mode
                          ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                    child: Text(
                      _isLogin
                          ? "Don't have an account? Sign Up"
                          : "Already have an account? Login", // Adjust the text based on the mode
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
