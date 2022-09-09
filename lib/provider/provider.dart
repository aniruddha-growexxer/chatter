import 'dart:developer';

import 'package:chat_app/constants/global_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/chat_user.dart';
import '../screens/chat_screen.dart';

class MyProvider with ChangeNotifier {
  QueryDocumentSnapshot<Object?>? peerUserData;
  late ChatUser currentUser;

  void usersClickListener(AsyncSnapshot<QuerySnapshot<Object?>> snapshot,
      int index, BuildContext context) {
    FirebaseFirestore.instance
        .collection('users')
        .where('userId',
            isEqualTo: snapshot.data!.docs[index]['userId'].toString())
        .get()
        .then((QuerySnapshot value) {
      peerUserData = value.docs[0];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ChatScreen(),
        ),
      );
    });
    notifyListeners();
  }

  void recentChatClickListener(AsyncSnapshot<QuerySnapshot<Object?>> snapshot,
      int index, BuildContext context) {
    if (snapshot.data!.docs[index]['messageSenderId'].toString() ==
        GlobalClass.auth.currentUser!.uid) {
      FirebaseFirestore.instance
          .collection('users')
          .where('userId',
              isEqualTo:
                  snapshot.data!.docs[index]['messageReceiverId'].toString())
          .get()
          .then((QuerySnapshot value) {
        log(value.docs.toString());
        peerUserData = value.docs[0];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ChatScreen(),
          ),
        );
      });
      notifyListeners();
    } else {
      FirebaseFirestore.instance
          .collection('users')
          .where('userId',
              isEqualTo:
                  snapshot.data!.docs[index]['messageSenderId'].toString())
          .get()
          .then((QuerySnapshot value) {
        log(value.docs.toString());

        peerUserData = value.docs[0];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ChatScreen(),
          ),
        );
      });
      notifyListeners();
    }
  }

  String getChatId(BuildContext context) {
    return GlobalClass.auth.currentUser!.uid.hashCode <=
            Provider.of<MyProvider>(context, listen: false)
                .peerUserData!["userId"]
                .hashCode
        ? "${GlobalClass.auth.currentUser!.uid} - ${Provider.of<MyProvider>(context, listen: false).peerUserData!["userId"]}"
        : "${Provider.of<MyProvider>(context, listen: false).peerUserData!["userId"]} - ${GlobalClass.auth.currentUser!.uid}";
  }

  void updateLastMessage(
      {required chatId,
      required senderId,
      required receiverId,
      required receiverUsername,
      required msgTime,
      required msgType,
      required message,
      required context}) {
    lastMessageForCurrentUser(
        receiverId: receiverId,
        senderId: senderId,
        chatId: chatId,
        context: context,
        receiverUsername: receiverUsername,
        msgTime: msgTime,
        msgType: msgType,
        message: message);
    lastMessageForPeerUser(
        receiverId: receiverId,
        senderId: senderId,
        chatId: chatId,
        context: context,
        receiverUsername: receiverUsername,
        msgTime: msgTime,
        msgType: msgType,
        message: message);
  }

  void lastMessageForCurrentUser(
      {receiverId,
      senderId,
      chatId,
      context,
      receiverUsername,
      msgTime,
      msgType,
      message}) {
    FirebaseFirestore.instance
        .collection("lastMessages")
        .doc(senderId)
        .collection(senderId)
        .where('chatId', isEqualTo: chatId)
        .get()
        .then((QuerySnapshot value) {
      if (value.size == 0) {
        FirebaseFirestore.instance
            .collection("lastMessages")
            .doc(senderId)
            .collection(senderId)
            .doc("${Timestamp.now().millisecondsSinceEpoch}")
            .set({
          'chatId': chatId,
          'messageFrom': GlobalClass.auth.currentUser!.displayName,
          'messageTo': receiverUsername,
          'messageSenderId': senderId,
          'messageReceiverId': receiverId,
          'msgTime': msgTime,
          'msgType': msgType,
          'message': message,
        });
      } else {
        FirebaseFirestore.instance
            .collection("lastMessages")
            .doc(senderId)
            .collection(senderId)
            .doc(value.docs[0].id)
            .update({
          'messageFrom': GlobalClass.auth.currentUser!.displayName,
          'messageTo': receiverUsername,
          'messageSenderId': senderId,
          'messageReceiverId': receiverId,
          'msgTime': msgTime,
          'msgType': msgType,
          'message': message,
        });
      }
    });
  }

  void lastMessageForPeerUser(
      {receiverId,
      senderId,
      chatId,
      context,
      receiverUsername,
      msgTime,
      msgType,
      message}) {
    FirebaseFirestore.instance
        .collection("lastMessages")
        .doc(receiverId)
        .collection(receiverId)
        .where('chatId', isEqualTo: chatId)
        .get()
        .then((QuerySnapshot value) {
      if (value.size == 0) {
        FirebaseFirestore.instance
            .collection("lastMessages")
            .doc(receiverId)
            .collection(receiverId)
            .doc("${Timestamp.now().millisecondsSinceEpoch}")
            .set({
          'chatId': chatId,
          'messageFrom': GlobalClass.auth.currentUser!.displayName,
          'messageTo': receiverUsername,
          'messageSenderId': senderId,
          'messageReceiverId': receiverId,
          'msgTime': msgTime,
          'msgType': msgType,
          'message': message,
        });
      } else {
        FirebaseFirestore.instance
            .collection("lastMessages")
            .doc(receiverId)
            .collection(receiverId)
            .doc(value.docs[0].id)
            .update({
          'messageFrom': GlobalClass.auth.currentUser!.displayName,
          'messageTo': receiverUsername,
          'messageSenderId': senderId,
          'messageReceiverId': receiverId,
          'msgTime': msgTime,
          'msgType': msgType,
          'message': message,
        });
      }
    });
  }
}
