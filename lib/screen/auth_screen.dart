import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  bool _isAuthenticating = false;
  var _enterdMobileNumber = '';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _isAuthenticating = true);
    _formKey.currentState!.save();
    await _auth.verifyPhoneNumber(
      phoneNumber: "+91$_enterdMobileNumber",
      verificationCompleted: (phoneAuthCredential) {},
      verificationFailed: (error) {
        setState(() => _isAuthenticating = false);
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
                  setState(() => _isAuthenticating = false);
                },
              ),
            );
          },
        );
      },
      codeAutoRetrievalTimeout: (verificationId) {},
    );
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
                    style: Theme.of(context).textTheme.headlineMedium,
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
                    onSaved: (newValue) => _enterdMobileNumber = newValue!,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submit,
                    child: _isAuthenticating
                        ? const CircularProgressIndicator()
                        : const Text(
                            "Verify",
                          ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
