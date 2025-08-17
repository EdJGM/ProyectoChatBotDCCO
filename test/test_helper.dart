import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:chatbot_dcco/models/chat_history.dart';
import 'package:chatbot_dcco/models/settings.dart';

class TestHelper {
  static Future<void> setupHive() async {
    await Hive.initFlutter('test_hive');

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ChatHistoryAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SettingsAdapter());
    }
  }

  static Future<void> cleanupHive() async {
    await Hive.deleteFromDisk();
  }

  static void setupMockResponses() {
    // Helper methods para configurar respuestas mock comunes
  }
}
