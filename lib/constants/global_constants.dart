import 'package:chat_app/models/chat_user.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GlobalClass {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static ChatUser thisUser = ChatUser(
    email: "",
    userStatus: "",
    chatWith: "",
    name: "",
    userId: "",
  );
}

class MessageType {
  static const String text = "text";
  static const String document = "document";
  static String voiceMessage = "voice message";
  static String audio = "audio";
}

class AttachedFileType {
  static String document = "document";
  static String voiceMessage = "voice message";
  static String audio = "audio";
  static const String video = "video";
  static const String image = "image";
}

class UserStatus {
  static String online = "Online";
  static String typing = "typing...";
}

class MimeType {
  static String audio = "audio";
  static String video = "video";
  static String application = "application";
  static String image = "image";
}
