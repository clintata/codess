import 'package:app/code.dart';
import 'package:app/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Deletes a chatroom
Future<void> deleteChatRoom(BuildContext context, String? chatroomID) async {
  try {
    if (chatroomID != null) {
      /// Delete top-leve doc first to remove from user UI (doesn't remove nested collections)
      await FirebaseFirestore.instance.doc('chatrooms/$chatroomID').delete();

      /// Delete all nested messages in subcollection (don't await)
      deleteMessages(chatroomID);
      if (!context.mounted) return;

      /// Go back to previous page, typically the ChatroomsPage
      pop(context);
      if (!context.mounted) return;

      /// Notify user of successful delete
      showSnackBar(
          context: context,
          label: 'Chat deleted successfully',
          bgColor: Colors.green);
    } else {
      debugPrint('ChatroomID was null');
    }
  } on FirebaseException catch (e) {
    debugPrint(e.message.toString());
  }
}

Future<void> deleteMessages(String chatroomID) async {
  final chatroomMessages = await FirebaseFirestore.instance
      .collection('chatrooms/$chatroomID/messages')
      .get();
  for (var message in chatroomMessages.docs) {
    message.reference.delete();
  }
}

void pop(BuildContext context) {
  Navigator.pop(context);
}

void pushUntilAndRemove(BuildContext context, Widget widget) {
  Navigator.pushAndRemoveUntil(context,
      MaterialPageRoute(builder: (context) => widget), (route) => false);
}

final Query<Map<String, dynamic>> classRecordsRef =
    db.collection('classRecords').where('teacher', isEqualTo: uid);

Widget? catchConnectionState(BuildContext context, AsyncSnapshot snapshot) {
  if (snapshot.connectionState == ConnectionState.none) {
    return const NoInternet();
  }

  if (snapshot.connectionState == ConnectionState.waiting) {
    return const Loading();
  }

  if (snapshot.hasError) {
    return const UnknownError();
  }

  if (!snapshot.hasData || snapshot.data == null) {}
  return null;
}

class NoInternet extends StatelessWidget {
  const NoInternet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: const Text('You are not connected to the internet'),
    );
  }
}

class UnknownError extends StatelessWidget {
  const UnknownError({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: const Text('Sorry, an unknown error occurred.'),
    );
  }
}
