import 'dart:async';
import 'dart:developer';
import 'package:chatbot_dcco/models/chat_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:chatbot_dcco/constants/constants.dart';
import 'package:chatbot_dcco/views/chat/widgets/boxes.dart';
import 'package:chatbot_dcco/views/chat/chat_history_screen.dart';
import 'package:chatbot_dcco/models/settings.dart';
import 'package:chatbot_dcco/models/user_model.dart';
import 'package:chatbot_dcco/models/message.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  // list of messages
  final List<Message> _inChatMessages = [];

  // page controller
  final PageController _pageController = PageController();

  // index of the current screen
  int _currentIndex = 0;

  // cuttent chatId
  String _currentChatId = '';

  // current mode
  String _modelType = 'simulacion';

  // loading bool
  bool _isLoading = false;

  // getters
  List<Message> get inChatMessages => _inChatMessages;

  PageController get pageController => _pageController;

  int get currentIndex => _currentIndex;

  String get currentChatId => _currentChatId;

  String get modelType => _modelType;

  bool get isLoading => _isLoading;

  // setters

  // set inChatMessages
  Future<void> setInChatMessages({required String chatId}) async {
    // get messages from hive database
    final messagesFromDB = await loadMessagesFromDB(chatId: chatId);

    for (var message in messagesFromDB) {
      if (_inChatMessages.contains(message)) {
        log('mensajes ya existen');
        continue;
      }

      _inChatMessages.add(message);
    }
    notifyListeners();
  }

  // load the messages from db
  Future<List<Message>> loadMessagesFromDB({required String chatId}) async {
    // open the box of this chatID
    await Hive.openBox('${Constants.chatMessagesBox}$chatId');

    final messageBox = Hive.box('${Constants.chatMessagesBox}$chatId');

    final newData = messageBox.keys.map((e) {
      final message = messageBox.get(e);
      final messageData = Message.fromMap(Map<String, dynamic>.from(message));

      return messageData;
    }).toList();
    notifyListeners();
    return newData;
  }

  // set the current model
  String setCurrentModel({required String newModel}) {
    _modelType = newModel;
    notifyListeners();
    return newModel;
  }

  // set current page index
  void setCurrentIndex({required int newIndex}) {
    _currentIndex = newIndex;
    notifyListeners();
  }

  // set current chat id
  void setCurrentChatId({required String newChatId}) {
    _currentChatId = newChatId;
    notifyListeners();
  }

  // set loading
  void setLoading({required bool value}) {
    _isLoading = value;
    notifyListeners();
  }

//?Yeha bata copy

  // eliminar los mensajes de un chat
  Future<void> deleteChatMessages({required String chatId}) async {
    // 1. check if the box is open
    if (!Hive.isBoxOpen('${Constants.chatMessagesBox}$chatId')) {
      // open the box
      await Hive.openBox('${Constants.chatMessagesBox}$chatId');

      // delete all messages in the box
      await Hive.box('${Constants.chatMessagesBox}$chatId').clear();

      // close the box
      await Hive.box('${Constants.chatMessagesBox}$chatId').close();
    } else {
      // delete all messages in the box
      await Hive.box('${Constants.chatMessagesBox}$chatId').clear();

      // close the box
      await Hive.box('${Constants.chatMessagesBox}$chatId').close();
    }

    // get the current chatId, its its not empty
    // we check if its the same as the chatId
    // if its the same we set it to empty
    if (currentChatId.isNotEmpty) {
      if (currentChatId == chatId) {
        setCurrentChatId(newChatId: '');
        _inChatMessages.clear();
        notifyListeners();
      }
    }
  }

  // prepare chat room
  Future<void> prepareChatRoom({
    required bool isNewChat,
    required String chatID,
  }) async {
    if (!isNewChat) {
      // 1.  load the chat messages from the db
      final chatHistory = await loadMessagesFromDB(chatId: chatID);

      // 2. clear the inChatMessages
      _inChatMessages.clear();

      for (var message in chatHistory) {
        _inChatMessages.add(message);
      }

      // 3. set the current chat id
      setCurrentChatId(newChatId: chatID);
    } else {
      // 1. clear the inChatMessages
      _inChatMessages.clear();

      // 2. set the current chat id
      setCurrentChatId(newChatId: chatID);
    }
  }

//?yeha samma

  Future<void> sentMessage({
    required String message,
    required bool isTextOnly,
  }) async {
    // Obtener el ID del chat actual o crear uno nuevo si no existe
    String chatId = getChatId();

    final chatBox = Boxes.getChatHistory();
    if (chatBox.get(chatId) == null) {
      // Crear el chat y actualizar el currentChatId con el ID generado
      chatId = await createNewChat(
        title: 'Chat ${DateTime.now().toString().substring(0, 16)}',
        modelType: modelType,
      );
    }

    // Simular un retraso para imitar el tiempo de respuesta de un servidor
    await Future.delayed(const Duration(milliseconds: 500));

    // Abrir o crear el box de mensajes para este chat
    if (!Hive.isBoxOpen('${Constants.chatMessagesBox}$chatId')) {
      await Hive.openBox('${Constants.chatMessagesBox}$chatId');
    }
    final messageBox = Hive.box('${Constants.chatMessagesBox}$chatId');

    // Crear un mensaje del usuario
    final userMessage = Message(
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: chatId,
      message: StringBuffer(message),
      timeSent: DateTime.now(),
      isFromUser: true,
    );

    // Guardar el mensaje del usuario en la base de datos
    await messageBox.put(userMessage.messageId, userMessage.toMap());

    // Actualizar el último mensaje en el historial
    await updateLastMessage(chatId: chatId, message: message);

    // Agregar el mensaje del usuario a la lista
    _inChatMessages.add(userMessage);
    notifyListeners();

    // Crear una respuesta simulada del asistente
    final assistantMessage = Message(
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: chatId,
      message: StringBuffer("Esta es una respuesta simulada a: \"$message\""),
      timeSent: DateTime.now(),
      isFromUser: false,
    );

    // Guardar la respuesta en la base de datos
    await messageBox.put(assistantMessage.messageId, assistantMessage.toMap());

    // Actualizar el último mensaje en el historial
    await updateLastMessage(chatId: chatId, message: "Esta es una respuesta simulada a: \"$message\"");

    // Agregar la respuesta simulada a la lista
    _inChatMessages.add(assistantMessage);
    notifyListeners();
  }

  // Método para cargar un chat específico
  Future<void> loadChat({required String chatId}) async {
    // Preparar la sala de chat
    await prepareChatRoom(isNewChat: false, chatID: chatId);

    // Navegar a la pantalla de chat
    setCurrentIndex(newIndex: 0);
  }

  String getChatId() {
    if (currentChatId.isEmpty) {
      return const Uuid().v4();
    } else {
      return currentChatId;
    }
  }

  // Crear un nuevo chat en el historial
  Future<String> createNewChat({
    required String title,
    String? modelType,
  }) async {
    // Generar un nuevo ID de chat
    final chatId = const Uuid().v4();

    // Crear un nuevo objeto ChatHistory
    final newChat = ChatHistory(
      chatId: chatId,
      title: title.isEmpty ? 'Chat ${DateTime.now().toString().substring(0, 16)}' : title,
      createdAt: DateTime.now(),
      modelType: modelType ?? 'simulacion',
    );

    // Guardar el chat en el box de Hive
    final box = Boxes.getChatHistory();
    await box.put(chatId, newChat);

    // Establecer el chatId actual
    setCurrentChatId(newChatId: chatId);

    return chatId;
  }

  // Actualizar el último mensaje en el historial de chat
  Future<void> updateLastMessage({
    required String chatId,
    required String message,
  }) async {
    final box = Boxes.getChatHistory();
    final chat = box.get(chatId);

    if (chat != null) {
      chat.lastMessage = message;
      chat.lastMessageTime = DateTime.now();
      await chat.save();
    }
  }

  // Eliminar un chat del historial
  Future<void> deleteChatHistory({required String chatId}) async {
    // Eliminar los mensajes del chat
    await deleteChatMessages(chatId: chatId);

    // Eliminar el chat del historial
    final box = Boxes.getChatHistory();
    await box.delete(chatId);

    notifyListeners();
  }

  // init Hive box
  static initHive() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ChatHistoryAdapter());
      await Hive.openBox<ChatHistory>(Constants.chatHistoryBox);
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserModelAdapter());
      await Hive.openBox<UserModel>(Constants.userBox);
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SettingsAdapter());
      await Hive.openBox<Settings>(Constants.settingsBox);
    }
  }
}
