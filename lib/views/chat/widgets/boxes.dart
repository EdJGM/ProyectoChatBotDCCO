import 'package:chatbot_dcco/constants/constants.dart';
import 'package:chatbot_dcco/models/chat_history.dart';
import 'package:chatbot_dcco/models/settings.dart';
import 'package:chatbot_dcco/models/user_model.dart';
import 'package:hive/hive.dart';

class Boxes {
  // get the chat history box
  static Box<ChatHistory> getChatHistory() =>
      Hive.box<ChatHistory>(Constants.chatHistoryBox);

  // get user box
  static Box<UserModel> getUser() => Hive.box<UserModel>(Constants.userBox);

  // get settings box
  static Box<Settings> getSettings() =>
      Hive.box<Settings>(Constants.settingsBox);
}
