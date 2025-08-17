import 'package:flutter_test/flutter_test.dart';
import 'package:chatbot_dcco/models/message.dart';
import 'package:chatbot_dcco/models/chat_history.dart';
import 'package:chatbot_dcco/models/settings.dart';
import 'package:chatbot_dcco/models/user_model.dart';
import 'package:chatbot_dcco/controllers/chat_controller.dart';
import 'package:chatbot_dcco/controllers/settings_controller.dart';

void main() {
  group('Modelos', () {
    test('Message debe convertir a Map correctamente', () {
      final message = Message(
        messageId: 'msg-123',
        chatId: 'chat-456', 
        message: StringBuffer('Hola'),
        timeSent: DateTime(2024, 1, 1),
        isFromUser: true,
      );
      
      final map = message.toMap();
      expect(map['messageId'], equals('msg-123'));
      expect(map['isFromUser'], equals(true));
      expect(map['message'], equals('Hola'));
    });

    test('Message debe crear desde Map correctamente', () {
      final map = {
        'messageId': 'msg-456',
        'chatId': 'chat-789',
        'message': 'Test message',
        'timeSent': DateTime(2024, 1, 1).millisecondsSinceEpoch,
        'isFromUser': false,
      };
      
      final message = Message.fromMap(map);
      expect(message.messageId, equals('msg-456'));
      expect(message.chatId, equals('chat-789'));
      expect(message.message.toString(), equals('Test message'));
      expect(message.isFromUser, equals(false));
    });

    test('ChatHistory debe convertir a Map correctamente', () {
      final chat = ChatHistory(
        chatId: 'chat-123',
        title: 'Mi Chat',
        createdAt: DateTime(2024, 1, 1),
        modelType: 'simulacion',
      );
      
      final map = chat.toMap();
      expect(map['chatId'], equals('chat-123'));
      expect(map['title'], equals('Mi Chat'));
      expect(map['modelType'], equals('simulacion'));
    });

    test('Settings debe crear con valores correctos', () {
      final settings = Settings(isDarkTheme: true, shouldSpeak: false);
      expect(settings.isDarkTheme, equals(true));
      expect(settings.shouldSpeak, equals(false));
    });
  });

  group('ChatProvider', () {
    late ChatProvider provider;

    setUp(() {
      provider = ChatProvider();
    });

    test('debe tener valores iniciales correctos', () {
      expect(provider.currentIndex, equals(0));
      expect(provider.isLoading, equals(false));
      expect(provider.modelType, equals('simulacion'));
      expect(provider.currentChatId, isEmpty);
      expect(provider.inChatMessages, isEmpty);
    });

    test('debe cambiar currentIndex', () {
      provider.setCurrentIndex(newIndex: 2);
      expect(provider.currentIndex, equals(2));
    });

    test('debe cambiar currentChatId', () {
      provider.setCurrentChatId(newChatId: 'test-123');
      expect(provider.currentChatId, equals('test-123'));
    });

    test('debe cambiar loading state', () {
      provider.setLoading(value: true);
      expect(provider.isLoading, equals(true));
      
      provider.setLoading(value: false);
      expect(provider.isLoading, equals(false));
    });

    test('debe cambiar modelo', () {
      final result = provider.setCurrentModel(newModel: 'nuevo-modelo');
      expect(provider.modelType, equals('nuevo-modelo'));
      expect(result, equals('nuevo-modelo'));
    });

    test('getChatId debe funcionar correctamente', () {
      // Sin chat ID
      expect(provider.getChatId(), isEmpty);
      
      // Con chat ID
      provider.setCurrentChatId(newChatId: 'mi-chat');
      expect(provider.getChatId(), equals('mi-chat'));
    });

    test('prepareChatRoom debe limpiar mensajes para nuevo chat', () async {
      // Agregar un mensaje
      final message = Message(
        messageId: '1',
        chatId: 'old-chat',
        message: StringBuffer('Test'),
        timeSent: DateTime.now(),
        isFromUser: true,
      );
      provider.inChatMessages.add(message);
      expect(provider.inChatMessages, hasLength(1));
      
      // Preparar nuevo chat
      await provider.prepareChatRoom(isNewChat: true, chatID: 'new-chat');
      
      expect(provider.inChatMessages, isEmpty);
      expect(provider.currentChatId, equals('new-chat'));
    });
  });

  group('SettingsProvider', () {
    late SettingsProvider provider;

    setUp(() {
      provider = SettingsProvider();
    });

    test('debe tener valores iniciales correctos', () {
      expect(provider.isDarkMode, equals(false));
      expect(provider.shouldSpeak, equals(false));
    });

    // Nota: No probamos métodos que usan Hive para evitar errores
  });

  group('Validaciones', () {
    test('debe validar mensajes vacíos', () {
      expect(''.trim().isEmpty, true);
      expect('   '.trim().isEmpty, true);
      expect('Hola'.trim().isEmpty, false);
    });

    test('debe validar IDs', () {
      expect('chat-123'.isNotEmpty, true);
      expect(''.isEmpty, true);
    });

    test('debe manejar timestamps', () {
      final now = DateTime.now();
      final past = DateTime(2024, 1, 1);
      expect(now.isAfter(past), true);
    });

    test('debe formatear fechas', () {
      final date = DateTime(2024, 12, 25, 15, 30);
      final timestamp = date.millisecondsSinceEpoch;
      final reconstructed = DateTime.fromMillisecondsSinceEpoch(timestamp);
      expect(reconstructed, equals(date));
    });

    test('debe manejar StringBuffer', () {
      final buffer = StringBuffer('Inicio');
      buffer.write(' - Fin');
      expect(buffer.toString(), equals('Inicio - Fin'));
    });
  });
  
  test('ChatHistory debe crear desde Map correctamente', () {
    final map = {
      'chatId': 'chat-456',
      'title': 'Test Chat',
      'createdAt': DateTime(2024, 1, 1).millisecondsSinceEpoch,
      'lastMessage': 'Último mensaje',
      'lastMessageTime': DateTime(2024, 1, 1, 12, 0).millisecondsSinceEpoch,
      'modelType': 'simulacion',
    };
    
    final chat = ChatHistory.fromMap(map);
    expect(chat.chatId, equals('chat-456'));
    expect(chat.title, equals('Test Chat'));
    expect(chat.lastMessage, equals('Último mensaje'));
    expect(chat.lastMessageTime, isNotNull);
    expect(chat.modelType, equals('simulacion'));
  });    

  test('ChatHistory debe manejar campos opcionales', () {
    final chat = ChatHistory(
      chatId: 'chat-789',
      title: 'Sin mensajes',
      createdAt: DateTime(2024, 1, 1),
      modelType: 'test',
    );
    
    expect(chat.lastMessage, isNull);
    expect(chat.lastMessageTime, isNull);
    expect(chat.modelType, equals('test'));
  });

  test('sentMessage debe validar mensaje vacío', () async {
    final provider = ChatProvider();
    await provider.sentMessage(message: '', isTextOnly: true);
    
    // No debe agregar mensajes vacíos
    expect(provider.inChatMessages, isEmpty);
  });  

  test('sentMessage debe validar mensaje con espacios', () async {
    final provider = ChatProvider();
    await provider.sentMessage(message: '   ', isTextOnly: true);
    
    // No debe agregar mensajes solo con espacios
    expect(provider.inChatMessages, isEmpty);
  });  

  group('UserModel', () {
    test('UserModel debe crearse correctamente', () {
      final user = UserModel(uid: 'u1', name: 'Juan', image: 'img.png');
      expect(user.uid, equals('u1'));
      expect(user.name, equals('Juan'));
      expect(user.image, equals('img.png'));
    });
  });

  group('Settings', () {
    test('Settings debe inicializar valores correctamente', () {
      final s = Settings(isDarkTheme: false, shouldSpeak: true);
      expect(s.isDarkTheme, isFalse);
      expect(s.shouldSpeak, isTrue);
    });
  });

  group('Message', () {
    test('Message toMap y fromMap deben ser inversos', () {
      final original = Message(
        messageId: 'm1',
        chatId: 'c1',
        message: StringBuffer('Hola mundo'),
        timeSent: DateTime(2024, 8, 12),
        isFromUser: true,
      );
      final map = original.toMap();
      final copy = Message.fromMap(map);
      expect(copy.messageId, original.messageId);
      expect(copy.chatId, original.chatId);
      expect(copy.message.toString(), original.message.toString());
      expect(copy.timeSent, original.timeSent);
      expect(copy.isFromUser, original.isFromUser);
    });
  });

  group('ChatHistory', () {
    test('ChatHistory toMap y fromMap deben ser inversos', () {
      final original = ChatHistory(
        chatId: 'c2',
        title: 'Chat prueba',
        createdAt: DateTime(2024, 8, 12),
        lastMessage: 'Hola',
        lastMessageTime: DateTime(2024, 8, 12, 10, 0),
        modelType: 'simulacion',
      );
      final map = original.toMap();
      final copy = ChatHistory.fromMap(map);
      expect(copy.chatId, original.chatId);
      expect(copy.title, original.title);
      expect(copy.createdAt, original.createdAt);
      expect(copy.lastMessage, original.lastMessage);
      expect(copy.lastMessageTime, original.lastMessageTime);
      expect(copy.modelType, original.modelType);
    });
  });

  group('ChatProvider métodos simples', () {
    late ChatProvider provider;

    setUp(() {
      provider = ChatProvider();
    });

    test('setCurrentModel actualiza el modelo', () {
      provider.setCurrentModel(newModel: 'otro');
      expect(provider.modelType, equals('otro'));
    });

    test('setCurrentIndex actualiza el índice', () {
      provider.setCurrentIndex(newIndex: 5);
      expect(provider.currentIndex, equals(5));
    });

    test('setCurrentChatId actualiza el chatId', () {
      provider.setCurrentChatId(newChatId: 'nuevo');
      expect(provider.currentChatId, equals('nuevo'));
    });

    test('setLoading actualiza el estado de carga', () {
      provider.setLoading(value: true);
      expect(provider.isLoading, isTrue);
      provider.setLoading(value: false);
      expect(provider.isLoading, isFalse);
    });
  });

  group('SettingsProvider métodos simples', () {
    late SettingsProvider provider;

    setUp(() {
      provider = SettingsProvider();
    });

    // test('toggleDarkMode cambia el modo oscuro', () {
    //   provider.toggleDarkMode(value: true);
    //   expect(provider.isDarkMode, isTrue);
    //   provider.toggleDarkMode(value: false);
    //   expect(provider.isDarkMode, isFalse);
    // });

    // test('toggleSpeak cambia el estado de speak', () {
    //   provider.toggleSpeak(value: true);
    //   expect(provider.shouldSpeak, isTrue);
    //   provider.toggleSpeak(value: false);
    //   expect(provider.shouldSpeak, isFalse);
    // });
  });  

group('ChatProvider lógica interna', () {
  late ChatProvider provider;

  setUp(() {
    provider = ChatProvider();
  });

  test('setCurrentModel actualiza y retorna el modelo', () {
    final result = provider.setCurrentModel(newModel: 'test-model');
    expect(provider.modelType, equals('test-model'));
    expect(result, equals('test-model'));
  });

  test('setCurrentIndex actualiza el índice', () {
    provider.setCurrentIndex(newIndex: 7);
    expect(provider.currentIndex, equals(7));
  });

  test('setCurrentChatId actualiza el chatId', () {
    provider.setCurrentChatId(newChatId: 'chat-xyz');
    expect(provider.currentChatId, equals('chat-xyz'));
  });

  test('setLoading actualiza el estado de carga', () {
    provider.setLoading(value: true);
    expect(provider.isLoading, isTrue);
    provider.setLoading(value: false);
    expect(provider.isLoading, isFalse);
  });

  test('getChatId retorna el chatId actual o vacío', () {
    expect(provider.getChatId(), isEmpty);
    provider.setCurrentChatId(newChatId: 'id-123');
    expect(provider.getChatId(), equals('id-123'));
  });
});

group('SettingsProvider lógica interna', () {
  late SettingsProvider provider;

  setUp(() {
    provider = SettingsProvider();
  });

  test('isDarkMode y shouldSpeak valores iniciales', () {
    expect(provider.isDarkMode, isFalse);
    expect(provider.shouldSpeak, isFalse);
  });

  // test('toggleDarkMode actualiza el valor interno sin Hive', () {
  //   provider.toggleDarkMode(value: true); // No pases el parámetro settings
  //   expect(provider.isDarkMode, isTrue);
  //   provider.toggleDarkMode(value: false);
  //   expect(provider.isDarkMode, isFalse);
  // });

  // test('toggleSpeak actualiza el valor interno sin Hive', () {
  //   provider.toggleSpeak(value: true); // No pases el parámetro settings
  //   expect(provider.shouldSpeak, isTrue);
  //   provider.toggleSpeak(value: false);
  //   expect(provider.shouldSpeak, isFalse);
  // });
}); 
}