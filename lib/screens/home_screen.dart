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
  // late MyProvider _appProvider;

  // @override
  // void didChangeDependencies() {
  //   _appProvider = Provider.of<MyProvider>(context, listen: false);
  //   super.didChangeDependencies();
  // }
  // @override
  // void initState() {

  // notificationsActionStreamSubscription = AwesomeNotifications().actionStream.listen((action) {
  //   if(action.buttonKeyPressed == "Answer"){
  //     getCallType().then((value) {
  //       Get.off(CallScreen(value));
  //
  //     });
  //   }else if(action.buttonKeyPressed == "Cancel"){
  //     FireBaseHelper().updateCallStatus(_appProvider,"false");
  //     cancelCall(_appProvider,"User cancel the call");
  //
  //   }
  // });
  // super.initState();
  // getDeviceToken().then((value) {
  //   updateUserToken(Provider.of<MyProvider>(context, listen: false).auth.currentUser!.email, value);
  // });
  // onTokenRefresh(Provider.of<MyProvider>(context, listen: false).auth.currentUser!.email);
  // }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    FireBaseHelper()
        .updateUserStatus(UserStatus.online, GlobalClass.auth.currentUser!.uid);
    // updatePeerDevice(Provider.of<MyProvider>(context,listen: false).auth.currentUser!.email, Provider.of<MyProvider>(context,listen: false).peerUserData!["email"]);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        FireBaseHelper().updateUserStatus(
            FieldValue.serverTimestamp(), GlobalClass.auth.currentUser!.uid);
        // updatePeerDevice(Provider.of<MyProvider>(context,listen: false).auth.currentUser!.email, "0");
        break;
      case AppLifecycleState.inactive:
        FireBaseHelper().updateUserStatus(
            FieldValue.serverTimestamp(), GlobalClass.auth.currentUser!.uid);
        // updatePeerDevice(Provider.of<MyProvider>(context,listen: false).auth.currentUser!.email, "0");
        break;
      case AppLifecycleState.detached:
        FireBaseHelper().updateUserStatus(
            FieldValue.serverTimestamp(), GlobalClass.auth.currentUser!.uid);
        // updatePeerDevice(Provider.of<MyProvider>(context,listen: false).auth.currentUser!.email, "0");
        break;
      case AppLifecycleState.resumed:
        FireBaseHelper().updateUserStatus(
            UserStatus.online, GlobalClass.auth.currentUser!.uid);
        // updatePeerDevice(Provider.of<MyProvider>(context,listen: false).auth.currentUser!.email, Provider.of<MyProvider>(context,listen: false).peerUserData!["email"]);
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // updatePeerDevice(_appProvider.auth.currentUser!.email, "0");
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
                  // Navigator.of(context).pushNamedAndRemoveUntil(
                  //     'login', (Route<dynamic> route) => false);
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
                          content: const Text("Are you sure you want to log out?"),
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
                  // color: Color(0xFF9899A5)
                  // color: AppColors.textFaded,
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
