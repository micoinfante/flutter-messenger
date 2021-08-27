import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:messenger/model/message_incoming.dart';
import 'package:messenger/screens/home_screen.dart';

import 'package:messenger/api/chat_service.dart';
import 'package:messenger/blocs/application_bloc.dart';
import 'package:messenger/blocs/bloc_provider.dart';
import 'package:messenger/blocs/message_event.dart';

import 'model/message_outgoing.dart';

void main() {
  return runApp(BlocProvider<ApplicationBloc>(
    bloc: ApplicationBloc(),
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ApplicationBloc _appBloc;
  late ChatService _service;

  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit == false) {
      _appBloc = BlocProvider.of<ApplicationBloc>(context)!;
      _service = ChatService(
          onMessageSent: _onMessageSent,
          onMessageSendFailed: _onMessageSendFailed,
          onMessageReceived: _onMessageReceived,
          onMessageReceivedFailed: _onMessageReceiveFailed);
      _service.start();

      _listenMessagesToSend();

      if (mounted) {
        setState(() {
          _isInit = true;
        });
      }
    }
  }

  void _listenMessagesToSend() async {
    await for (var event in _appBloc.outMessageSend) {
      var s = event.message;
      var out = OutgoingMessage(
          sender: s.sender,
          message: s.message,
          time: s.time,
          isLiked: s.isLiked,
          unread: s.unread);
      _service.send(out);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _service.shutdown();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Messenger',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.red,
        accentColor: Color(0xFFFEF9EB),
      ),
      home: HomeScreen(),
    );
  }

  /// 'outgoing message sent to the server' event
  void _onMessageSent(MessageSentEvent event) {
    debugPrint('Message "${event.message}" sent to the server');
    _appBloc.inMessageSent.add(event);
  }

  /// 'failed to send message' event
  void _onMessageSendFailed(MessageSendFailedEvent event) {
    debugPrint(
        'Failed to send message "${event.id}" to the server: ${event.error}');
    _appBloc.inMessageSendFailed.add(event);
  }

  /// 'new incoming message received from the server' event
  void _onMessageReceived(MessageReceivedEvent event) {
    debugPrint('Message received from the server: ${event.message}');
    _appBloc.inMessageReceived.add(event);
  }

  /// 'failed to receive messages' event
  void _onMessageReceiveFailed(MessageReceiveFailedEvent event) {
    debugPrint('Failed to receive messages from the server: ${event.error}');
  }
}
