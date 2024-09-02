import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// the physical screen size (as opposed to MediaQuery)
final FlutterView view = PlatformDispatcher.instance.views.first;

// firestore instance
final FirebaseFirestore db = FirebaseFirestore.instance;

// firebase auth instance
final FirebaseAuth auth = FirebaseAuth.instance;

// current user uid
String? uid = auth.currentUser?.uid;
String? userName = auth.currentUser?.displayName;
String? userEmail = auth.currentUser?.email;

// default colors in app
const Color parentPrimaryColor = Color.fromARGB(255, 224, 246, 224);
const Color teacherPrimaryColor = Colors.greenAccent;

String? fireErrors(BuildContext context, FirebaseException e) {
  debugPrint(e.code);
  debugPrint(e.message);
  switch (e.code) {
    case 'too-many-requests':
      showSnackBar(
          context: context,
          label: 'Too many login requests. Try again later',
          bgColor: Colors.red);
      return 'Too many login requests. Try again later';
    case 'network-request-failed':
      showSnackBar(
          context: context, label: 'Network Problem!', bgColor: Colors.red);
      return 'Network Problem!';
    case 'invalid-credential':
      showSnackBar(
          context: context,
          label: 'Incorrect credentials.',
          bgColor: Colors.red);
      return 'Incorrect credentials.';
    case 'invalid-email':
      showSnackBar(
          context: context, label: 'Incorrect email.', bgColor: Colors.red);
      return 'Incorrect email.';
    case 'email-already-in-use':
      showSnackBar(
          context: context,
          label: 'Account already exists',
          bgColor: Colors.red);
      return 'Account already exists';
    default:
      showSnackBar(
          context: context, label: 'Something went wrong', bgColor: Colors.red);
      return null;
  }
}

double screenH(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

double screenW(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

void navPush(BuildContext context, Widget widget) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => widget));
}

void navPop(BuildContext context, [dynamic result]) {
  Navigator.pop(context, result);
}

void navPushReplacement(BuildContext context, Widget widget) {
  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => widget));
}

void showSnackBar(
    {required BuildContext context, required String label, Color? bgColor}) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Center(child: Text(label)),
    backgroundColor: bgColor,
  ));
}

void showSnackBarError(BuildContext context, String label) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Center(child: Text(label)),
    backgroundColor: Colors.red,
  ));
}

void showSnackBarSuccess(BuildContext context, String label) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Center(child: Text(label)),
    backgroundColor: Colors.green,
  ));
}

void showSnackBarInfo(BuildContext context, String label) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Center(child: Text(label)),
    backgroundColor: Colors.blue,
  ));
}

EdgeInsetsGeometry listTilePadding =
    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5);

class Validators {
  static final RegExp email = RegExp(
      r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
      r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
      r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
      r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
      r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
      r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
      r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])');
  static final RegExp name = RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%0-9-]');
  static RegExp contactNumber = RegExp(r'^\d{10}$');
}

class UserData {
  static String? name;
  static String? email;
  static int? contactNumber;

  static Future<void> updateDetails(
      BuildContext context, String collection) async {
    try {
      await FirebaseFirestore.instance
          .doc('$collection/${FirebaseAuth.instance.currentUser?.uid}')
          .get()
          .then((snapshot) {
        name = snapshot['name'];
        email = snapshot['email'];
        contactNumber = snapshot['contactNumber'];
      });
    } on FirebaseException catch (e) {
      if (!context.mounted) return;
      fireErrors(context, e);
      debugPrint(e.toString());
    }
  }
}

ThemeData theme(BuildContext context) {
  return Theme.of(context);
}

Widget listItem(BuildContext context, Widget title,
    {Widget? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    EdgeInsets? contentPadding,
    EdgeInsets? padding}) {
  return Padding(
    padding:
        padding ?? const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    child: ListTile(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))),
      contentPadding: contentPadding ?? listTilePadding,
      onTap: onTap,
      tileColor: Colors.green[100],
      title: title,
      subtitle: subtitle,
      trailing: trailing,
    ),
  );
}
