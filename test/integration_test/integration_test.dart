import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:chatbot_dcco/controllers/chat_controller.dart';
import 'package:chatbot_dcco/models/message.dart';
import 'package:chatbot_dcco/models/chat_history.dart';
import 'package:chatbot_dcco/models/settings.dart';
import 'dart:convert';

@GenerateMocks([http.Client])
import 'integration_test.mocks.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Pruebas de Integración - ChatBot DCCO', () {
    late ChatProvider chatProvider;
    late MockClient mockHttpClient;

    setUpAll(() async {
      // Inicializar Hive para pruebas
      await Hive.initFlutter('test_hive');

      // Registrar adaptadores si no están registrados
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(ChatHistoryAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(SettingsAdapter());
      }
    });

    setUp(() async {
      chatProvider = ChatProvider();
      mockHttpClient = MockClient();

      // Limpiar boxes antes de cada test
      if (Hive.isBoxOpen('chat_history')) {
        await Hive.box('chat_history').clear();
      }
      if (Hive.isBoxOpen('settings')) {
        await Hive.box('settings').clear();
      }
    });

    tearDownAll(() async {
      // Cerrar todas las boxes
      await Hive.close();
    });

    group('Integración ChatProvider + Hive', () {
      testWidgets('debe crear y guardar un nuevo chat en Hive', (WidgetTester tester) async {
        // Arrange
        if (!Hive.isBoxOpen('chat_history')) {
          await Hive.openBox<ChatHistory>('chat_history');
        }
        final box = Hive.box<ChatHistory>('chat_history');

        // Act
        final chatId = await chatProvider.createNewChat(
            title: 'Test Chat Integration',
            modelType: 'simulacion'
        );

        // Assert
        expect(chatId, isNotEmpty);
        expect(chatProvider.currentChatId, equals(chatId));

        final savedChat = box.get(chatId);
        expect(savedChat, isNotNull);
        expect(savedChat!.title, equals('Test Chat Integration'));
        expect(savedChat.modelType, equals('simulacion'));
      });

      testWidgets('debe cargar mensajes desde Hive correctamente', (WidgetTester tester) async {
        // Arrange
        const testChatId = 'test-chat-integration';
        final messagesBoxName = 'chat_messages_$testChatId';

        if (!Hive.isBoxOpen(messagesBoxName)) {
          await Hive.openBox(messagesBoxName);
        }
        final messageBox = Hive.box(messagesBoxName);

        // Crear mensajes de prueba en Hive
        final testMessage1 = Message(
          messageId: '1',
          chatId: testChatId,
          message: StringBuffer('Mensaje de prueba 1'),
          timeSent: DateTime.now(),
          isFromUser: true,
        );

        final testMessage2 = Message(
          messageId: '2',
          chatId: testChatId,
          message: StringBuffer('Respuesta de prueba 1'),
          timeSent: DateTime.now(),
          isFromUser: false,
        );

        await messageBox.put(testMessage1.messageId, testMessage1.toMap());
        await messageBox.put(testMessage2.messageId, testMessage2.toMap());

        // Act
        final loadedMessages = await chatProvider.loadMessagesFromDB(chatId: testChatId);

        // Assert
        expect(loadedMessages, hasLength(2));
        expect(loadedMessages.any((msg) => msg.message.toString() == 'Mensaje de prueba 1'), true);
        expect(loadedMessages.any((msg) => msg.message.toString() == 'Respuesta de prueba 1'), true);

        // Cleanup
        await messageBox.close();
      });

      testWidgets('debe eliminar chat y sus mensajes correctamente', (WidgetTester tester) async {
        // Arrange
        if (!Hive.isBoxOpen('chat_history')) {
          await Hive.openBox<ChatHistory>('chat_history');
        }
        final historyBox = Hive.box<ChatHistory>('chat_history');

        // Crear chat de prueba
        final chatId = await chatProvider.createNewChat(
            title: 'Chat a eliminar',
            modelType: 'simulacion'
        );

        // Verificar que el chat existe
        expect(historyBox.get(chatId), isNotNull);

        // Act
        await chatProvider.deleteChatHistory(chatId: chatId);

        // Assert
        expect(historyBox.get(chatId), isNull);
        expect(chatProvider.currentChatId, isEmpty);
      });
    });

    group('Integración HTTP + ChatProvider', () {
      testWidgets('debe enviar mensaje y recibir respuesta del servidor', (WidgetTester tester) async {
        // Arrange
        const testMessage = 'Hola, ¿qué carreras ofrece el DCCO?';
        const expectedResponse = 'El DCCO ofrece Software, ITIN e ITIN en línea.';

        // Mock HTTP response
        when(mockHttpClient.post(
          Uri.parse('http://74.235.218.90:8000/api/chatbot/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'pregunta': testMessage}),
        )).thenAnswer((_) async => http.Response(
          jsonEncode({'respuesta': expectedResponse}),
          200,
        ));

        // Preparar chat room
        await chatProvider.prepareChatRoom(isNewChat: true, chatID: '');

        // Act
        await chatProvider.sentMessage(
          message: testMessage,
          isTextOnly: true,
        );

        // Assert
        expect(chatProvider.inChatMessages, hasLength(2)); // Usuario + Asistente
        expect(chatProvider.inChatMessages.first.message.toString(), equals(testMessage));
        expect(chatProvider.inChatMessages.first.isFromUser, true);
        expect(chatProvider.inChatMessages.last.isFromUser, false);
      });

      testWidgets('debe manejar error del servidor correctamente', (WidgetTester tester) async {
        // Arrange
        const testMessage = 'Mensaje de prueba';

        // Mock HTTP error response
        when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('Server Error', 500));

        // Preparar chat room
        await chatProvider.prepareChatRoom(isNewChat: true, chatID: '');

        // Act
        await chatProvider.sentMessage(
          message: testMessage,
          isTextOnly: true,
        );

        // Assert
        expect(chatProvider.inChatMessages, hasLength(2));
        expect(chatProvider.inChatMessages.last.message.toString(),
            contains('Error: No se pudo obtener respuesta del servidor'));
      });

      testWidgets('debe manejar error de conexión correctamente', (WidgetTester tester) async {
        // Arrange
        const testMessage = 'Mensaje de prueba';

        // Mock network error
        when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenThrow(Exception('Network error'));

        // Preparar chat room
        await chatProvider.prepareChatRoom(isNewChat: true, chatID: '');

        // Act
        await chatProvider.sentMessage(
          message: testMessage,
          isTextOnly: true,
        );

        // Assert
        expect(chatProvider.inChatMessages, hasLength(2));
        expect(chatProvider.inChatMessages.last.message.toString(),
            contains('Error: No se pudo conectar con el servidor'));
      });
    });

    group('Integración Settings + Hive', () {
      testWidgets('debe persistir configuraciones en Hive', (WidgetTester tester) async {
        // Arrange
        if (!Hive.isBoxOpen('settings')) {
          await Hive.openBox<Settings>('settings');
        }
        final settingsBox = Hive.box<Settings>('settings');

        final settings = Settings(isDarkTheme: true, shouldSpeak: false);

        // Act
        await settingsBox.put(0, settings);

        // Assert
        final savedSettings = settingsBox.getAt(0);
        expect(savedSettings, isNotNull);
        expect(savedSettings!.isDarkTheme, true);
        expect(savedSettings.shouldSpeak, false);
      });
    });

    group('Integración Flujo Completo de Chat', () {
      testWidgets('debe completar flujo: crear chat -> enviar mensaje -> guardar -> cargar',
              (WidgetTester tester) async {
            // Arrange
            const userMessage = '¿Cuáles son los requisitos para Software?';
            const botResponse = 'Los requisitos para Software incluyen...';

            // Mock HTTP response
            when(mockHttpClient.post(
              any,
              headers: anyNamed('headers'),
              body: anyNamed('body'),
            )).thenAnswer((_) async => http.Response(
              jsonEncode({'respuesta': botResponse}),
              200,
            ));

            // Act 1: Crear nuevo chat
            final chatId = await chatProvider.createNewChat(
                title: 'Consulta Software',
                modelType: 'simulacion'
            );

            // Act 2: Enviar mensaje
            await chatProvider.sentMessage(
              message: userMessage,
              isTextOnly: true,
            );

            // Act 3: Simular recarga de la app - cargar chat existente
            await chatProvider.prepareChatRoom(isNewChat: false, chatID: chatId);

            // Assert
            expect(chatProvider.currentChatId, equals(chatId));
            expect(chatProvider.inChatMessages, hasLength(2));
            expect(chatProvider.inChatMessages.first.message.toString(), equals(userMessage));
            expect(chatProvider.inChatMessages.last.message.toString(), equals(botResponse));
          });
    });
  });
}