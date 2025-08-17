import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:chatbot_dcco/controllers/chat_controller.dart';
import 'package:chatbot_dcco/models/message.dart';
import 'package:chatbot_dcco/models/chat_history.dart';

// Genera mocks automáticamente
@GenerateMocks([Box, http.Client])
import 'chat_controller_test.mocks.dart';

void main() {
  group('ChatController - Pruebas Unitarias', () {
    late ChatProvider chatProvider;
    late MockBox<ChatHistory> mockChatHistoryBox;
    late MockBox mockMessageBox;
    late MockClient mockHttpClient;

    setUp(() {
      chatProvider = ChatProvider();
      mockChatHistoryBox = MockBox<ChatHistory>();
      mockMessageBox = MockBox();
      mockHttpClient = MockClient();
    });

    group('Gestión de Estado', () {
      test('setCurrentIndex debe actualizar el índice actual', () {
        // Arrange
        const newIndex = 2;

        // Act
        chatProvider.setCurrentIndex(newIndex: newIndex);

        // Assert
        expect(chatProvider.currentIndex, equals(newIndex));
      });

      test('setCurrentChatId debe actualizar el chatId actual', () {
        // Arrange
        const newChatId = 'test-chat-id-123';

        // Act
        chatProvider.setCurrentChatId(newChatId: newChatId);

        // Assert
        expect(chatProvider.currentChatId, equals(newChatId));
      });

      test('setLoading debe cambiar el estado de loading', () {
        // Arrange
        expect(chatProvider.isLoading, false);

        // Act
        chatProvider.setLoading(value: true);

        // Assert
        expect(chatProvider.isLoading, true);

        // Act
        chatProvider.setLoading(value: false);

        // Assert
        expect(chatProvider.isLoading, false);
      });

      test('setCurrentModel debe actualizar el modelo actual', () {
        // Arrange
        const newModel = 'test-model';

        // Act
        final result = chatProvider.setCurrentModel(newModel: newModel);

        // Assert
        expect(chatProvider.modelType, equals(newModel));
        expect(result, equals(newModel));
      });
    });

    group('Gestión de Mensajes', () {
      test('getChatId debe retornar chatId actual si existe', () {
        // Arrange
        const testChatId = 'existing-chat-id';
        chatProvider.setCurrentChatId(newChatId: testChatId);

        // Act
        final result = chatProvider.getChatId();

        // Assert
        expect(result, equals(testChatId));
      });

      test('getChatId debe retornar string vacío si no hay chatId', () {
        // Arrange - chatId por defecto está vacío

        // Act
        final result = chatProvider.getChatId();

        // Assert
        expect(result, isEmpty);
      });

      test('prepareChatRoom debe limpiar mensajes para nuevo chat', () async {
        // Arrange
        final testMessage = Message(
          messageId: '1',
          chatId: 'old-chat',
          message: StringBuffer('Test message'),
          timeSent: DateTime.now(),
          isFromUser: true,
        );
        chatProvider.inChatMessages.add(testMessage);

        // Act
        await chatProvider.prepareChatRoom(
            isNewChat: true,
            chatID: 'new-chat-id'
        );

        // Assert
        expect(chatProvider.inChatMessages, isEmpty);
        expect(chatProvider.currentChatId, equals('new-chat-id'));
      });
    });

    group('Validaciones de Entrada', () {
      test('sentMessage no debe procesar mensaje vacío', () async {
        // Arrange
        const emptyMessage = '';

        // Act
        await chatProvider.sentMessage(
          message: emptyMessage,
          isTextOnly: true,
        );

        // Assert
        expect(chatProvider.inChatMessages, isEmpty);
        expect(chatProvider.isLoading, false);
      });

      test('sentMessage no debe procesar mensaje solo con espacios', () async {
        // Arrange
        const whitespaceMessage = '   ';

        // Act
        await chatProvider.sentMessage(
          message: whitespaceMessage,
          isTextOnly: true,
        );

        // Assert
        expect(chatProvider.inChatMessages, isEmpty);
        expect(chatProvider.isLoading, false);
      });
    });

    group('Manejo de Errores', () {
      test('debe manejar excepción al enviar mensaje', () async {
        // Arrange
        const testMessage = 'Test message';

        // Simular error en HTTP
        when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenThrow(Exception('Network error'));

        // Act & Assert - no debe lanzar excepción
        expect(
              () async => await chatProvider.sentMessage(
            message: testMessage,
            isTextOnly: true,
          ),
          returnsNormally,
        );
      });
    });
  });

  group('Message Model - Pruebas Unitarias', () {
    test('toMap debe convertir Message a Map correctamente', () {
      // Arrange
      final message = Message(
        messageId: 'msg-123',
        chatId: 'chat-456',
        message: StringBuffer('Test message'),
        timeSent: DateTime(2024, 1, 1, 12, 0, 0),
        isFromUser: true,
      );

      // Act
      final map = message.toMap();

      // Assert
      expect(map['messageId'], equals('msg-123'));
      expect(map['chatId'], equals('chat-456'));
      expect(map['message'], equals('Test message'));
      expect(map['timeSent'], equals(DateTime(2024, 1, 1, 12, 0, 0).millisecondsSinceEpoch));
      expect(map['isFromUser'], equals(true));
    });

    test('fromMap debe crear Message desde Map correctamente', () {
      // Arrange
      final map = {
        'messageId': 'msg-123',
        'chatId': 'chat-456',
        'message': 'Test message',
        'timeSent': DateTime(2024, 1, 1, 12, 0, 0).millisecondsSinceEpoch,
        'isFromUser': true,
      };

      // Act
      final message = Message.fromMap(map);

      // Assert
      expect(message.messageId, equals('msg-123'));
      expect(message.chatId, equals('chat-456'));
      expect(message.message.toString(), equals('Test message'));
      expect(message.timeSent, equals(DateTime(2024, 1, 1, 12, 0, 0)));
      expect(message.isFromUser, equals(true));
    });
  });

  group('ChatHistory Model - Pruebas Unitarias', () {
    test('toMap debe convertir ChatHistory a Map correctamente', () {
      // Arrange
      final chatHistory = ChatHistory(
        chatId: 'chat-123',
        title: 'Test Chat',
        createdAt: DateTime(2024, 1, 1, 10, 0, 0),
        lastMessage: 'Last message',
        lastMessageTime: DateTime(2024, 1, 1, 11, 0, 0),
        modelType: 'simulacion',
      );

      // Act
      final map = chatHistory.toMap();

      // Assert
      expect(map['chatId'], equals('chat-123'));
      expect(map['title'], equals('Test Chat'));
      expect(map['lastMessage'], equals('Last message'));
      expect(map['modelType'], equals('simulacion'));
    });

    test('fromMap debe crear ChatHistory desde Map correctamente', () {
      // Arrange
      final map = {
        'chatId': 'chat-123',
        'title': 'Test Chat',
        'createdAt': DateTime(2024, 1, 1, 10, 0, 0).millisecondsSinceEpoch,
        'lastMessage': 'Last message',
        'lastMessageTime': DateTime(2024, 1, 1, 11, 0, 0).millisecondsSinceEpoch,
        'modelType': 'simulacion',
      };

      // Act
      final chatHistory = ChatHistory.fromMap(map);

      // Assert
      expect(chatHistory.chatId, equals('chat-123'));
      expect(chatHistory.title, equals('Test Chat'));
      expect(chatHistory.lastMessage, equals('Last message'));
      expect(chatHistory.modelType, equals('simulacion'));
    });
  });
}