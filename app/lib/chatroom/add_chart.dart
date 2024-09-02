import 'package:app/assets/functions.dart';
import 'package:app/code.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widget.dart';
import 'chat_page.dart';

class AddChat extends StatefulWidget {
  const AddChat({super.key});

  @override
  State<AddChat> createState() => _AddChatState();
}

class _AddChatState extends State<AddChat> {
  List<String> existingTeacherIDs = [];

  void goToChat(String chatID, String teacherID) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ChatRoom(chatroomID: chatID, teacherID: teacherID)));
  }

  Future<bool> chatRoomNotExisting(String teacherID) async {
    try {
      QuerySnapshot<Map<String, dynamic>> existingRoom = await FirebaseFirestore
          .instance
          .collection('chatroom')
          .where('users', isEqualTo: uid)
          .where('teacher', isEqualTo: teacherID)
          .get();
      if (existingRoom.docs.isEmpty) {
        return true;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return false;
  }

  void createChatroom(String? teacherID) async {
    if (teacherID != null) {
      if (await chatRoomNotExisting(teacherID)) {
        Map<String, dynamic> newChatroom = {
          'dateCreated': FieldValue.serverTimestamp(),
          'teacher': teacherID,
          'parent': FirebaseAuth.instance.currentUser?.uid ?? '',
        };
        try {
          await FirebaseFirestore.instance
              .collection('chatroom')
              .add(newChatroom);
          final teacherChatRoom = await FirebaseFirestore.instance
              .collection('chatroom')
              .where('teacher', isEqualTo: teacherID)
              .get();
          goToChat(teacherChatRoom.docs.first.id, teacherID);
        } on FirebaseException catch (e) {
          debugPrint(e.message.toString());
        }
      }
    }
  }

  Widget getProfilePic(String? link) {
    if (link != null) {
      return Image.network(
        link,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => defaultProfilePic,
      );
    } else {
      return defaultProfilePic;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: parentPrimaryColor,
      appBar: AppBar(
        title: const Text('Add New Chat'),
        backgroundColor: Color.fromARGB(255, 27, 106, 171),
      ),
      body: FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('chatroom')
              .where('parent', isEqualTo: '$uid')
              .get(),
          builder: (context, existingChats) {
            catchConnectionState(context, existingChats);

            /// Check if there are existing chats
            if (existingChats.hasData || existingChats.data?.docs != null) {
              /// Save all the teacher ids
              for (final doc in existingChats.data!.docs) {
                existingTeacherIDs.add(doc.get('teacher'));
              }
            }
            return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('teachers')
                    .snapshots(),
                builder: (context, teachers) {
                  if (teachers.connectionState == ConnectionState.waiting) {
                    return const Loading();
                  }

                  if (!teachers.hasData || teachers.data?.docs == null) {
                    return const NoTeachers();
                  }

                  return Column(
                    children: [
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      ),
                      Expanded(
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: teachers.data?.docs.length ?? 1,
                            itemBuilder: (context, index) {
                              /// Loop through all existing chats
                              if (existingTeacherIDs
                                  .contains(teachers.data!.docs[index].id)) {
                                /// Return an empty container
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  tileColor:
                                      Colors.greenAccent.withOpacity(0.5),
                                  onTap: () {
                                    createChatroom(
                                        teachers.data?.docs[index].id);
                                  },
                                  title: Text(
                                      teachers.data?.docs[index].get('name') ??
                                          ''),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  trailing: const Padding(
                                    padding: EdgeInsets.only(right: 10.0),
                                    child: Icon(Icons.open_in_new_rounded),
                                  ),
                                  leading: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(50)),
                                      child: SizedBox(
                                          height: 50,
                                          width: 50,
                                          child: getProfilePic(teachers
                                              .data?.docs[index]
                                              .get('profilePic'))),
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ),
                    ],
                  );
                });
          }),
    );
  }
}

class NoTeachers extends StatelessWidget {
  const NoTeachers({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('No teachers found.. That\'s strange..'),
    );
  }
}
