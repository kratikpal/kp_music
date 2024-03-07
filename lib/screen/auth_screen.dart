import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  bool _isAuthenticatingWithMobile = false;
  bool _isAuthenticatingWithGoogle = false;
  var _enteredMobileNumber = '';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _isAuthenticatingWithMobile = true);
    _formKey.currentState!.save();
    await _auth.verifyPhoneNumber(
      phoneNumber: "+91$_enteredMobileNumber",
      verificationCompleted: (phoneAuthCredential) {},
      verificationFailed: (error) {
        setState(() => _isAuthenticatingWithMobile = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${error.message}',
            ),
          ),
        );
      },
      codeSent: (verificationId, forceResendingToken) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                'Enter OTP',
              ),
              content: OTPTextField(
                length: 6,
                fieldStyle: FieldStyle.box,
                width: MediaQuery.of(context).size.width,
                textFieldAlignment: MainAxisAlignment.spaceAround,
                onCompleted: (value) async {
                  Navigator.of(context).pop();
                  try {
                    final credential = PhoneAuthProvider.credential(
                      verificationId: verificationId,
                      smsCode: value,
                    );
                    final signIn = await _auth.signInWithCredential(credential);
                    if (signIn.user != null) {
                      final userDoc = await FirebaseFirestore.instance
                          .collection("users")
                          .doc(signIn.user!.uid)
                          .get();
                      if (!userDoc.exists) {
                        // User doesn't exist in Firestore, create a new document
                        FirebaseFirestore.instance
                            .collection("users")
                            .doc(signIn.user!.uid)
                            .set({
                          "UID": signIn.user!.uid,
                        });
                      }
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '$e',
                        ),
                      ),
                    );
                  }
                  setState(() => _isAuthenticatingWithMobile = false);
                },
              ),
            );
          },
        );
      },
      codeAutoRetrievalTimeout: (verificationId) {},
    );
  }

  Future<void> _signInWithGoogle() async {
    try {
      setState(() => _isAuthenticatingWithGoogle = true);
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await _auth.signInWithCredential(credential);
        // Proceed with your application logic after signing in with Google
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$e',
          ),
        ),
      );
    } finally {
      setState(() => _isAuthenticatingWithGoogle = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Mobile Number",
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your mobile number';
                      }
                      if (value.length != 10 || int.tryParse(value) == null) {
                        return 'Please enter a valid mobile number';
                      }
                      return null;
                    },
                    onSaved: (newValue) => _enteredMobileNumber = newValue!,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submit,
                    child: _isAuthenticatingWithMobile
                        ? const CircularProgressIndicator()
                        : const Text(
                            "Verify",
                          ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "or",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _signInWithGoogle,
                    child: _isAuthenticatingWithGoogle
                        ? const CircularProgressIndicator()
                        : const Text(
                            "Sign in with Google",
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
