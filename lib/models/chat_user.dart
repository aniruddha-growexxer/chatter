import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../constants/firestore_constants.dart';

class ChatUser {
  ChatUser({
    this.photoUrl,
    required this.email,
    required this.userStatus,
    required this.chatWith,
    required this.name,
    required this.userId,
  });

  final String email;
  final String userStatus;
  final String chatWith;
  final String name;
  final String userId;
  final String? photoUrl;

  factory ChatUser.fromJson(Map<String, dynamic> json) => ChatUser(
        email: json["email"],
        userStatus: json["userStatus"],
        chatWith: json["chatWith"],
        name: json["name"],
        userId: json["userId"],
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "userStatus": userStatus,
        "chatWith": chatWith,
        "name": name,
        "userId": userId,
      };

  factory ChatUser.fromDocument(DocumentSnapshot snapshot) {
    String email = "";
    String userStatus = "";
    String chatWith = "";
    String name = "";

    try {
      email = snapshot.get(FirestoreConstants.email);
      userStatus = snapshot.get(FirestoreConstants.userStatus).toString();
      chatWith = snapshot.get(FirestoreConstants.chatWith);
      name = snapshot.get(FirestoreConstants.name);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return ChatUser(
        userId: snapshot.id,
        userStatus: userStatus,
        chatWith: chatWith,
        name: name,
        email: email);
  }
}
