import 'dart:ffi';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:favorite_button/favorite_button.dart';
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
  Widget build(BuildContext context) =>
      OrientationBuilder(builder: (context, orientation) {
        final isPortrait = orientation == Orientation.portrait;
        {
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
          bool favorite = widget.image.get('favorite');
          int savedFromUrl = widget.image.get('savedFromUrl');

          uid = user?.uid;
          return Scaffold(
              backgroundColor: Colors.black,
              body: Column(
                children: [
                  Expanded(
                      child: GestureDetector(
                          child: Center(
                              child: ClipRect(
                            child: PhotoView(
                              imageProvider: CachedNetworkImageProvider(
                                  widget.image.get('url')),
                            ),
                          )),
                          onTap: () {
                            Navigator.of(context).pop();
                          })),
                  Column(
                    children: [
                      SizedBox(height: 10.h),
                      isPortrait
                          ? Text('''
            Filename: $filename;
            Uploaded by: ${widget.image.get('uploaded by')}
            Uploaded at: $uploadedAtFormatted
              ''', style: TextStyle(color: Colors.grey[100]))
                          : const SizedBox(height: 0),
                    ],
                  ),
                  Row(
                    children: [
                      BackButton(
                        onPressed: () => Navigator.of(context).pop(),
                        color: Colors.deepPurple,
                      ),
                      const Spacer(),
                      FavoriteButton(
                          iconSize: 45,
                          isFavorite: favorite,
                          iconColor: Colors.deepPurple,
                          valueChanged: (favorite) {
                            if (favorite == false) {
                              firestore
                                  .collection('users/$uid/images')
                                  .doc(widget.image.id)
                                  .update(
                                {'favorite': false},
                              );
                            } else {
                              firestore
                                  .collection('users/$uid/images')
                                  .doc(widget.image.id)
                                  .update(
                                {'favorite': true},
                              );
                            }
                          }),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                    backgroundColor: Colors.grey[900],
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    elevation: 16,
                                    child: SizedBox(
                                        height: 160.h,
                                        width: 220.w,
                                        child: ListView(children: [
                                          Text(
                                            "Rename Image",
                                            style: TextStyle(
                                                color: Colors.deepPurple,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 24.sp),
                                            textAlign: TextAlign.center,
                                          ),
                                          Row(
                                            children: [
                                              SizedBox(
                                                width: 170.w,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 16.0,
                                                      vertical: 8.0),
                                                  child: TextFormField(
                                                    controller:
                                                        renameController,
                                                    decoration: InputDecoration(
                                                        hintText:
                                                            'Enter new filename',
                                                        hintStyle: TextStyle(
                                                            color: Colors
                                                                .grey[600])),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  '.jpg',
                                                  style: TextStyle(
                                                      color: Colors.grey[600]),
                                                ),
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
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: const Text(
                                                        'Cancel',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.purple),
                                                      )),
                                                ),
                                                const Spacer(),
                                                Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 16.0.w,
                                                            vertical: 8.0.w),
                                                    child: TextButton(
                                                        child: const Text(
                                                          'Rename',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .purple),
                                                        ),
                                                        onPressed: () async {
                                                          await firestore
                                                              .collection(
                                                                  'users/$uid/images')
                                                              .doc(widget
                                                                  .image.id)
                                                              .update({
                                                            'filename':
                                                                '${renameController.text}.jpg'
                                                          }).then(
                                                            (value) {
                                                              // TODO: Get name updating
                                                              filename =
                                                                  '${renameController.text}.jpg';
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(
                                                                      filename);
                                                            },
                                                          );
                                                        }))
                                              ],
                                            ),
                                          ),
                                        ])));
                              });
                        },
                        icon: const Icon(Icons.edit),
                        color: Colors.deepPurple,
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                    backgroundColor: Colors.grey[900],
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    elevation: 16,
                                    child: SizedBox(
                                        height: 90.h,
                                        width: 220.w,
                                        child: ListView(children: [
                                          Text(
                                            "Delete Image",
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
                                                            color:
                                                                Colors.purple),
                                                      )),
                                                ),
                                                const Spacer(),
                                                Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 16.0.w,
                                                            vertical: 8.0.w),
                                                    child: Container(
                                                      height: 40.h,
                                                      padding:
                                                          EdgeInsets.all(4.r),
                                                      decoration: BoxDecoration(
                                                          color: Colors.red,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      12.r)),
                                                      child: TextButton(
                                                          child: Text(
                                                            'Delete',
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .grey[900],
                                                            ),
                                                          ),
                                                          onPressed: () async {
                                                            await storage
                                                                .deleteFile(
                                                                    url,
                                                                    uid!,
                                                                    docId,
                                                                    savedFromUrl)
                                                                .then(
                                                              (value) {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                Navigator.of(
                                                                        context)
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
                        color: Colors.deepPurple,
                      )
                    ],
                  )
                ],
              ));
        }
      });
}
