import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chatbot_dcco/main.dart';
import 'package:chatbot_dcco/controllers/chat_controller.dart';
import 'package:chatbot_dcco/controllers/settings_controller.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('debe navegar entre pantallas correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Verificar pantalla inicial
      expect(find.text('Historial de Chats'), findsOneWidget);

      // Navegar a Chat
      await tester.tap(find.text('Chat'));
      await tester.pumpAndSettle();
      expect(find.text('Chat Simulado'), findsOneWidget);

      // Navegar a Feedback
      await tester.tap(find.text('Feedback'));
      await tester.pumpAndSettle();
      expect(find.text('Tu opinión es importante'), findsOneWidget);

      // Navegar a Información
      await tester.tap(find.text('Información'));
      await tester.pumpAndSettle();
      expect(find.text('DCCO'), findsOneWidget);
    });

    testWidgets('debe enviar mensaje y mostrar respuesta', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Ir a la pantalla de chat
      await tester.tap(find.text('Chat'));
      await tester.pumpAndSettle();

      // Escribir y enviar mensaje
      await tester.enterText(find.byType(TextField), '¿Qué carreras ofrecen?');
      await tester.tap(find.byIcon(Icons.arrow_upward));
      await tester.pumpAndSettle();

      // Verificar que el mensaje se muestra
      expect(find.text('¿Qué carreras ofrecen?'), findsOneWidget);
    });
  });
}