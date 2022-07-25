import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gallery_app/screens/signup_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../validation_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) =>
      OrientationBuilder(builder: (context, orientation) {
        final isPortrait = orientation == Orientation.portrait;
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          return const SignupPage();
        } else {
          return Scaffold(
            backgroundColor: Colors.grey[900],
            body: SafeArea(
                child: Form(
                    key: _key,
                    child: Center(
                        child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: isPortrait
                                ? EdgeInsets.all(8.0.r)
                                : EdgeInsets.all(4.r),
                            child: Text(
                              'Welcome to the Gallery App!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isPortrait ? 24.sp : 16.sp,
                                color: Colors.grey[300],
                              ),
                            ),
                          ),
                          isPortrait
                              ? SizedBox(height: 10.h)
                              : SizedBox(height: 1.h),
                          isPortrait
                              ? Text('Sign in or sign up',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isPortrait ? 20.sp : 12.sp,
                                    color: Colors.grey[300],
                                  ))
                              : SizedBox(
                                  height: 1.h,
                                ),
                          isPortrait
                              ? SizedBox(height: 25.h)
                              : SizedBox(height: 8.h),
                          Text(
                            'Email Address:',
                            style: TextStyle(
                              fontSize: isPortrait ? 24.sp : 16.sp,
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
                                    controller: emailController,
                                    validator: validateEmail,
                                    keyboardType: TextInputType.emailAddress,
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
                              fontSize: isPortrait ? 24.sp : 16.sp,
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
                                    controller: passwordController,
                                    validator: validatePassword,
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Password',
                                    ),
                                  ),
                                ),
                              )),
                          SizedBox(height: 25.h),
                          isPortrait
                              ? Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 25.0.w),
                                      child: Container(
                                        padding: EdgeInsets.all(25.r),
                                        decoration: BoxDecoration(
                                            color: Colors.deepPurple,
                                            borderRadius:
                                                BorderRadius.circular(12.r)),
                                        child: Column(
                                          children: [
                                            Center(
                                              child: TextButton(
                                                onPressed: () async {
                                                  if (_key.currentState!
                                                      .validate()) {
                                                    try {
                                                      await FirebaseAuth
                                                          .instance
                                                          .signInWithEmailAndPassword(
                                                              email:
                                                                  emailController
                                                                      .text,
                                                              password:
                                                                  passwordController
                                                                      .text);
                                                    } on FirebaseAuthException catch (error) {
                                                      errorMessage =
                                                          error.message!;
                                                    }
                                                  }
                                                  setState(() {});
                                                },
                                                child: Text(
                                                  'Sign In',
                                                  style: TextStyle(
                                                    color: Colors.grey[300],
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18.sp,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 15.h),
                                    Text(
                                      errorMessage,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                    Text(
                                      'Not a member? Register now!',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey[300],
                                      ),
                                    ),
                                    SizedBox(height: 15.h),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 25.0.w),
                                      child: Container(
                                          padding: EdgeInsets.all(25.r),
                                          decoration: BoxDecoration(
                                              color: Colors.deepPurple,
                                              borderRadius:
                                                  BorderRadius.circular(12.r)),
                                          child: Center(
                                            child: TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pushReplacement(
                                                      MaterialPageRoute(
                                                          builder: ((context) =>
                                                              const SignupPage())));
                                                },
                                                child: Text('Sign Up',
                                                    style: TextStyle(
                                                      color: Colors.grey[300],
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18.sp,
                                                    ))),
                                          )),
                                    ),
                                  ],
                                )
                              : Row(children: [
                                  SizedBox(height: 8.h),
                                  Container(
                                    margin: EdgeInsets.fromLTRB(24.w, 0, 0, 0),
                                    width: 150.w,
                                    height: 100.h,
                                    padding: EdgeInsets.all(4.r),
                                    decoration: BoxDecoration(
                                        color: Colors.deepPurple,
                                        borderRadius:
                                            BorderRadius.circular(12.r)),
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                                builder: ((context) =>
                                                    const SignupPage())));
                                      },
                                      child: Text(
                                        'Sign Up',
                                        style: TextStyle(
                                          color: Colors.grey[300],
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    margin: EdgeInsets.fromLTRB(0, 0, 24.w, 0),
                                    height: 100.h,
                                    width: 150.w,
                                    padding: EdgeInsets.all(4.r),
                                    decoration: BoxDecoration(
                                        color: Colors.deepPurple,
                                        borderRadius:
                                            BorderRadius.circular(12.r)),
                                    child: TextButton(
                                        onPressed: () async {
                                          if (_key.currentState!.validate()) {
                                            try {
                                              await FirebaseAuth.instance
                                                  .signInWithEmailAndPassword(
                                                      email:
                                                          emailController.text,
                                                      password:
                                                          passwordController
                                                              .text);
                                            } on FirebaseAuthException catch (error) {
                                              errorMessage = error.message!;
                                            }
                                          }
                                          setState(() {});
                                        },
                                        child: Text('Sign In',
                                            style: TextStyle(
                                              color: Colors.grey[300],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18.sp,
                                            ))),
                                  ),
                                ]),
                        ],
                      ),
                    )))),
          );
        }
      });
}
