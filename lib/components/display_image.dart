import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chat_app/constants/global_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DisplayImage extends StatelessWidget {
  // final String imagePath;
  final VoidCallback onPressed;

  // Constructor
  const DisplayImage({
    Key? key,
    // required this.imagePath,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = const Color.fromARGB(255, 168, 190, 255);

    return Center(
      child: Stack(
        children: [
          buildImage(color),
          Positioned(
            child: buildEditIcon(color),
            right: 4,
            top: 10,
          )
        ],
      ),
    );
  }

  // Builds Profile Image
  Widget buildImage(Color color) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(GlobalClass.auth.currentUser!.uid.toString())
          .snapshots(),
      builder: (context,
          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasData) {
          var data = snapshot.requireData.data();
          log(data.toString());
          // print(data.toString());
          return CircleAvatar(
            radius: 75,
            backgroundColor: color,
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              backgroundImage: data!["photoUrl"] == "" ||
                      data["photoUrl"] == null
                  ? AssetImage("images/avatar.png") as ImageProvider
                  : Image.network(
                      data["photoUrl"],
                      // "https://thumbs.dreamstime.com/z/portrait-lion-black-detail-face-lion-hight-quality-portrait-lion-portrait-animal-portrait-lion-black-detail-145612151.jpg",
                      loadingBuilder: (context, child, loadingProgress) {
                        log("========");
                        // log(loadingProgress!.cumulativeBytesLoaded.toString());
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 5,
                            color: Colors.black,
                          ),
                        );
                      },
                    ).image,
              radius: 70,
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  // Builds Edit Icon on Profile Picture
  Widget buildEditIcon(Color color) => GestureDetector(
        onTap: onPressed,
        child: buildCircle(
          // all: 8,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                border: Border.all(
                    color: const Color.fromARGB(255, 168, 190, 255), width: 3),
                borderRadius: BorderRadius.circular(100)),
            child: Icon(
              Icons.edit,
              color: color,
              size: 20,
            ),
          ),
        ),
      );

  // Builds/Makes Circle for Edit Icon on Profile Picture
  Widget buildCircle({
    required Widget child,
    // required double all,
  }) =>
      ClipOval(
          child: Container(
        color: Colors.white,
        child: child,
      ));
}
