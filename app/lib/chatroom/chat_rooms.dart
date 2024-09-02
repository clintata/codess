import 'package:app/assets/functions.dart';
import 'package:app/chatroom/add_chart.dart';
import 'package:app/code.dart';
import 'package:app/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'chat_page.dart';

/// Displays all user chatrooms. Users may add new chats as needed.
class ChatRoomsPage extends StatefulWidget {
  const ChatRoomsPage({super.key});

  @override
  State<ChatRoomsPage> createState() => _ChatRoomsPageState();
}

class _ChatRoomsPageState extends State<ChatRoomsPage> {
  /// Used for multi selection delete
  late List<bool> selection;
  bool isEditMode = false;

  ///
  void editMode() {
    setState(() {
      isEditMode = !isEditMode;
    });
  }

  @override
  void initState() {
    debugPrint(uid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: parentPrimaryColor,

        /// Change appbar icons & color when in edit mode
        appBar: AppBar(
          leading: isEditMode
              ? IconButton(
                  onPressed: () {
                    editMode();
                  },
                  icon: const Icon(Icons.close))
              : null,
          backgroundColor: isEditMode ? Colors.amberAccent : Colors.greenAccent,
          title: isEditMode
              ? const Text('Select chats')
              : const Text(
                  'Chats',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
          centerTitle: true,
        ),
        body:
            // get user chatrooms
            StreamBuilder(
                stream: db
                    .collection('chatrooms')
                    .where('parent', isEqualTo: uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  catchConnectionState(context, snapshot);
                  // If the parent has not existing, display no chats page
                  if (snapshot.hasData) {
                    final parentChats = snapshot.data;
                    if (parentChats == null || parentChats.docs.isEmpty) {
                      return const NoChats();
                    }
                    // Return chats page with a floating search bar below appbar
                    return Column(
                      children: [
                        Expanded(
                            child: Chats(
                          editMode: editMode,
                          chatsSnapshot: parentChats,
                        ))
                      ],
                    );
                  }
                  return const Loading();
                }),
        // Floating action button to add new chats
        floatingActionButton: const ChatFAB());
  }
}

// The existing chats of the user
class Chats extends StatefulWidget {
  const Chats({super.key, required this.chatsSnapshot, this.editMode});
  final void Function()? editMode;
  final QuerySnapshot<Map<String, dynamic>>? chatsSnapshot;

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.chatsSnapshot?.docs.length ?? 1,
      itemBuilder: (context, index) {
        // get the teacher doc id
        return FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('teachers')
                .doc(widget.chatsSnapshot?.docs[index].get('teacher'))
                .get(),
            builder: (context, teacherData) {
              catchConnectionState(context, teacherData);
              if (!teacherData.hasData || teacherData.data == null) {
                return Container(
                  color: Colors.grey,
                );
              }
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  tileColor: Colors.greenAccent.withOpacity(0.5),
                  onTap: () {
                    navPush(
                        context,
                        ChatRoom(
                            teacherID: teacherData.data?.id ?? '',
                            chatroomID: widget.chatsSnapshot?.docs[index].id));
                  },
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  leading: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(50)),
                      ),
                      height: 50,
                      width: 50,
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(50)),
                        child: Image.network(
                          teacherData.data?.get('profilePic') ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              defaultProfilePic,
                        ),
                      ),
                    ),
                  ),
                  title: Text(teacherData.data?.get('name') ?? ''),
                ),
              );
            });
      },
    );
  }
}

// Displayed if the user has no existing chats
class NoChats extends StatelessWidget {
  const NoChats({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image(
            image: Image.asset('assets/nothing.gif').image,
            height: 200,
            width: 200,
          ),
          const Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Nothing yet ..'),
          ),
          const SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }
}

// Calls the AddPage() widget when pressed
class ChatFAB extends StatelessWidget {
  const ChatFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10, bottom: 20),
      child: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddChat()));
        },
        icon: const Icon(Icons.add),
        label: const Text('New'),
      ),
    );
  }
}
