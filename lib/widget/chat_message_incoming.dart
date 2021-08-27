import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:messenger/model/message_incoming.dart';
import 'package:messenger/widget/chat_message.dart';

const String _server = "Server";

class IncomingChatMessage extends StatelessWidget implements ChatMessage {
  final IncomingMessage message;
  final AnimationController animationController;

  IncomingChatMessage(
      {required this.message, required this.animationController})
      : super(key: Key(message.id ?? ""));

  @override
  Widget build(BuildContext context) {
    return Text(message.message);
  }
}
