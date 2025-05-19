import 'package:flutter/material.dart';
import 'package:chatbot_dcco/models/message.dart';
import 'package:chatbot_dcco/controllers/chat_controller.dart';
import 'package:chatbot_dcco/views/chat/widgets/assistant_message_widget.dart';
import 'package:chatbot_dcco/views/chat/widgets/my_message_widget.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({
    super.key,
    required this.scrollController,
    required this.chatProvider,
  });

  final ScrollController scrollController;
  final ChatProvider chatProvider;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: chatProvider.inChatMessages.length,
      itemBuilder: (context, index) {
        // compare with timeSent before showing the list
        final message = chatProvider.inChatMessages[index];
        final isUserMessage = index % 2 == 0; // Ejemplo de lógica para diferenciar mensajes
        return isUserMessage
            ? MyMessageWidget(message: message)
            : AssistantMessageWidget(message: message.message.toString());
      },
    );
  }
}
