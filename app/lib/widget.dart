import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Image defaultProfilePic = Image.asset(
  'assets/user.png',
  fit: BoxFit.cover,
);

enum UserRole { parent, teacher }

enum Collection { parents, teachers, chatrooms }

class ProfilePic extends StatelessWidget {
  const ProfilePic({super.key, required this.collection});
  final Collection collection;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .doc('${collection.name}/${FirebaseAuth.instance.currentUser?.uid}')
          .snapshots(),
      builder: (context, snapshot) {
        debugPrint(snapshot.data?.id);
        if (snapshot.hasData) {
          String profilePic = snapshot.data?.get('profilePic') ?? '';
          if (profilePic.isNotEmpty) {
            return Image.network('${snapshot.data?.get('profilePic')}',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    defaultProfilePic);
          } else {
            return defaultProfilePic;
          }
        }
        return const Loading();
      },
    );
  }
}

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Loading(),
    );
  }
}

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
