import 'package:app/assets/functions.dart';
import 'package:app/code.dart';
import 'package:app/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatRoom extends StatefulWidget {
  const ChatRoom({super.key, required this.chatroomID, this.teacherID});
  final String? chatroomID;
  final String? teacherID;
  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  bool isEnabled = false;
  Widget sendingWidget = const SizedBox.shrink();

  /// Method to scroll down to bottom of chat when:
  /// - when this widget is first built
  /// - typing/sending new message
  void _scrollDown() {
    scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }

  /// Function to send message. Cannot reusable because it depends on setstate
  Future<void> sendMessage(String message) async {
    /// Show sending widget before attempting to send
    setState(() {
      sendingWidget = const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Text(
          'Sending ...',
          style: TextStyle(color: Colors.lightBlueAccent),
        ),
      );
    });
    try {
      /// Message doc fields in database
      Map<String, dynamic> newMessage = {
        'date': FieldValue.serverTimestamp(),
        'message': message,
        'sender': FirebaseAuth.instance.currentUser?.uid
      };

      /// Send the message
      await db
          .collection('chatrooms/${widget.chatroomID}/messages')
          .add(newMessage);
    } on FirebaseException catch (e) {
      /// Show the relevant error
      if (context.mounted) {
        showSnackBar(context: context, label: e.code, bgColor: Colors.red);
      }
    } finally {
      /// Remove the sending widget
      setState(() {
        sendingWidget = const SizedBox.shrink();
      });
    }
  }

  /// Attempt to get the message in doc.
  String getMessage(QueryDocumentSnapshot<Map<String, dynamic>>? doc) {
    try {
      return doc?.get('message');
    } catch (e) {
      return '';
    }
  }

  /// For debugging purposes
  @override
  void initState() {
    debugPrint('User uid: $uid');
    debugPrint('Chatroom: ${widget.chatroomID}');
    debugPrint('Teacher: ${widget.teacherID}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: ChatAppBar(
          teacherID: widget.teacherID,
        ),
        actions: [
          PopupMenuButton(
              itemBuilder: (context) => [
                    PopupMenuItem(
                        onTap: () {
                          deleteChatRoom(context, widget.chatroomID);
                        },
                        child: const Text('Delete chat')),
                  ]),
          const SizedBox(
            width: 5,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
                stream: db
                    .collection('chatrooms/${widget.chatroomID}/messages')
                    .orderBy('date', descending: true)
                    .snapshots(),
                builder: (context, messages) {
                  if (messages.hasData) {
                    return Scrollbar(
                      child: ListView.builder(
                          reverse: true,
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom),
                          controller: scrollController,
                          shrinkWrap: true,
                          itemCount: messages.data?.docs.length ?? 1,
                          itemBuilder: (context, index) {
                            /// If the message was sent by user, then it should be rendered on right side
                            if (messages.data?.docs[index]
                                    .get('sender')
                                    .toString()
                                    .contains(uid.toString()) ??
                                false) {
                              return RightChat(
                                  message:
                                      getMessage(messages.data?.docs[index]));
                            }

                            /// If the message was sent by teacher, then it should be rendered on left side
                            return LeftChat(
                                message:
                                    getMessage(messages.data?.docs[index]));
                          }),
                    );
                  }
                  return const Loading();
                }),
          ),

          /// Shows a sendingWidget whenever attempting to send a new message.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              sendingWidget,
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                    child: Container(
                  padding: const EdgeInsets.all(10),
                  constraints: const BoxConstraints(minHeight: 20),
                  child: SingleChildScrollView(
                    child: TextField(
                      onTap: () {
                        _scrollDown();
                      },
                      maxLines: null,
                      onChanged: (value) {
                        if (value.isEmpty) {
                          setState(() {
                            isEnabled = false;
                          });
                        } else {
                          setState(() {
                            isEnabled = true;
                          });
                        }
                      },
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                      ),
                    ),
                  ),
                )),
                const SizedBox(width: 8),
                IconButton(
                  color: isEnabled ? Colors.green : Colors.grey,
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (isEnabled == true) {
                      sendMessage(_messageController.text);
                      _messageController.clear();
                      setState(() {
                        isEnabled = false;
                      });
                      _scrollDown();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Renders a message on the right side of screen, occupying 1/3 of the screen width
class RightChat extends StatelessWidget {
  const RightChat({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth:
                    (view.physicalSize.width / view.devicePixelRatio) / 1.7,
              ),
              decoration: const BoxDecoration(
                color: Colors.greenAccent,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: ClipRRect(
                clipBehavior: Clip.antiAlias,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Text(
                    message,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

/// Renders a message on the left side of screen, occupying 1/3 of the screen width
class LeftChat extends StatefulWidget {
  const LeftChat({super.key, required this.message});
  final String message;

  @override
  State<LeftChat> createState() => _LeftChatState();
}

class _LeftChatState extends State<LeftChat> {
  @override
  Widget build(BuildContext context) {
    Widget deleteButton = const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          deleteButton,
          Flexible(
            child: GestureDetector(
              onLongPress: () {
                setState(() {
                  deleteButton = IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.delete_rounded,
                        color: Colors.red,
                      ));
                });
              },

              /// Container with its maxwidth set to roughly 1/3 of the screen
              child: Container(
                constraints: BoxConstraints(
                  maxWidth:
                      (view.physicalSize.width / view.devicePixelRatio) / 1.7,
                ),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),

                /// Make the message container have rounded corners
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),

                    /// Display the message
                    child: Text(
                      widget.message,
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

/// Displays the teacher profile pic & name in the appbar
class ChatAppBar extends StatelessWidget {
  const ChatAppBar({
    super.key,
    this.teacherID,
  });
  final String? teacherID;

  @override
  Widget build(BuildContext context) {
    /// If no teacher ID was received, then display this text
    if (teacherID == null) {
      return const Text('Teacher ID was blank');
    }

    /// Get the teacher data from teachers collection
    return FutureBuilder(
        future: db.doc('teachers/$teacherID').get(),
        builder: (context, teacherData) {
          catchConnectionState(context, teacherData);

          /// Display loading while waiting
          if (!teacherData.hasData) {
            return const Text('Loading ...');
          }

          /// Display blank instead if not found
          if (!teacherData.data!.exists) {
            return const Text('');
          }

          /// Display the profile pic and name of teacher
          return Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                child: SizedBox(
                    height: 35,
                    width: 35,

                    /// If teacher has no profile pic yet, display the default one
                    child: teacherData.data?.get('profilePic') != null
                        ? Image.network(
                            teacherData.data?.get('profilePic'),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                defaultProfilePic,
                          )
                        : defaultProfilePic),
              ),
              const SizedBox(
                width: 15,
              ),

              /// The teacher's name
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    teacherData.data?.get('name') ?? '',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            ],
          );
        });
  }
}
