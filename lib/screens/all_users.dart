import 'package:chat_app/constants/size_config.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

import '../Utils.dart';
import '../constants/colors.dart';
import '../constants/firestore_constants.dart';
import '../constants/global_constants.dart';
import '../firebase_helper/firebase_helper.dart';
import '../provider/provider.dart';

class AllUsers extends StatefulWidget {
  const AllUsers({Key? key}) : super(key: key);

  @override
  State<AllUsers> createState() => _AllUsersState();
}

class _AllUsersState extends State<AllUsers> {
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(title: Text('All Users')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FireBaseHelper()
                  .getFirestoreData(FirestoreConstants.pathUserCollection, 10),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  if ((snapshot.data?.docs.length ?? 0) > 0) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) => GestureDetector(
                        onTap: () {
                          Provider.of<MyProvider>(context, listen: false)
                              .usersClickListener(snapshot, index, context);
                        },
                        child: buildItem(context, snapshot.data?.docs[index]),
                      ),
                      controller: scrollController,
                      // separatorBuilder: (BuildContext context, int index) =>
                      //     const Divider(),
                    );
                  } else {
                    return const Center(
                      child: Text('No user found...'),
                    );
                  }
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildItem(BuildContext context, DocumentSnapshot? documentSnapshot) {
    // final firebaseAuth = FirebaseAuth.instance;
    if (documentSnapshot != null) {
      // var jsonEncoded = json.encode(documentSnapshot.data());
      // log('jsonEncoded: ${}');
      ChatUser userChat = ChatUser.fromDocument(documentSnapshot);
      if (userChat.userId == GlobalClass.auth.currentUser!.uid) {
        return const SizedBox.shrink();
      } else {
        return Container(
          padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockWidth * 3, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  height: 60,
                  width: 60,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                      color: COLORS.primary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(100)),
                  child: userChat.photoUrl == "" || userChat.photoUrl == null
                      ? Image.asset("images/avatar.png")
                      : Image.network(
                          userChat.photoUrl.toString(),
                          fit: BoxFit.fill,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 5,
                                color: Colors.black,
                              ),
                            );
                          },
                        )),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    userChat.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    // textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Icon(
                Icons.circle,
                color: userChat.userStatus == UserStatus.online
                    ? Colors.green
                    : Colors.grey.shade500,
              )
            ],
          ),
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }
}
