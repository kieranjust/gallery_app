import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'home_page.dart';
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final auth = FirebaseAuth.instance;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return const HomePage();
    } else {
      return Scaffold(
          backgroundColor: Colors.grey[900],
          body: Form(
              key: _key,
              child: SafeArea(
                  child: Center(
                      child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      'Welcome to the Gallery App!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24.sp,
                        color: Colors.grey[300],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text('Please enter your details below',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                          color: Colors.grey[300],
                        )),
                    SizedBox(height: 55.h),
                    Text(
                      'Email Address:',
                      style: TextStyle(
                        fontSize: 24.sp,
                        color: Colors.grey[300],
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25.0.w),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[600],
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(left: 20.0.w),
                            child: TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              controller: emailController,
                              validator: validateEmail,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Email',
                              ),
                            ),
                          ),
                        )),
                    SizedBox(height: 10.h),
                    Text(
                      'Password:',
                      style: TextStyle(
                        fontSize: 24.sp,
                        color: Colors.grey[300],
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25.0.w),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[600],
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(left: 20.0.w),
                            child: TextFormField(
                              obscureText: true,
                              controller: passwordController,
                              validator: validatePassword,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Password',
                              ),
                            ),
                          ),
                        )),
                    SizedBox(height: 10.h),
                    Text(
                      'Confirm Password:',
                      style: TextStyle(
                        fontSize: 24.sp,
                        color: Colors.grey[300],
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25.0.w),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[600],
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(left: 20.0.w),
                            child: TextFormField(
                              obscureText: true,
                              controller: confirmController,
                              validator: (val) {
                                if (val != passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Confirm Password',
                              ),
                            ),
                          ),
                        )),
                    SizedBox(height: 30.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25.0.w),
                      child: Container(
                        padding: EdgeInsets.all(25.r),
                        decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(12.r)),
                        child: Center(
                          child: TextButton(
                            onPressed: () async {
                              if (_key.currentState!.validate()) {
                                try {
                                  await FirebaseAuth.instance
                                      .createUserWithEmailAndPassword(
                                    email: emailController.text,
                                    password: passwordController.text,
                                  );
                                  errorMessage = '';
                                } on FirebaseAuthException catch (error) {
                                  errorMessage = error.message!;
                                }
                                setState(() {});
                              }
                            },
                            child: Text('Sign Up',
                                style: TextStyle(
                                  color: Colors.grey[300],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.sp,
                                )),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    SizedBox(height: 30.h),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: ((context) => const LoginPage())));
                        },
                        child: Text('Return to Login',
                            style: TextStyle(
                              color: Colors.grey[300],
                            )))
                  ],
                ),
              )))));
    }
  }

  String? validateEmail(String? formEmail) {
    if (formEmail == null || formEmail.isEmpty) {
      return 'Email address is required.';
    }

    String pattern = r'\w+@\w+\.\w+';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(formEmail)) {
      return 'Invalid email address format.';
    }

    return null;
  }

  String? validatePassword(String? formPassword) {
    if (formPassword == null || formPassword.isEmpty) {
      return 'Password is required.';
    }

    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(formPassword)) {
      return '''
      Password must be at least 8 characters,
      include an uppercase letter, number and symbol.
      ''';
    }

    return null;
  }
}
