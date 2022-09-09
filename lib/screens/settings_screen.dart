import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:chat_app/constants/global_constants.dart';
import 'package:chat_app/firebase_helper/firebase_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../components/display_image.dart';
import '../models/chat_user.dart';

// This class handles the Page to dispaly the user's info on the "Edit Profile" Screen
class SettingsScreen extends StatefulWidget {
  final ChatUser user;

  SettingsScreen({Key? key, required this.user}) : super(key: key);
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool loading = false;
  ImagePicker _picker = ImagePicker();
  CroppedFile? _croppedFile;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            // toolbarHeight: 10,
            centerTitle: true,
            title: const Text(
              'My Profile',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: Color.fromRGBO(64, 105, 225, 1),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              // navigateSecondPage(EditImagePage());
            },
            child: loading
                ? Container(
                    height: 150,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  )
                : DisplayImage(
                    // imagePath: widget.user.photoUrl.toString(),
                    // imagePath: Stream,
                    onPressed: () {
                      _picker
                          .pickImage(source: ImageSource.gallery)
                          .then((pickedFile) async {
                        setState(() {
                          loading = true;
                        });
                        if (pickedFile != null) {
                          final croppedFile = await ImageCropper().cropImage(
                            sourcePath: pickedFile.path,
                            compressFormat: ImageCompressFormat.jpg,
                            compressQuality: 100,
                            uiSettings: [
                              AndroidUiSettings(
                                  toolbarTitle: 'Cropper',
                                  toolbarColor: Colors.deepOrange,
                                  toolbarWidgetColor: Colors.white,
                                  initAspectRatio:
                                      CropAspectRatioPreset.original,
                                  lockAspectRatio: false),
                              IOSUiSettings(
                                title: 'Cropper',
                              ),
                            ],
                          );
                          if (croppedFile != null) {
                            setState(() {
                              _croppedFile = croppedFile;
                            });
                          }
                        }
                        try {
                          log(
                            pickedFile!.path.toString(),
                          );
                          File file = File(_croppedFile!.path.toString());
                          UploadTask uploadTask = FireBaseHelper()
                              .uploadProfilePicture(
                                  GlobalClass.auth.currentUser!.uid, file);
                          uploadTask.whenComplete(() {
                            uploadTask.then((fileRef) async {
                              String url = await fileRef.ref.getDownloadURL();
                              log("url is $url");
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(GlobalClass.auth.currentUser!.uid)
                                  .update({"photoUrl": url}).whenComplete(() {
                                setState(() {
                                  loading = false;
                                });
                              });
                            });
                          });
                        } on FirebaseException catch (e) {
                          log(e.message.toString());
                          setState(() {
                            loading = false;
                          });
                        }
                      }).onError((error, stackTrace) {
                        log(error.toString());
                        setState(() {
                          loading = false;
                        });
                      });
                    },
                  ),
          ),
          buildUserInfoDisplay(
            getValue: widget.user.name,
            title: 'Name',
          ),
          buildUserInfoDisplay(getValue: widget.user.email, title: 'Email'),
          // Expanded(
          //   child: buildAbout(user),
          //   flex: 4,
          // )
        ],
      ),
    );
  }

  // Widget builds the display item with the proper formatting to display the user's info
  Widget buildUserInfoDisplay(
          {String? getValue, required String title, Widget? editPage}) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(
                height: 1,
              ),
              Container(
                  width: 350,
                  height: 40,
                  decoration: const BoxDecoration(
                      border: const Border(
                          bottom: BorderSide(
                    color: Colors.grey,
                    width: 1,
                  ))),
                  child: Row(children: [
                    Expanded(
                        child: TextButton(
                            onPressed: () {
                              // navigateSecondPage(editPage);
                            },
                            child: Text(
                              getValue.toString(),
                              style: const TextStyle(fontSize: 16, height: 1.4),
                            ))),
                    const Icon(
                      Icons.keyboard_arrow_right,
                      color: Colors.grey,
                      size: 40.0,
                    )
                  ]))
            ],
          ));

  // Widget builds the About Me Section
  // Widget buildAbout(User user) => Padding(
  //     padding: EdgeInsets.only(bottom: 10),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Tell Us About Yourself',
  //           style: TextStyle(
  //             fontSize: 15,
  //             fontWeight: FontWeight.w500,
  //             color: Colors.grey,
  //           ),
  //         ),
  //         const SizedBox(height: 1),
  //         Container(
  //             width: 350,
  //             height: 200,
  //             decoration: BoxDecoration(
  //                 border: Border(
  //                     bottom: BorderSide(
  //               color: Colors.grey,
  //               width: 1,
  //             ))),
  //             child: Row(children: [
  //               Expanded(
  //                   child: TextButton(
  //                       onPressed: () {
  //                         navigateSecondPage(EditDescriptionFormPage());
  //                       },
  //                       child: Padding(
  //                           padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
  //                           child: Align(
  //                               alignment: Alignment.topLeft,
  //                               child: Text(
  //                                 user.aboutMeDescription,
  //                                 style: TextStyle(
  //                                   fontSize: 16,
  //                                   height: 1.4,
  //                                 ),
  //                               ))))),
  //               Icon(
  //                 Icons.keyboard_arrow_right,
  //                 color: Colors.grey,
  //                 size: 40.0,
  //               )
  //             ]))
  //       ],
  //     ));

  // Refrshes the Page after updating user info.
  FutureOr onGoBack(dynamic value) {
    setState(() {});
  }

  // Handles navigation and prompts refresh.
  void navigateSecondPage(Widget editForm) {
    Route route = MaterialPageRoute(builder: (context) => editForm);
    Navigator.push(context, route).then(onGoBack);
  }
}
