import 'dart:developer';

import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:chat_app/constants/colors.dart';
import 'package:chat_app/constants/size_config.dart';
import 'package:chat_app/firebase_helper/firebase_helper.dart';
import 'package:chat_app/models/story_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'dart:math' as math;

import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../constants/global_constants.dart';
import '../provider/provider.dart';

class AddTextStory extends StatefulWidget {
  const AddTextStory({Key? key}) : super(key: key);

  @override
  State<AddTextStory> createState() => _AddTextStoryState();
}

class _AddTextStoryState extends State<AddTextStory> {
  TextEditingController _textEditingController = TextEditingController();

  double grayscale = 0.0;
  Color color = Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
      .withOpacity(0.1)
      .withOpacity(1);
  bool isDark = false;
  bool showSendButton = false;

  @override
  void initState() {
    super.initState();

    grayscale =
        (0.299 * color.red) + (0.587 * color.red) + (0.114 * color.blue);
    setState(() {
      isDark = grayscale < 128;
    });
    _textEditingController.addListener(() {
      log(_textEditingController.text);
      // setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    isDark = grayscale < 128;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black.withOpacity(0.1),
        actions: [
          GestureDetector(
            child: const Icon(Icons.close),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(
            width: 20,
          ),
        ],
      ),
      backgroundColor: color,
      body: Center(
        child: Container(
          width: SizeConfig.screenWidth * 0.8,
          height: SizeConfig.screenHeight * 0.8,
          // padding: EdgeInsets.symmetric(),
          child: AutoSizeTextField(
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Type your status here",
                hintStyle: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                fillColor: Colors.red),
            onChanged: (text) {
              setState(() {
                showSendButton = text.isNotEmpty;
              });
            },
            maxLines: null,
            textAlign: TextAlign.center,
            controller: _textEditingController,
            style: const TextStyle(fontSize: 30),
            minFontSize: 12,
            maxFontSize: 40,
            // maxLines: 10,
          ),
        ),
      ),
      floatingActionButton: showSendButton
          ? FloatingActionButton(
              backgroundColor: COLORS.primary,
              child: const Icon(Icons.send),
              onPressed: () {
                // Navigator.pop(context);
                FireBaseHelper().addNewStory(
                  storyModel: StoryModel(
                    userName:
                        GlobalClass.auth.currentUser!.displayName.toString(),
                    storyId: const Uuid().v1(),
                    storyText: _textEditingController.text,
                    storyBackgroundColor: color.value.toString(),
                    storyImageUrl: null,
                    timestamp: DateTime.now(),
                    userId: GlobalClass.auth.currentUser!.uid,
                  ),
                );
                Navigator.pop(context);
              },
            )
          : null,
    );
  }
}
