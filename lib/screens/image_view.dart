import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:photo_view/photo_view.dart';
import 'package:intl/intl.dart';

import 'home_page.dart';

class ImageView extends StatefulWidget {
  QueryDocumentSnapshot<Object?> image;
  ImageView(this.image, {Key? key}) : super(key: key);

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  @override
  Widget build(BuildContext context) {
    Timestamp uploaded = widget.image.get('uploaded');
    DateTime uploadedAt = uploaded.toDate();
    String uploadedAtFormatted = DateFormat.yMEd().format(uploadedAt);
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
            Filename: ${widget.image.get('filename')}
            Uploaded by: ${widget.image.get('uploaded by')}
            Uploaded at: $uploadedAtFormatted
          ''',
            ),
          ],
        ),
        BackButton(
            onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: ((context) => const HomePage()))))
      ],
    ));
  }
}
