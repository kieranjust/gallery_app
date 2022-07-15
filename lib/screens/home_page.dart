import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gallery_app/storage_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  XFile? image;
  final Storage storage = Storage();
  List<XFile> imageList = [];
  String errorMessage = '';
  String uid = '';

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const LoginPage();
    } else {
      uid = user.uid;
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('Gallery App'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(CupertinoIcons.square_grid_2x2),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(CupertinoIcons.sort_down),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  setState(() {});
                } on FirebaseAuthException catch (error) {
                  errorMessage = error.message!;
                }
              },
            ),
            Center(
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            )
          ],
        ),
        body: Container(
          padding: EdgeInsets.all(8.r),
          child: Column(
            children: [
              SizedBox(
                height: 475.h,
                width: 400.w,
                child: StreamBuilder<QuerySnapshot>(
                    stream:
                        firestore.collection('users/$uid/images').snapshots(),
                    builder: (context, snapshot) {
                      return snapshot.hasError
                          ? const Center(
                              child: Text(
                                  'There was a problem loading your images.'),
                            )
                          : snapshot.hasData
                              ? GridView.count(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 8,
                                  childAspectRatio: 1,
                                  children: snapshot.data!.docs
                                      .map((e) => Image.network(e.get('url')))
                                      .toList(),
                                )
                              : const Center(
                                  child: Text('You do not have any images.'));
                    }),
              ),
              FloatingActionButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 16,
                          child: SizedBox(
                            height: 175.h,
                            width: 70.w,
                            child: ListView(
                              children: [
                                Text(
                                  "Upload an Image",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24.sp),
                                  textAlign: TextAlign.center,
                                ),
                                TextButton(
                                    child: Text('Pick from gallery',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16.sp)),
                                    onPressed: () =>
                                        uploadImage(ImageSource.gallery)),
                                TextButton(
                                    child: Text('Pick from camera',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16.sp)),
                                    onPressed: () =>
                                        uploadImage(ImageSource.camera)),
                                TextButton(
                                    child: Text('Pick from URL',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16.sp)),
                                    onPressed: () {}),
                              ],
                            ),
                          ),
                        );
                      });
                },
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      );
    }
  }

  Future uploadImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;

      final imageTemporary = XFile(image.path);
      setState(() => this.image = imageTemporary);
      errorMessage = '';

      storage.uploadFile(image.path, image.name, uid);
    } on PlatformException catch (error) {
      errorMessage = error.message!;
    }
  }
}
