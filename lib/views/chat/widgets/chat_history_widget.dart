import 'package:chatbot_dcco/views/chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:chatbot_dcco/models/chat_history.dart';
import 'package:chatbot_dcco/controllers/chat_controller.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ChatHistoryWidget extends StatelessWidget {
  final ChatHistory chat;

  const ChatHistoryWidget({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          chat.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (chat.lastMessage != null)
              Text(
                chat.lastMessage!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (chat.lastMessageTime != null)
              Text(
                DateFormat('dd/MM/yyyy HH:mm').format(chat.lastMessageTime!),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                // Mostrar diálogo de confirmación
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Eliminar Chat'),
                    content: const Text('¿Estás seguro de que quieres eliminar este chat?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          // Eliminar el chat
                          chatProvider.deleteChatHistory(chatId: chat.chatId);
                          Navigator.of(context).pop();
                        },
                        child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        onTap: () async {
          final chatProvider = Provider.of<ChatProvider>(context, listen: false);
          await chatProvider.loadChat(chatId: chat.chatId);
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ChatScreen()),
          );
        },
      ),
    );
  }
}