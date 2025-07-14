import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chatbot_dcco/controllers/chat_controller.dart';
import 'package:chatbot_dcco/utility/animated_dialog.dart';

class BottomChatField extends StatefulWidget {
  const BottomChatField({
    super.key,
    required this.chatProvider,
  });

  final ChatProvider chatProvider;

  @override
  State<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<BottomChatField> {
  // controller for the input field
  final TextEditingController textController = TextEditingController();

  // focus node for the input field
  final FocusNode textFieldFocus = FocusNode();

  @override
  void dispose() {
    textController.dispose();
    textFieldFocus.dispose();
    super.dispose();
  }

  Future<void> sendChatMessage({
    required String message,
    required ChatProvider chatProvider,
    required bool isTextOnly,
  }) async {
    // Verificar que el mensaje no esté vacío
    if (message.trim().isEmpty) {
      return;
    }

    // Verificar que no se esté enviando otro mensaje
    if (chatProvider.isLoading) {
      return;
    }

    try {
      // Limpiar el campo de texto inmediatamente
      textController.clear();
      textFieldFocus.unfocus();

      // Llamar al método para enviar el mensaje
      await chatProvider.sentMessage(
        message: message.trim(),
        isTextOnly: isTextOnly,
      );
    } catch (e) {
      log('Error al enviar mensaje: $e');
      // Mostrar un snackbar o mensaje de error si es necesario
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar mensaje: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Theme.of(context).textTheme.titleLarge!.color!,
        ),
      ),
      child: Row(
            children: [
              const SizedBox(width: 5,),
              Expanded(
                child: TextField(
                  focusNode: textFieldFocus,
                  controller: textController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: widget.chatProvider.isLoading
                      ? null
                      : (String value) {
                    if (value.isNotEmpty) {
                      // send the message
                      sendChatMessage(
                        message: textController.text,
                        chatProvider: widget.chatProvider,
                        isTextOnly: true,
                      );
                    }
                  },
                  decoration: InputDecoration.collapsed(
                      hintText: 'Escribe un mensaje',
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(30),
                      )),
                ),
              ),
              GestureDetector(
                onTap: widget.chatProvider.isLoading
                    ? null
                    : () {
                  if (textController.text.isNotEmpty) {
                    // send the message
                    sendChatMessage(
                      message: textController.text,
                      chatProvider: widget.chatProvider,
                      isTextOnly: true,
                    );
                  }
                },
                child: Container(
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.all(5.0),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        // Icons.arrow_upward,
                        CupertinoIcons.arrow_up,
                        color: Colors.white,
                      ),
                    )),
              )
            ],
          ),
      );
  }
}
