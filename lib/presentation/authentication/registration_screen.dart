// import 'dart:math';

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:todo_verynew/home/home_page.dart';
import 'package:todo_verynew/model/user_details.dart';
import 'package:todo_verynew/presentation/todos/firestore_collection.dart';
import 'package:todo_verynew/util/app_constants.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  final googleSignIn = GoogleSignIn.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    final passwordRegex =
        RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[A-Za-z\d]{6,}$');
    if (!passwordRegex.hasMatch(value)) {
      return 'Password must be at least 6 characters long, uppercase letter, lowercase letter, and number';
    }
    // Additional check for minimum length
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  Future<void> _storeUserData({
    required UserDetails userDetails,
  }) async {
    final firestore = FirebaseFirestore.instance;
    await firestore
        .collection('/users')
        .doc(userDetails.uid)
        .set(userDetails.toJson());
    // print("ydde");

    await firestore
        .collection(FirestoreCollections.todoListCollection)
        .doc(userDetails.uid)
        .set({});
  }

  Future<void> _handleRegistration() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final firebaseAuth = FirebaseAuth.instance;

        final userCredentials =
            await firebaseAuth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (userCredentials.user == null) {
          throw Exception('something went wrong,');
        }
        await _storeUserData(
            userDetails: UserDetails(
          uid: userCredentials.user!.uid,
          email: userCredentials.user!.email ?? _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ));

        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
          (route) => false,
        );

        AppConstans.showSnackBar(context,
            message: 'account successfully created');
      } on FirebaseException catch (error) {
        if (error.code == 'weak-password') {
          if (!mounted) return;
          AppConstans.showSnackBar(context,
              message: 'weak password', isSuccess: false);
        } else if (error.code == 'email-already-in-use') {
          if (!mounted) return;
          AppConstans.showSnackBar(context,
              message: 'email is already in use', isSuccess: false);
        }
      } catch (error) {
        AppConstans.showSnackBar(context,
            message: error.toString(), isSuccess: false);
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signinAsGuest() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final firebaseAuth = FirebaseAuth.instance;
      final userCredentials = await firebaseAuth.signInAnonymously();

      if (userCredentials.user == null) {
        return;
      }

      await _storeUserData(
        userDetails: UserDetails(
          uid: userCredentials.user!.uid,
          isGuest: true,
        ),
      );

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
        (route) => false,
      );

      AppConstans.showSnackBar(
        context,
        message: 'Loged in as Guest',
        isSuccess: true,
      );
    } catch (error) {
      AppConstans.showSnackBar(
        context,
        message: error.toString(),
        isSuccess: false,
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _goolgesignin() async {
    setState(() {
      _isLoading = true;
    });

    await googleSignIn.initialize();

//   unawaited(signIn
//     .initialize(clientId: clientId, serverClientId: serverClientId)
//     .then((_) {
//   signIn.authenticationEvents
//       .listen(_handleAuthenticationEvent)
//       .onError(_handleAuthenticationError);

//   /// This example always uses the stream-based approach to determining
//   /// which UI state to show, rather than using the future returned here,
//   /// if any, to conditionally skip directly to the signed-in state.
//   signIn.attemptLightweightAuthentication();
// }));

    try {
      final googleUser = await googleSignIn.authenticate();
      if (googleUser == null) {
        setState(() {
          _isLoading = false;
          return;
        });
      }

      final googlaAuth = googleUser.authentication;
      final credentials = GoogleAuthProvider.credential(
        idToken: googlaAuth.idToken,
      );

      final firebaseauth = FirebaseAuth.instance;
      await firebaseauth.signInWithCredential(credentials);

      if (!mounted) return;
    } catch (e) {
      if (mounted) {
        AppConstans.showSnackBar(context, message: e.toString());
      }
    }
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),

                // Welcome text
                Text(
                  'Join TodoEasy',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your account to get started',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: _validateEmail,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email address',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  textInputAction: TextInputAction.next,
                  validator: _validatePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                // Confirm password field

                const SizedBox(height: 32),

                // Register button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegistration,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Create Account',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
                SizedBox(
                  height: 12,
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _signinAsGuest,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            backgroundColor: Colors.blueAccent,
                          ),
                        )
                      : const Text(
                          'Enter as Guest',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
                SizedBox(
                  height: 12,
                ),

                ElevatedButton(
                    onPressed: _isLoading ? null : _goolgesignin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Google Sign in')),

                const SizedBox(height: 16),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Sign In'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
