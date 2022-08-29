import 'dart:developer';

import 'package:chat_app/constants/global_constants.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

import '../components/message_tile.dart';
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
                .getLastMessages(context, GlobalClass.auth.currentUser!.uid),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong try again');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
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
                  : ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (BuildContext context, int index) {
                        // snapshot.data!.docs.forEach(
                        //   (element) {
                        //     log(element.data().toString());
                        //   },
                        // );
                        return InkWell(
                          onTap: () {
                            Provider.of<MyProvider>(context, listen: false)
                                .recentChatClickListener(
                                    snapshot, index, context);
                          },
                          child: MessageTile(snapshot.data!.docs[index]),
                        );
                      },
                    );
            },
          )),
    );
  }
}
