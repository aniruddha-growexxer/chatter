import 'dart:developer';

import 'package:chat_app/constants/global_constants.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/message_tile.dart';
import '../constants/colors.dart';
import '../constants/firestore_constants.dart';
import '../firebase_helper/firebase_helper.dart';
import '../provider/provider.dart';

class RecentChats extends StatefulWidget {
  const RecentChats({Key? key}) : super(key: key);

  @override
  State<RecentChats> createState() => _RecentChatsState();
}

class _RecentChatsState extends State<RecentChats> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(5.0), topRight: Radius.circular(5.0)),
        child: StreamBuilder(
          stream: FireBaseHelper()
              .getFirestoreData(FirestoreConstants.pathUserCollection, 10),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            List<ChatUser> users = [];
            if (snapshot.hasError) {
              return const Text('Something went wrong try again');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasData) {
              for (var i in snapshot.data!.docs) {
                users.add(ChatUser.fromDocument(i));
              }
            }
            return snapshot.data!.size == 0
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Center(
                          child:
                              Text('No messages start to chat with someone')),
                    ],
                  )
                : StreamBuilder(
                    stream: FireBaseHelper().getLastMessages(
                        context, GlobalClass.auth.currentUser!.uid),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasData) {
                        return ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          itemCount: snapshot.data!.docs.length,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (BuildContext context, int index) {
                            String tempUrl = "";
                            for (var element in users) {
                              if (element.userId ==
                                      snapshot.data!.docs[index]
                                          ["messageReceiverId"] &&
                                  element.name ==
                                      snapshot.data!.docs[index]["messageTo"] &&
                                  element.userId !=
                                      GlobalClass.auth.currentUser!.uid) {
                                log("${element.userId} ${element.name} ${snapshot.data!.docs[index]["messageReceiverId"]} ${snapshot.data!.docs[index]["messageTo"]}");
                                tempUrl = element.photoUrl.toString();
                              } else if (element.userId ==
                                      snapshot.data!.docs[index]
                                          ["messageSenderId"] &&
                                  element.name ==
                                      snapshot.data!.docs[index]
                                          ["messageFrom"] &&
                                  element.userId !=
                                      GlobalClass.auth.currentUser!.uid) {
                                // log("${element.userId} ${element.name} ${snapshot.data!.docs[index]["messageReceiverId"]} ${snapshot.data!.docs[index]["messageTo"]}");
                                tempUrl = element.photoUrl.toString();
                              }
                            }
                            log("tempUrl is $tempUrl");
                            return Container(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                children: [
                                  Container(
                                      height: 60,
                                      width: 60,
                                      clipBehavior: Clip.hardEdge,
                                      decoration: BoxDecoration(
                                          color:
                                              COLORS.primary.withOpacity(0.3),
                                          borderRadius:
                                              BorderRadius.circular(100)),
                                      child: tempUrl == "" || tempUrl == null
                                          ? Image.asset("images/avatar.png")
                                          : Image.network(
                                              tempUrl.toString(),
                                              fit: BoxFit.fill,
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    value: loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes!
                                                        : null,
                                                    strokeWidth: 5,
                                                    color: Colors.black,
                                                  ),
                                                );
                                              },
                                            )),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        Provider.of<MyProvider>(context,
                                                listen: false)
                                            .recentChatClickListener(
                                                snapshot, index, context);
                                      },
                                      child: MessageTile(
                                          snapshot.data!.docs[index]),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                      return Container();
                    },
                  );
          },
        ),
      ),
    );
  }
}
