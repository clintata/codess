import 'package:app/announcement.dart';
import 'package:app/chatroom/add_chart.dart';
import 'package:app/components/setting_page.dart';
import 'package:app/components/task/task_list_pagee.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HOME"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Settings()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TaskItem(
            title: "Announcement",
            time: "11:44 PM",
            date: "Fri, Oct 20, 2023",
            backgroundColor: Colors.white,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AnnouncementPage()),
              );
            },
          ),
          TaskItem(
            title: "Task",
            time: "05:45 PM",
            date: "Sun, Sep 24, 2023",
            backgroundColor: Colors.white,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddTaskPage()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the "New Chat" page or open a chat dialog
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddChat()), // Replace with your chat page
          );
        },
        child: const Icon(Icons.chat),
      ),
    );
  }
}

class TaskItem extends StatefulWidget {
  final String title;
  final String time;
  final String date;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final VoidCallback onTap;

  const TaskItem({
    required this.title,
    required this.time,
    required this.date,
    this.backgroundColor = Colors.white,
    this.iconColor = Colors.black,
    this.textColor = Colors.black,
    required this.onTap,
  });

  @override
  _TaskItemState createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  isChecked = !isChecked;
                });
              },
              child: Icon(
                isChecked ? Icons.check_circle : Icons.circle,
                color: isChecked
                    ? widget.iconColor
                    : widget.iconColor.withOpacity(0.5),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      color: widget.textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  Text(
                    "${widget.time}, ${widget.date}",
                    style: TextStyle(color: widget.textColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
