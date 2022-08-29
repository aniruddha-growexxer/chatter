import 'dart:convert';
import 'dart:developer';

import 'package:chat_app/constants/global_constants.dart';
import 'package:chat_app/provider/shared_prefs.dart';
import 'package:chat_app/screens/all_users.dart';
import 'package:chat_app/screens/login.dart';
import 'package:chat_app/screens/recent_chats.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../constants/firestore_constants.dart';
import '../firebase_helper/firebase_helper.dart';
import '../models/chat_user.dart';
import '../utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    FireBaseHelper()
        .updateUserStatus(UserStatus.online, GlobalClass.auth.currentUser!.uid);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        FireBaseHelper().updateUserStatus(
            FieldValue.serverTimestamp(), GlobalClass.auth.currentUser!.uid);
        break;
      case AppLifecycleState.inactive:
        FireBaseHelper().updateUserStatus(
            FieldValue.serverTimestamp(), GlobalClass.auth.currentUser!.uid);
        break;
      case AppLifecycleState.detached:
        FireBaseHelper().updateUserStatus(
            FieldValue.serverTimestamp(), GlobalClass.auth.currentUser!.uid);
        break;
      case AppLifecycleState.resumed:
        FireBaseHelper().updateUserStatus(
            UserStatus.online, GlobalClass.auth.currentUser!.uid);
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Chatter"),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Logout"),
                          titleTextStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 20),
                          actionsOverflowButtonSpacing: 20,
                          actions: [
                            ElevatedButton(
                                onPressed: () {
                                  FireBaseHelper().updateUserStatus(
                                      FieldValue.serverTimestamp(),
                                      GlobalClass.auth.currentUser!.uid);
                                  FireBaseHelper().signOut();
                                  clearData();
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const Login(),
                                    ),
                                    (Route<dynamic> route) => false,
                                  );
                                },
                                child: const Text("Yes")),
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("No")),
                          ],
                          content:
                              const Text("Are you sure you want to log out?"),
                        );
                      });
                },
                icon: const Icon(Icons.logout_sharp))
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            // Users(),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 2.0,
                vertical: 5.0,
              ),
              child: Text(
                'Recent Chats',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            RecentChats(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.message),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: ((context) {
              return const AllUsers();
            })));
          },
        ),
      ),
    );
  }
}
