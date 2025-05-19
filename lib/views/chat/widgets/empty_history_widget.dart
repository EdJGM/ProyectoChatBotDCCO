import 'package:chatbot_dcco/controllers/chat_controller.dart';
import 'package:chatbot_dcco/views/chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmptyHistoryWidget extends StatelessWidget {
  const EmptyHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: GestureDetector(
        onTap: () async {
          //navegar a la pantalla de chat
          final chatProvider = context.read<ChatProvider>();
          //preparar la sala de chat
          await chatProvider.prepareChatRoom(
            isNewChat: true,
            chatID: '',
          );
          chatProvider.setCurrentIndex(newIndex: 1);
          chatProvider.pageController.jumpToPage(1);
        },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
          const Text(
            'No hay conversaciones guardadas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Comienza una nueva conversación desde la pantalla de chat',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () async {
              //navegar a la pantalla de chat
              final chatProvider = context.read<ChatProvider>();
              //preparar la sala de chat
              await chatProvider.prepareChatRoom(
                isNewChat: true,
                chatID: '',
              );
              chatProvider.setCurrentIndex(newIndex: 1);
              chatProvider.pageController.jumpToPage(1);
            },
            child: const Text('Iniciar Nueva Conversación'),
          ),
        ],
      ),
    ),
    );
  }
}