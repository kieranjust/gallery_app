import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gallery_app/storage_service.dart';
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
    final Storage storage = Storage();
    User? user = FirebaseAuth.instance.currentUser;
    String? uid = '';
    final renameController = TextEditingController();
    Timestamp uploaded = widget.image.get('uploaded');
    DateTime uploadedAt = uploaded.toDate();
    String uploadedAtFormatted = DateFormat.yMEd().format(uploadedAt);
    String filename = widget.image.get('filename');
    String url = widget.image.get('url');
    String docId = widget.image.reference.id;

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
            BackButton(onPressed: () => Navigator.of(context).pop()),
            const Spacer(),
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
                                                      filename =
                                                          '${renameController.text}.jpg';
                                                      Navigator.of(context)
                                                          .pop(filename);
                                                    },
                                                  );
                                                }))
                                      ],
                                    ),
                                  ),
                                ])));
                      });
                },
                icon: const Icon(Icons.edit)),
            const Spacer(),
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
                              height: 80.h,
                              width: 220.w,
                              child: ListView(children: [
                                Text(
                                  "Delete Image",
                                  style: TextStyle(
                                      color: Colors.grey[900],
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
                                          child: Container(
                                            height: 40.h,
                                            padding: EdgeInsets.all(4.r),
                                            decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        12.r)),
                                            child: TextButton(
                                                child: const Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                onPressed: () async {
                                                  await storage
                                                      .deleteFile(
                                                          url, uid!, docId)
                                                      .then((value) {})
                                                      .then(
                                                    (value) {
                                                      Navigator.of(context)
                                                          .pop();
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  );
                                                }),
                                          ))
                                    ],
                                  ),
                                ),
                              ])));
                    });
              },
              icon: const Icon(Icons.delete),
            )
          ],
        )
      ],
    ));
  }
}
