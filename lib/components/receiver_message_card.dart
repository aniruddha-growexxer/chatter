// ignore_for_file: avoid_unnecessary_containers

import 'dart:developer';

import 'package:chat_app/constants/global_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class ReceiverMessageCard extends StatefulWidget {
  const ReceiverMessageCard(this.fileName, this.msgType, this.msg, this.time,
      {Key? key})
      : super(key: key);
  final String msg;
  final String time;
  final String msgType;
  final String fileName;

  @override
  State<ReceiverMessageCard> createState() => _ReceiverMessageCardState();
}

class _ReceiverMessageCardState extends State<ReceiverMessageCard> {
  _messageBuilder() {
    switch (widget.msgType) {
      case MessageType.document:
        return Container(
          child: Padding(
            padding:
                const EdgeInsets.only(left: 10, right: 20, top: 5, bottom: 5),
            child: SelectableText(
              widget.fileName,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        );
      case AttachedFileType.image:
        return Container(
          height: 200,
          width: 200,

          // child: Padding(
          padding: const EdgeInsets.all(10),
          child: Image.network(
            widget.msg,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                child: const Text(
                  "Image not uploaded correctly",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              );
            },
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  color: Colors.amber,
                  strokeWidth: 5,
                ),
              );
            },
          ),
        );
      case MessageType.text:
        return Padding(
          padding:
              const EdgeInsets.only(left: 10, right: 20, top: 5, bottom: 5),
          child: SelectableText(
            widget.msg,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        );
      default:
        return Container(
          child: const Text("Document upload error"),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Card(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        // color: Colors.purple[200],
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _messageBuilder(),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
              child: Text(widget.time,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade300)),
            )
          ],
        ),
      ),
    );
  }
}
