import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../validation_service.dart';
import 'home_page.dart';
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final userNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) =>
      OrientationBuilder(builder: (context, orientation) {
        final isPortrait = orientation == Orientation.portrait;
        {
          User? user = FirebaseAuth.instance.currentUser;

          if (user != null) {
            return const HomePage();
          } else {
            return Scaffold(
                backgroundColor: Colors.grey[900],
                body: Form(
                    key: _key,
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            isPortrait
                                ? SizedBox(
                                    height: 40.h,
                                  )
                                : const SizedBox(height: 0),
                            isPortrait
                                ? Text(
                                    'Welcome to the Gallery App!',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24.sp,
                                      color: Colors.grey[300],
                                    ),
                                  )
                                : const SizedBox(height: 0),
                            isPortrait
                                ? SizedBox(height: 20.h)
                                : const SizedBox(height: 0),
                            Text('Please enter your signup details below',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isPortrait ? 20.sp : 14.sp,
                                  color: Colors.grey[300],
                                )),
                            isPortrait
                                ? SizedBox(height: 55.h)
                                : SizedBox(height: 10.h),
                            // Commented out until username login is implimented
                            // Text(
                            //   'User Name:',
                            //   style: TextStyle(
                            //     fontSize: 24.sp,
                            //     color: Colors.grey[300],
                            //   ),
                            // ),
                            // Padding(
                            //     padding: EdgeInsets.symmetric(horizontal: 25.0.w),
                            //     child: Container(
                            //       decoration: BoxDecoration(
                            //         color: Colors.grey[600],
                            //         border: Border.all(color: Colors.grey),
                            //         borderRadius: BorderRadius.circular(12.r),
                            //       ),
                            //       child: Padding(
                            //         padding: EdgeInsets.only(left: 20.0.w),
                            //         child: TextFormField(
                            //           controller: userNameController,
                            //           validator: validateUserName,
                            //           decoration: const InputDecoration(
                            //             border: InputBorder.none,
                            //             hintText: 'User Name',
                            //           ),
                            //         ),
                            //       ),
                            //     )),
                            Text(
                              'Email Address:',
                              style: TextStyle(
                                fontSize: isPortrait ? 24.sp : 10.sp,
                                color: Colors.grey[300],
                              ),
                            ),
                            Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 25.0.w),
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
                                fontSize: isPortrait ? 24.sp : 10.sp,
                                color: Colors.grey[300],
                              ),
                            ),
                            Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 25.0.w),
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
                                fontSize: isPortrait ? 24.sp : 10.sp,
                                color: Colors.grey[300],
                              ),
                            ),
                            Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 25.0.w),
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
                            isPortrait
                                ? SizedBox(height: 30.h)
                                : SizedBox(height: 8.h),
                            isPortrait
                                ? Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25.0.w),
                                        child: Container(
                                          padding: EdgeInsets.all(25.r),
                                          height: 75.h,
                                          decoration: BoxDecoration(
                                              color: Colors.deepPurple,
                                              borderRadius:
                                                  BorderRadius.circular(12.r)),
                                          child: Center(
                                            child: TextButton(
                                              onPressed: () async {
                                                if (_key.currentState!
                                                    .validate()) {
                                                  try {
                                                    await FirebaseAuth.instance
                                                        .createUserWithEmailAndPassword(
                                                      email:
                                                          emailController.text,
                                                      password:
                                                          passwordController
                                                              .text,
                                                    );
                                                    errorMessage = '';
                                                  } on FirebaseAuthException catch (error) {
                                                    errorMessage =
                                                        error.message!;
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
                                          style: const TextStyle(
                                              color: Colors.red),
                                        ),
                                      ),
                                      SizedBox(height: 30.h),
                                      TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pushReplacement(
                                                    MaterialPageRoute(
                                                        builder: ((context) =>
                                                            const LoginPage())));
                                          },
                                          child: Text('Return to Login',
                                              style: TextStyle(
                                                color: Colors.grey[300],
                                              )))
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.fromLTRB(
                                            24.w, 20.h, 0, 0),
                                        padding: EdgeInsets.all(3.r),
                                        width: 145.w,
                                        height: 75.h,
                                        decoration: BoxDecoration(
                                            color: Colors.deepPurple,
                                            borderRadius:
                                                BorderRadius.circular(12.r)),
                                        child: Center(
                                          child: TextButton(
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pushReplacement(
                                                      MaterialPageRoute(
                                                          builder: ((context) =>
                                                              const LoginPage())));
                                            },
                                            child: Text('Return to Login',
                                                style: TextStyle(
                                                  color: Colors.grey[300],
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 10.sp,
                                                )),
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        margin: EdgeInsets.fromLTRB(
                                            0, 20.h, 24.w, 0),
                                        padding: EdgeInsets.all(3.r),
                                        width: 145.w,
                                        height: 75.h,
                                        decoration: BoxDecoration(
                                            color: Colors.deepPurple,
                                            borderRadius:
                                                BorderRadius.circular(12.r)),
                                        child: Center(
                                          child: TextButton(
                                            onPressed: () async {
                                              if (_key.currentState!
                                                  .validate()) {
                                                try {
                                                  await FirebaseAuth.instance
                                                      .createUserWithEmailAndPassword(
                                                    email: emailController.text,
                                                    password:
                                                        passwordController.text,
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
                                                  fontSize: 10.sp,
                                                )),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                          ],
                        ),
                      ),
                    )));
          }
        }
      });
}
