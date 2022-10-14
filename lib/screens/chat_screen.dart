import 'dart:developer';

import 'package:chat_app/constants/global_constants.dart';
import 'package:chat_app/constants/size_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/components.dart';
import '../constants/colors.dart';
import '../firebase_helper/firebase_helper.dart';
import '../provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  late MyProvider _appProvider;

  @override
  void didChangeDependencies() {
    _appProvider = Provider.of<MyProvider>(context, listen: false);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    log(Provider.of<MyProvider>(context, listen: false)
        .peerUserData!
        .data()
        .toString());
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: AppBar(
          backgroundColor: COLORS.primary,
          leading: Container(
            // color: Colors.amber,
            // color: COLORS.primary,

            margin: EdgeInsets.only(left: SizeConfig.blockWidth * 5),
            child: GestureDetector(
              child: Icon(Icons.arrow_back_ios),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
          leadingWidth: SizeConfig.blockWidth * 10,
          titleSpacing: 0,
          title: Row(
            children: [
              Container(
                  height: 40,
                  width: 40,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                      color: COLORS.primary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(100)),
                  child: Provider.of<MyProvider>(context, listen: false)
                              .peerUserData!["photoUrl"] ==
                          ""
                      ? Container(
                          child: const Icon(
                            Icons.account_circle,
                            size: 40,
                          ),
                        )
                      : Image.network(
                          Provider.of<MyProvider>(context, listen: false)
                              .peerUserData!["photoUrl"]
                              .toString(),
                          fit: BoxFit.fill,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 5,
                                color: Colors.black,
                              ),
                            );
                          },
                        )),
              Container(
                margin: const EdgeInsets.only(left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        Provider.of<MyProvider>(context, listen: false)
                            .peerUserData!["name"],
                        style: const TextStyle(
                            fontSize: 18.5, fontWeight: FontWeight.bold)),
                    const SubTitleAppBar(),
                  ],
                ),
              )
            ],
          ),
          // actions: [
          //   IconButton(onPressed: () {
          //     notifyUserWithCall("Calling from ${Provider.of<MyProvider>(context,listen: false).auth.currentUser!.displayName}",
          //       Provider.of<MyProvider>(context,listen: false).peerUserData!["email"],
          //       Provider.of<MyProvider>(context,listen: false).peerUserData!["userId"],
          //       Provider.of<MyProvider>(context,listen: false).peerUserData!["name"],
          //       "video"
          //     );
          //     Navigator.pushNamed(context, 'video_call');
          //   }, icon: const Icon(Icons.videocam)),
          //   IconButton(onPressed: () {
          //     notifyUserWithCall("Calling from ${Provider.of<MyProvider>(context,listen: false).auth.currentUser!.displayName}",
          //         Provider.of<MyProvider>(context,listen: false).peerUserData!["email"],
          //         Provider.of<MyProvider>(context,listen: false).peerUserData!["userId"],
          //         Provider.of<MyProvider>(context,listen: false).peerUserData!["name"],
          //         "audio"
          //     );
          //     Navigator.pushNamed(context, 'audio_call');
          //   }, icon: const Icon(Icons.call)),
          // ],
        ),
        body: Column(
          children: const [
            Expanded(
              child: Messages(),
            ),
            MessagesCompose(),
          ],
        ));
  }
}
