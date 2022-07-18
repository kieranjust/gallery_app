import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_view/photo_view.dart';
import 'package:intl/intl.dart';

import 'home_page.dart';

class ImageView extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> image;
  const ImageView(this.image, {Key? key}) : super(key: key);

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? user = FirebaseAuth.instance.currentUser;
    String? uid = '';
    final renameController = TextEditingController();
    Timestamp uploaded = widget.image.get('uploaded');
    DateTime uploadedAt = uploaded.toDate();
    String uploadedAtFormatted = DateFormat.yMEd().format(uploadedAt);
    String filename = widget.image.get('filename');
    uid = user?.uid;
    return Scaffold(
        body: Column(
      children: [
        Expanded(
            child: GestureDetector(
                child: Center(
                    child: PhotoView(
                  imageProvider:
                      CachedNetworkImageProvider(widget.image.get('url')),
                )),
                onTap: () {
                  Navigator.of(context).pop();
                })),
        Column(
          children: [
            Text(
              '''
            Filename: $filename;
            Uploaded by: ${widget.image.get('uploaded by')}
            Uploaded at: $uploadedAtFormatted
              ''',
            ),
          ],
        ),
        Row(
          children: [
            BackButton(
                onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: ((context) => const HomePage())))),
            IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                            backgroundColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 16,
                            child: SizedBox(
                                height: 140.h,
                                width: 220.w,
                                child: ListView(children: [
                                  Text(
                                    "Rename Image",
                                    style: TextStyle(
                                        color: Colors.grey[900],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24.sp),
                                    textAlign: TextAlign.center,
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 160.w,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0, vertical: 8.0),
                                          child: TextFormField(
                                              controller: renameController,
                                              decoration: const InputDecoration(
                                                  hintText:
                                                      'Enter new filename')),
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text('.jpg'),
                                      )
                                    ],
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
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text(
                                                'Cancel',
                                                style: TextStyle(
                                                    color: Colors.deepPurple),
                                              )),
                                        ),
                                        const Spacer(),
                                        Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16.0.w,
                                                vertical: 8.0.w),
                                            child: TextButton(
                                                child: const Text(
                                                  'Rename',
                                                  style: TextStyle(
                                                      color: Colors.deepPurple),
                                                ),
                                                onPressed: () async {
                                                  await firestore
                                                      .collection(
                                                          'users/$uid/images')
                                                      .doc(widget.image.id)
                                                      .update({
                                                    'filename':
                                                        '${renameController.text}.jpg'
                                                  }).then(
                                                    (value) {
                                                      // TODO: Get name updating
                                                      Navigator.of(context)
                                                          .pop();
                                                      setState(
                                                        () {
                                                          filename =
                                                              '${renameController.text}.jpg';
                                                        },
                                                      );
                                                    },
                                                  );
                                                }))
                                      ],
                                    ),
                                  ),
                                ])));
                      });
                },
                icon: const Icon(Icons.edit))
          ],
        )
      ],
    ));
  }
}
