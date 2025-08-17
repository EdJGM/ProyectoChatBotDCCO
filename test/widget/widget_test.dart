import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:chatbot_dcco/controllers/chat_controller.dart';
import 'package:chatbot_dcco/controllers/settings_controller.dart';
import 'package:chatbot_dcco/views/chat/chat_screen.dart';
import 'package:chatbot_dcco/views/chat/widgets/bottom_chat_field.dart';
import 'package:chatbot_dcco/views/chat/widgets/my_message_widget.dart';
import 'package:chatbot_dcco/views/chat/widgets/assistant_message_widget.dart';
import 'package:chatbot_dcco/views/chat/widgets/chat_history_widget.dart';
import 'package:chatbot_dcco/views/chat/widgets/empty_history_widget.dart';
import 'package:chatbot_dcco/views/profile/widgets/settings_tile.dart';
import 'package:chatbot_dcco/views/home_screen.dart';
import 'package:chatbot_dcco/models/message.dart';
import 'package:chatbot_dcco/models/chat_history.dart';

@GenerateMocks([ChatProvider, SettingsProvider])
import 'widget_test.mocks.dart';

void main() {
  group('Pruebas de Widgets', () {
    late MockChatProvider mockChatProvider;
    late MockSettingsProvider mockSettingsProvider;

    setUp(() {
      mockChatProvider = MockChatProvider();
      mockSettingsProvider = MockSettingsProvider();

      // Setup default mock behaviors
      when(mockChatProvider.currentIndex).thenReturn(0);
      when(mockChatProvider.isLoading).thenReturn(false);
      when(mockChatProvider.inChatMessages).thenReturn([]);
      when(mockChatProvider.currentChatId).thenReturn('');
      when(mockChatProvider.pageController).thenReturn(PageController());

      when(mockSettingsProvider.isDarkMode).thenReturn(false);
      when(mockSettingsProvider.shouldSpeak).thenReturn(false);
    });

    group('ChatScreen Widget Tests', () {
      testWidgets('debe mostrar mensaje inicial cuando no hay mensajes', (WidgetTester tester) async {
        // Arrange
        when(mockChatProvider.inChatMessages).thenReturn([]);

        // Act
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<ChatProvider>.value(value: mockChatProvider),
            ],
            child: MaterialApp(
              home: ChatScreen(),
            ),
          ),
        );

        // Assert
        expect(find.text('Ingresa un mensaje para iniciar la conversación'), findsOneWidget);
        expect(find.text('Chat Simulado'), findsOneWidget);
      });

      testWidgets('debe mostrar botón de nuevo chat cuando hay mensajes', (WidgetTester tester) async {
        // Arrange
        final testMessage = Message(
          messageId: '1',
          chatId: 'test',
          message: StringBuffer('Test message'),
          timeSent: DateTime.now(),
          isFromUser: true,
        );

        when(mockChatProvider.inChatMessages).thenReturn([testMessage]);

        // Act
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<ChatProvider>.value(value: mockChatProvider),
            ],
            child: MaterialApp(
              home: ChatScreen(),
            ),
          ),
        );

        // Assert
        expect(find.byIcon(Icons.add), findsOneWidget);
      });
    });

    group('BottomChatField Widget Tests', () {
      testWidgets('debe renderizar campo de texto y botón de envío', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BottomChatField(chatProvider: mockChatProvider),
            ),
          ),
        );

        // Assert
        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Escribe un mensaje'), findsOneWidget);
        expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
      });

      testWidgets('debe llamar sentMessage cuando se toca el botón de envío', (WidgetTester tester) async {
        // Arrange
        when(mockChatProvider.sentMessage(
          message: anyNamed('message'),
          isTextOnly: anyNamed('isTextOnly'),
        )).thenAnswer((_) async {});

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BottomChatField(chatProvider: mockChatProvider),
            ),
          ),
        );

        // Act
        await tester.enterText(find.byType(TextField), 'Mensaje de prueba');
        await tester.tap(find.byIcon(Icons.arrow_upward));
        await tester.pump();

        // Assert
        verify(mockChatProvider.sentMessage(
          message: 'Mensaje de prueba',
          isTextOnly: true,
        )).called(1);
      });

      testWidgets('no debe enviar mensaje vacío', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BottomChatField(chatProvider: mockChatProvider),
            ),
          ),
        );

        // Act
        await tester.tap(find.byIcon(Icons.arrow_upward));
        await tester.pump();

        // Assert
        verifyNever(mockChatProvider.sentMessage(
          message: anyNamed('message'),
          isTextOnly: anyNamed('isTextOnly'),
        ));
      });
    });

    group('Message Widgets Tests', () {
      testWidgets('MyMessageWidget debe mostrar mensaje del usuario correctamente', (WidgetTester tester) async {
        // Arrange
        final userMessage = Message(
          messageId: '1',
          chatId: 'test',
          message: StringBuffer('Mensaje del usuario'),
          timeSent: DateTime.now(),
          isFromUser: true,
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MyMessageWidget(message: userMessage),
            ),
          ),
        );

        // Assert
        expect(find.text('Mensaje del usuario'), findsOneWidget);
      });

      testWidgets('AssistantMessageWidget debe mostrar mensaje del asistente', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AssistantMessageWidget(message: 'Mensaje del asistente'),
            ),
          ),
        );

        // Assert
        expect(find.text('Mensaje del asistente'), findsOneWidget);
      });

      testWidgets('AssistantMessageWidget debe mostrar spinner cuando mensaje está vacío', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AssistantMessageWidget(message: ''),
            ),
          ),
        );

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('ChatHistoryWidget Tests', () {
      testWidgets('debe mostrar información del chat correctamente', (WidgetTester tester) async {
        // Arrange
        final chatHistory = ChatHistory(
          chatId: 'test-chat',
          title: 'Chat de Prueba',
          createdAt: DateTime.now(),
          lastMessage: 'Último mensaje de prueba',
          lastMessageTime: DateTime.now(),
          modelType: 'simulacion',
        );

        // Act
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<ChatProvider>.value(value: mockChatProvider),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: ChatHistoryWidget(chat: chatHistory),
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('Chat de Prueba'), findsOneWidget);
        expect(find.text('Último mensaje de prueba'), findsOneWidget);
        expect(find.byIcon(Icons.delete), findsOneWidget);
      });

      testWidgets('debe mostrar diálogo de confirmación al eliminar', (WidgetTester tester) async {
        // Arrange
        final chatHistory = ChatHistory(
          chatId: 'test-chat',
          title: 'Chat de Prueba',
          createdAt: DateTime.now(),
          modelType: 'simulacion',
        );

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<ChatProvider>.value(value: mockChatProvider),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: ChatHistoryWidget(chat: chatHistory),
              ),
            ),
          ),
        );

        // Act
        await tester.tap(find.byIcon(Icons.delete));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Eliminar Chat'), findsOneWidget);
        expect(find.text('¿Estás seguro de que quieres eliminar este chat?'), findsOneWidget);
        expect(find.text('Cancelar'), findsOneWidget);
        expect(find.text('Eliminar'), findsOneWidget);
      });
    });

    group('EmptyHistoryWidget Tests', () {
      testWidgets('debe mostrar mensaje y botón cuando no hay historial', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<ChatProvider>.value(value: mockChatProvider),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: EmptyHistoryWidget(),
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('No hay conversaciones guardadas'), findsOneWidget);
        expect(find.text('Iniciar Nueva Conversación'), findsOneWidget);
        expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
      });

      testWidgets('debe llamar prepareChatRoom cuando se toca el botón', (WidgetTester tester) async {
        // Arrange
        when(mockChatProvider.prepareChatRoom(
          isNewChat: anyNamed('isNewChat'),
          chatID: anyNamed('chatID'),
        )).thenAnswer((_) async {});

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<ChatProvider>.value(value: mockChatProvider),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: EmptyHistoryWidget(),
              ),
            ),
          ),
        );

        // Act
        await tester.tap(find.text('Iniciar Nueva Conversación'));
        await tester.pump();

        // Assert
        verify(mockChatProvider.prepareChatRoom(
          isNewChat: true,
          chatID: '',
        )).called(1);
        verify(mockChatProvider.setCurrentIndex(newIndex: 1)).called(1);
      });
    });

    group('SettingsTile Widget Tests', () {
      testWidgets('debe mostrar configuración con switch', (WidgetTester tester) async {
        // Arrange
        bool testValue = false;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SettingsTile(
                icon: Icons.dark_mode,
                title: 'Modo Oscuro',
                value: testValue,
                onChanged: (value) {
                  testValue = value;
                },
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('Modo Oscuro'), findsOneWidget);
        expect(find.byIcon(Icons.dark_mode), findsOneWidget);
        expect(find.byType(Switch), findsOneWidget);
      });

      testWidgets('debe cambiar valor cuando se toca el switch', (WidgetTester tester) async {
        // Arrange
        bool testValue = false;

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return MaterialApp(
                home: Scaffold(
                  body: SettingsTile(
                    icon: Icons.dark_mode,
                    title: 'Modo Oscuro',
                    value: testValue,
                    onChanged: (value) {
                      setState(() {
                        testValue = value;
                      });
                    },
                  ),
                ),
              );
            },
          ),
        );

        // Act
        await tester.tap(find.byType(Switch));
        await tester.pump();

        // Assert
        expect(testValue, true);
      });
    });

    group('HomeScreen Navigation Tests', () {
      testWidgets('debe cambiar de página cuando se toca navigation bar', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<ChatProvider>.value(value: mockChatProvider),
            ],
            child: MaterialApp(
              home: HomeScreen(),
            ),
          ),
        );

        // Act - Tap en la segunda pestaña (Chat)
        await tester.tap(find.text('Chat'));
        await tester.pump();

        // Assert
        verify(mockChatProvider.setCurrentIndex(newIndex: 1)).called(1);
      });
    });
  });
}