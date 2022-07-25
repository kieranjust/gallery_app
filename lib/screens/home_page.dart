import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gallery_app/screens/image_view.dart';
import 'package:gallery_app/storage_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  int columnsPortrait = 3;
  int columnsLandscape = 5;
  final fileNameController = TextEditingController();
  final urlController = TextEditingController();
  String imageUrl = '';
  String imageFileName = '';
  String sortBy = 'filename';
  bool sortDecending = false;
  Stream<QuerySnapshot> get galleryStream => firestore
      .collection('users/$uid/images')
      .orderBy(sortBy, descending: sortDecending)
      .snapshots();

  @override
  Widget build(BuildContext context) => OrientationBuilder(
        builder: (context, orientation) {
          final isPortrait = orientation == Orientation.portrait;
          {
            User? user = FirebaseAuth.instance.currentUser;

            if (user == null) {
              return const LoginPage();
            } else {
              uid = user.uid;
              return Scaffold(
                  backgroundColor: Colors.grey[900],
                  appBar: AppBar(
                    backgroundColor: Colors.black,
                    title: const Text(
                      'Gallery App',
                      style: TextStyle(color: Colors.deepPurple),
                    ),
                    actions: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.add_a_photo),
                        color: Colors.deepPurple,
                        onPressed: () {
                          uploadImageBuilder();
                        },
                      ),
                      IconButton(
                        icon: const Icon(CupertinoIcons.square_grid_2x2),
                        color: Colors.deepPurple,
                        onPressed: () {
                          if (columnsPortrait == 3) {
                            columnsPortrait = 5;
                            columnsLandscape = 8;
                          } else {
                            columnsPortrait = 3;
                            columnsLandscape = 5;
                          }
                          setState(() {});
                        },
                      ),
                      IconButton(
                        icon: const Icon(CupertinoIcons.sort_down),
                        color: Colors.deepPurple,
                        onPressed: () {
                          setState(() {});
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout),
                        color: Colors.deepPurple,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                  backgroundColor: Colors.grey[900],
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  elevation: 16,
                                  child: SizedBox(
                                      height: 90.h,
                                      width: 220.w,
                                      child: ListView(children: [
                                        Text(
                                          "Confirm Logout",
                                          style: TextStyle(
                                              color: Colors.deepPurple,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 24.sp),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(
                                          width: 220.w,
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 16.0.h,
                                                    vertical: 8.0.w),
                                                child: TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text(
                                                      'Cancel',
                                                      style: TextStyle(
                                                          color: Colors.purple),
                                                    )),
                                              ),
                                              const Spacer(),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 16.0.w,
                                                    vertical: 8.0.w),
                                                child: TextButton(
                                                  child: const Text(
                                                    'Logout',
                                                    style: TextStyle(
                                                      color: Colors.purple,
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    try {
                                                      await FirebaseAuth
                                                          .instance
                                                          .signOut()
                                                          .then(((value) =>
                                                              Navigator.pop(
                                                                  context)));
                                                      setState(() {});
                                                    } on FirebaseAuthException catch (error) {
                                                      errorMessage =
                                                          error.message!;
                                                    }
                                                  },
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ])));
                            },
                          );
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
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 475.h,
                            width: 400.w,
                            child: StreamBuilder<QuerySnapshot>(
                                stream: galleryStream,
                                builder: (context, snapshot) {
                                  return snapshot.hasError
                                      ? const Center(
                                          child: Text(
                                              'There was a problem loading your images.'),
                                        )
                                      : snapshot.hasData
                                          ? SizedBox(
                                              child: GridView.count(
                                                crossAxisCount: isPortrait
                                                    ? columnsPortrait
                                                    : columnsLandscape,
                                                mainAxisSpacing: 8,
                                                crossAxisSpacing: 4,
                                                children: snapshot.data!.docs
                                                    .map(
                                                        (image) =>
                                                            GestureDetector(
                                                                onTap: () {
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder:
                                                                              (_) {
                                                                    return ImageView(
                                                                        image);
                                                                  }));
                                                                },
                                                                child:
                                                                    Container(
                                                                  decoration: BoxDecoration(
                                                                      color: Colors
                                                                          .transparent,
                                                                      borderRadius:
                                                                          BorderRadius.all(
                                                                              Radius.circular(12.r)),
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                            color: Colors.black.withOpacity(
                                                                                0.5),
                                                                            spreadRadius:
                                                                                2,
                                                                            blurRadius:
                                                                                6,
                                                                            offset:
                                                                                const Offset(0, 0))
                                                                      ]),
                                                                  child: ClipRRect(
                                                                      borderRadius: BorderRadius.all(Radius.circular(12.r)),
                                                                      child: CachedNetworkImage(
                                                                        imageUrl:
                                                                            image.get('url'),
                                                                        placeholder:
                                                                            (context, url) =>
                                                                                const CircularProgressIndicator(),
                                                                        errorWidget: (context,
                                                                                url,
                                                                                error) =>
                                                                            const Icon(Icons.error),
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      )),
                                                                )))
                                                    .toList(),
                                              ),
                                            )
                                          : const Center(
                                              child: Text(
                                                  'You do not have any images.'));
                                }),
                          ),
                          isPortrait
                              ? FloatingActionButton(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.black,
                                  onPressed: () {
                                    uploadImageBuilder();
                                  },
                                  child: const Icon(Icons.add_a_photo),
                                )
                              : const SizedBox(
                                  height: 0,
                                ),
                        ],
                      ),
                    ),
                  ));
            }
          }
        },
      );

  Future uploadImage(ImageSource source) async {
    final rename = TextEditingController();
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      final displayImage = File(image.path);
      final imageTemporary = XFile(image.path);
      setState(() => this.image = imageTemporary);
      errorMessage = '';
      await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                'Confirm upload',
                style: TextStyle(color: Colors.deepPurple),
              ),
              backgroundColor: Colors.grey[900],
              content: Container(
                height: MediaQuery.of(context).size.height / 3,
                width: double.infinity,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: FileImage(displayImage), fit: BoxFit.cover)),
              ),
              actions: [
                SizedBox(
                  width: 300.w,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 220.w,
                        child: TextFormField(
                            controller: rename,
                            decoration: InputDecoration(
                              hintText: 'Image Name(Optional)',
                              hintStyle: TextStyle(color: Colors.grey[600]),
                            )),
                      ),
                      const Text('.jpg', style: TextStyle(color: Colors.purple))
                    ],
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel')),
                    const Spacer(),
                    TextButton(
                        onPressed: () {
                          if (rename.text.isEmpty) {
                            storage.uploadFile(image.path, image.name, uid);
                          } else {
                            storage
                                .uploadFile(
                                    image.path, "${rename.text}.jpg", uid)
                                .then(((value) => Navigator.pop(context)));
                          }
                        },
                        child: const Text('Confirm'))
                  ],
                ),
              ],
            );
          });
    } on PlatformException catch (error) {
      errorMessage = error.message!;
    }
  }

  uploadImageBuilder() {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
              backgroundColor: Colors.grey[900],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SingleChildScrollView(
                    child: SizedBox(
                        height: 190.h,
                        width: 190.w,
                        child: ListView(children: [
                          Text(
                            "Upload an Image",
                            style: TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold,
                                fontSize: 24.sp),
                            textAlign: TextAlign.center,
                          ),
                          TextButton(
                              child: Text('Pick from gallery',
                                  style: TextStyle(
                                      color: Colors.purple, fontSize: 16.sp)),
                              onPressed: () => uploadImage(ImageSource.gallery)
                                      .then((value) {
                                    Navigator.pop(context);
                                  })),
                          TextButton(
                            child: Text('Pick from camera',
                                style: TextStyle(
                                    color: Colors.purple, fontSize: 16.sp)),
                            onPressed: () =>
                                uploadImage(ImageSource.camera).then((value) {
                              Navigator.pop(context);
                            }),
                          ),
                          TextButton(
                            child: Text('Pick from URL',
                                style: TextStyle(
                                    color: Colors.purple, fontSize: 16.sp)),
                            onPressed: () {
                              uploadImageFromURLBuilder();
                            },
                          )
                        ])),
                  ),
                ],
              ));
        });
  }

  uploadImageFromURLBuilder() {
    {
      showDialog(
          context: context,
          builder: (context) {
            return Dialog(
                backgroundColor: Colors.grey[900],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 16,
                child: SizedBox(
                    height: 240.h,
                    width: 220.w,
                    child: ListView(children: [
                      Text(
                        "Upload with URL",
                        style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                            fontSize: 24.sp),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        width: 220.w,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0.w, vertical: 8.0.h),
                          child: TextFormField(
                              controller: urlController,
                              decoration: InputDecoration(
                                hintText: 'Enter image URL',
                                hintStyle: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              )),
                        ),
                      ),
                      SizedBox(
                        width: 220.w,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 220.w,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.0.w, vertical: 8.0.h),
                                child: TextFormField(
                                    controller: fileNameController,
                                    decoration: InputDecoration(
                                      hintText: 'Image Name(Optional)',
                                      hintStyle:
                                          TextStyle(color: Colors.grey[600]),
                                    )),
                              ),
                            ),
                            const Text('.jpg',
                                style: TextStyle(color: Colors.purple))
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 220.w,
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.0.h, vertical: 8.0.w),
                              child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.purple),
                                  )),
                            ),
                            const Spacer(),
                            Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.0.w, vertical: 8.0.w),
                                child: TextButton(
                                    child: const Text(
                                      'Upload',
                                      style: TextStyle(color: Colors.purple),
                                    ),
                                    onPressed: () {
                                      uploadImageFromURL(urlController.text,
                                          fileNameController.text);
                                    }))
                          ],
                        ),
                      )
                    ])));
          });
    }
  }

  Future uploadImageFromURL(String imageUrl, String imageFileName) async {
    try {
      //TODO: Remove whitespace at bottom of dialog
      await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                title: const Text('Confirm upload',
                    style: TextStyle(color: Colors.deepPurple)),
                backgroundColor: Colors.grey[900],
                content: Column(children: [
                  Container(
                      height: 240.h,
                      width: 220.w,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover))),
                  SizedBox(
                    height: 50.h,
                    child: Row(
                      children: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel')),
                        const Spacer(),
                        TextButton(
                            onPressed: () async {
                              await firestore
                                  .collection('users/$uid/images')
                                  .add({
                                    'url': imageUrl,
                                    'filename': '$imageFileName.jpg',
                                    'uploaded by': uid,
                                    'uploaded': DateTime.now(),
                                    'favorite': 0,
                                    'savedFromUrl': 1,
                                  })
                                  .whenComplete(() => print(
                                      "$imageFileName Image reference saved in Firestore."))
                                  .then((value) => Navigator.pop(context))
                                  .then((value) => Navigator.pop(context));
                            },
                            child: const Text('Confirm'))
                      ],
                    ),
                  )
                ]));
          });
    } on PlatformException catch (error) {
      errorMessage = error.message!;
    }
  }
}
