import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants/firestore_constants.dart';

class StoryModel {
  final DateTime timestamp;
  final String storyId;
  final String userId;
  final String userName;
  final String? storyImageUrl;
  final String? storyText;
  final String? storyBackgroundColor;

  StoryModel({
    required this.userName,
    required this.storyId,
    required this.storyText,
    required this.storyBackgroundColor,
    required this.storyImageUrl,
    required this.timestamp,
    required this.userId,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) => StoryModel(
        storyId: json["storyId"],
        userName: json["userName"],
        storyText: json["storyText"],
        storyBackgroundColor: json["storyBackgroundColor"],
        storyImageUrl: json["storyImageUrl"],
        timestamp: json["timestamp"],
        userId: json["userId"],
      );

  Map<String, dynamic> toJson() => {
        "userName": userName,
        "storyText": storyText,
        "storyBackgroundColor": storyBackgroundColor,
        "storyImageUrl": storyImageUrl,
        "timestamp": timestamp,
        "userId": userId,
      };

  factory StoryModel.fromDocument(DocumentSnapshot snapshot) {
    String userName = "";
    String storyText = "";
    String storyId = "";
    String storyBackgroundColor = "";
    String storyImageUrl = "";
    // DateTime timestamp;
    String userId = "";
    // log(snapshot.data().toString());
    Timestamp timestamp = snapshot.get(FirestoreConstants.timestamp);
    // Timestamp.fromDate(date)
    try {
      userName = snapshot.get(FirestoreConstants.userName);
      storyText = snapshot.get(FirestoreConstants.storyText).toString();
      storyBackgroundColor =
          snapshot.get(FirestoreConstants.storyBackgroundColor);
      storyImageUrl = snapshot.get(FirestoreConstants.storyImageUrl) ?? "";
      // timestamp = snapshot.get(FirestoreConstants.timestamp).toDate();
      userId = snapshot.get(FirestoreConstants.userId);
      storyId = snapshot.get(FirestoreConstants.storyId);
    } catch (e) {
      log(e.toString(), error: e);
    }
    // log(userId);
    return StoryModel(
        userId: userId,
        storyText: storyText,
        storyBackgroundColor: storyBackgroundColor,
        storyImageUrl: storyImageUrl,
        timestamp: timestamp.toDate(),
        userName: userName,
        storyId: storyId);
  }
}
