import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart' as cloud_firestore;

class Storage {
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  final cloud_firestore.FirebaseFirestore firestore =
      cloud_firestore.FirebaseFirestore.instance;

  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> uploadFile(
    String filePath,
    String fileName,
    String uid,
  ) async {
    File file = File(filePath);
    String url;
    try {
      await storage.ref('images/$uid/$fileName').putFile(file);
      url = await storage.ref('images/$uid/$fileName').getDownloadURL();
      await firestore.collection('users/$uid/images').add({
        'url': url,
        'filename': fileName,
        'uploaded by': uid,
        'uploaded': DateTime.now(),
        'favorite': false,
        'savedFromUrl': false,
      }).whenComplete(() => print(
          "$fileName uploaded to Firebase Storage and reference saved in Firestore."));
    } on firebase_core.FirebaseException catch (error) {
      print(error);
    }
  }

  Future<void> deleteFile(
    String url,
    String uid,
    String docId,
    bool savedFromUrl,
  ) async {
    // Images saved from url do not have
    if (savedFromUrl == false) {
      try {
        await firestore
            .collection('users/$uid/images')
            .doc(docId)
            .delete()
            .whenComplete(() => print("Document deleted from Firestore."));
        await storage
            .refFromURL(url)
            .delete()
            .whenComplete(() => print('Document deleted from storage.'));
      } on firebase_core.FirebaseException catch (error) {
        print(error);
      }
    } else {
      await firestore
          .collection('users/$uid/images')
          .doc(docId)
          .delete()
          .whenComplete(() => print("Document deleted from Firestore."));
    }
  }
}
