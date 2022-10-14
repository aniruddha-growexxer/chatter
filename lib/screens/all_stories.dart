// ignore_for_file: prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:chat_app/constants/colors.dart';
import 'package:chat_app/constants/firestore_constants.dart';
import 'package:chat_app/constants/global_constants.dart';
import 'package:chat_app/constants/size_config.dart';
import 'package:chat_app/firebase_helper/firebase_helper.dart';
import 'package:chat_app/screens/add_text_story.dart';
import 'package:chat_app/screens/story_screen.dart';
import 'package:chat_app/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/widgets/story_view.dart';
import 'package:uuid/uuid.dart';

import '../models/story_model.dart';

class AllStories extends StatefulWidget {
  const AllStories({Key? key}) : super(key: key);

  @override
  State<AllStories> createState() => _AllStoriesState();
}

class _AllStoriesState extends State<AllStories> {
  bool loaded = false;
  StreamController storyStreamController = StreamController.broadcast();
  ImagePicker _picker = ImagePicker();
  CroppedFile? _croppedFile;

  startListening() {
    List<List<StoryModel>> storyModelList = [];
    Stream<QuerySnapshot> userSnapshots = FireBaseHelper()
        .getFirestoreData(FirestoreConstants.pathUserCollection, 10);
    userSnapshots.listen((user) async {}).onData((user) {
      storyModelList = [];
      storyStreamController.stream.drain();
      log("user is ${user.docs.length}");
      for (var element in user.docs) {
        Stream<QuerySnapshot> singleUserStorySnapshot =
            FireBaseHelper().getAllStories(context, element.id);
        log(element.get("userId").toString());
        singleUserStorySnapshot.listen((e) {}).onData((e) {
          List<StoryModel> storyModelsOfSingleUser = [];
          if (e.docs.isNotEmpty) {
            for (var singleStory in e.docs) {
              StoryModel storyModel = StoryModel.fromDocument(singleStory);
              storyModelsOfSingleUser.add(storyModel);
            }
            storyModelList.add(storyModelsOfSingleUser);
          }
          storyStreamController.add(storyModelList);
        });
      }
    });
  }

  createStoryItems(List<StoryModel> stories) {
    List<StoryItem> storyItems = [];
    for (StoryModel singleStoryModel in stories) {
      StoryController storyController = StoryController();
      singleStoryModel.storyText != ""
          ? storyItems.add(StoryItem.text(
              title: singleStoryModel.storyText.toString(),
              backgroundColor: Color(
                  int.parse(singleStoryModel.storyBackgroundColor.toString()))))
          : storyItems.add(
              StoryItem.pageImage(
                  url: singleStoryModel.storyImageUrl.toString(),
                  controller: storyController),
            );
    }
    return storyItems;
  }

  buildStoryWidget(List<StoryModel> stories) {
    String username = stories[0].userId == GlobalClass.auth.currentUser!.uid
        ? "My Status"
        : stories[0].userName;
    bool isText = stories.first.storyText != "";
    String imageUrl = isText ? "" : stories.first.storyImageUrl.toString();
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: ((context) {
              return StoryScreen(
                storyItems: createStoryItems(stories),
              );
            }),
          ),
        );
      },
      child: Container(
        // color: Colors.red.shade100,
        padding: const EdgeInsets.only(left: 20),
        alignment: Alignment.centerLeft,
        height: SizeConfig.blockHeight * 9,
        width: SizeConfig.screenWidth,

        child: Row(
          children: [
            imageUrl == ""
                ? Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: convertColorFromString(
                            stories.first.storyBackgroundColor.toString())),
                    margin: const EdgeInsets.only(right: 15),
                    padding: const EdgeInsets.all(5),
                    alignment: Alignment.center,
                    height: 70,
                    width: 70,
                    child: Text(
                      stories.first.storyText.toString(),
                      style:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                : Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.hardEdge,
                    margin: const EdgeInsets.only(right: 15),
                    // padding: EdgeInsets.all(2),
                    // alignment: Alignment.center,
                    height: 70,
                    width: 70,
                    child: Image.network(imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) =>
                            loadingBuilder(context, child, loadingProgress)),
                  ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  stories.first.timestamp.day == DateTime.now().day
                      ? "Today at ${DateFormat('h:mm a').format(stories.first.timestamp)}"
                      : DateFormat('EEE, M/d/y, h:mm a')
                          .format(stories.first.timestamp),
                  style: TextStyle(
                      fontWeight: FontWeight.w500, color: Colors.grey.shade500),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    startListening();
  }

  @override
  void dispose() {
    super.dispose();
    storyStreamController.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(      
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StreamBuilder(
                stream: storyStreamController.stream,
                initialData: [],
                builder: ((context, AsyncSnapshot<dynamic> snapshot) {
                  log("Stream builder snapshot is ${snapshot.data}");
                  if (snapshot.data is List<List<StoryModel>>) {
                    List<List<StoryModel>> allStoryModels = snapshot.data;
                    List<List<StoryModel>> revisedStoryModels = [];

                    List<StoryModel> redundantStories =
                        allStoryModels.expand((element) => element).toList();
                    List<String> storyIds = [];
                    List<StoryModel> uniqStories = [];
                    redundantStories.forEach((element) {
                      if (!storyIds.contains(element.storyId)) {
                        storyIds.add(element.storyId);
                        uniqStories.add(element);
                      }
                    });
                    uniqStories.sort(
                        ((a, b) => a.timestamp.isBefore(b.timestamp) ? 1 : -1));
                    //flattened
                    Map flattenedMap = groupBy(uniqStories, (StoryModel obj) {
                      return obj.userId.toString();
                    });
                    log("flattened map is $flattenedMap");

                    flattenedMap.forEach((key, value) {
                      revisedStoryModels.add(value);
                    });
                    return ListView.builder(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: revisedStoryModels.length,
                        itemBuilder: ((context, index) {
                          if (revisedStoryModels[index].isNotEmpty) {
                            return buildStoryWidget(revisedStoryModels[index]);
                          }
                          return Container();
                        }));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    buildShowSnackBar(context, "Something went wrong");
                    return Container(
                      alignment: Alignment.center,
                      child: const Text("Please come again later"),
                    );
                  }
                  return Container();
                }))
          ],
        ),
      ),
      bottomSheet: Container(
        height: SizeConfig.blockHeight * 20,
        padding: const EdgeInsets.only(right: 20, bottom: 20),
        alignment: Alignment.centerRight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            MaterialButton(
              padding: const EdgeInsets.all(15),
              shape: const CircleBorder(side: BorderSide.none),
              color: COLORS.primary,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddTextStory()));
              },
              child: const Icon(
                Icons.edit,
                color: Colors.white,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            MaterialButton(
              padding: const EdgeInsets.all(15),
              shape: const CircleBorder(side: BorderSide.none),
              color: COLORS.primary,
              onPressed: () {
                _picker
                    .pickImage(source: ImageSource.gallery)
                    .then((pickedFile) async {
                  if (pickedFile != null) {
                    final croppedFile = await ImageCropper().cropImage(
                      sourcePath: pickedFile.path,
                      compressFormat: ImageCompressFormat.jpg,
                      compressQuality: 100,
                      uiSettings: [
                        AndroidUiSettings(
                            toolbarTitle: 'Cropper',
                            toolbarColor: COLORS.primary,
                            toolbarWidgetColor: Colors.white,
                            initAspectRatio: CropAspectRatioPreset.original,
                            lockAspectRatio: false),
                        IOSUiSettings(
                          title: 'Cropper',
                          aspectRatioLockEnabled: true,
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
                    UploadTask uploadTask = FireBaseHelper().uploadStoryImage(
                        GlobalClass.auth.currentUser!.uid, file);
                    uploadTask.whenComplete(() {
                      uploadTask.then((fileRef) async {
                        String url = await fileRef.ref.getDownloadURL();
                        log("url is $url");
                        FireBaseHelper().addNewStory(
                          storyModel: StoryModel(
                            userName: GlobalClass.auth.currentUser!.displayName
                                .toString(),
                            storyId: const Uuid().v1(),
                            storyText: "",
                            storyBackgroundColor: "",
                            storyImageUrl: url,
                            timestamp: DateTime.now(),
                            userId: GlobalClass.auth.currentUser!.uid,
                          ),
                        );
                      });
                    });
                  } on FirebaseException catch (e) {
                    log(e.message.toString());
                    buildShowSnackBar(context, "Something went wrong");
                  }
                }).onError((error, stackTrace) {
                  log(error.toString());
                  buildShowSnackBar(context, "Something went wrong");
                });
              },
              child: const Icon(
                Icons.photo_camera,
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}
