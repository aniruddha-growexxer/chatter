import 'dart:convert';
import 'dart:developer';

import 'package:chat_app/constants/colors.dart';
import 'package:chat_app/constants/global_constants.dart';
import 'package:chat_app/constants/size_config.dart';
import 'package:chat_app/provider/shared_prefs.dart';
import 'package:chat_app/screens/all_stories.dart';
import 'package:chat_app/screens/all_users.dart';
import 'package:chat_app/screens/login.dart';
import 'package:chat_app/screens/recent_chats.dart';
import 'package:chat_app/screens/settings_screen.dart';
import 'package:chat_app/screens/story_screen.dart';
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

class HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    FireBaseHelper()
        .updateUserStatus(UserStatus.online, GlobalClass.auth.currentUser!.uid);
    FireBaseHelper().setGlobalCurrentUser(GlobalClass.auth.currentUser!.uid);
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      // print("${tabController.index}");
      setState(() {
        _currentTabIndex = tabController.index;
      });
    });
  }

  bool showOptions = false;

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
    FireBaseHelper().updateUserStatus(
        FieldValue.serverTimestamp(), GlobalClass.auth.currentUser!.uid);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Widget tab({required String title}) {
    return Container(
      width: double.infinity,
      color: COLORS.primary,
      padding: const EdgeInsets.symmetric(
        // horizontal: 2.0,
        vertical: 20.0,
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  late TabController tabController;
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    tabController.animateTo(_currentTabIndex);
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          setState(() {
            showOptions = false;
          });
        },
        child: DefaultTabController(
          length: 2,
          initialIndex: _currentTabIndex,
          child: Stack(
            children: [
              Scaffold(
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.blockWidth * 2,
                        vertical: 5,
                      ),
                      color: COLORS.primary,
                      child: Row(
                        children: [
                          const Text(
                            "Chatter",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            color: Colors.white,
                            onPressed: () {
                              setState(() {
                                showOptions = true;
                              });
                            },
                            // icon: const Icon(Icons.logout_sharp),
                            icon: const Icon(Icons.more_vert),
                          ),
                        ],
                      ),
                    ),
                    TabBar(
                      labelPadding: EdgeInsets.zero,
                      indicatorColor: COLORS.deepBlue,                      
                      indicatorSize: TabBarIndicatorSize.tab,
                      // unselectedLabelColor: COLORS.primary,
                      indicatorWeight: 2,
                      onTap: (index) {
                        setState(() {
                          _currentTabIndex = index;
                        });
                      },
                      controller: tabController,
                      tabs: [
                        tab(title: 'CHATS'),
                        tab(title: 'STATUS'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: tabController,
                        children: const [
                          RecentChats(),
                          AllStories(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (showOptions)
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    // height: 200,
                    width: SizeConfig.blockWidth * 35,
                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 2,
                          offset: Offset(1, 1),
                          spreadRadius: 0.1,
                        )
                      ],
                      color: Colors.white,
                    ),
                    margin: EdgeInsets.only(
                      top: SizeConfig.blockHeight * 2,
                      right: SizeConfig.blockWidth * 5,
                    ),
                    // ignore: prefer_const_literals_to_create_immutables
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              showOptions = false;
                            });
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SettingsScreen(user: GlobalClass.thisUser),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: SizeConfig.blockHeight * 1.5),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: const Icon(Icons.settings),
                                ),
                                const Text(
                                  "Settings",
                                  style: TextStyle(
                                    color: Colors.black,
                                    decoration: TextDecoration.none,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              showOptions = false;
                            });
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
                                                GlobalClass
                                                    .auth.currentUser!.uid);
                                            FireBaseHelper().signOut();
                                            clearData();
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const Login(),
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
                                    content: const Text(
                                        "Are you sure you want to log out?"),
                                  );
                                });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: SizeConfig.blockHeight * 1.5),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: const Icon(Icons.logout),
                                ),
                                const Text(
                                  "Logout",
                                  style: TextStyle(
                                    decoration: TextDecoration.none,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(),
            ],
          ),
        ),
      ),
    );
  }
}
