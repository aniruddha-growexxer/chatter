import 'dart:async';

// import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:chat_app/constants/global_constants.dart';
import 'package:chat_app/provider/shared_prefs.dart';
import 'package:chat_app/screens/home_screen.dart';
import 'package:chat_app/screens/login.dart';
import 'package:flutter/material.dart';

import '../Utils.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // late MyProvider _appProvider;

  // @override
  // void didChangeDependencies() {
  //   _appProvider = Provider.of<MyProvider>(context, listen: false);
  //   super.didChangeDependencies();
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Timer(const Duration(seconds: 3), () {
      if (GlobalClass.auth.currentUser != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: ((context) => HomeScreen())),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: ((context) => Login())),
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/chat_icon.png'),
            const Text(
              'Chatter',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 40.0,
                  color: Colors.black87),
            ),
            // const CircularProgressIndicator()
          ],
        ),
      )),
    );
  }
}
