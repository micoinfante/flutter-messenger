import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:messenger/model/message_incoming.dart';
import 'package:messenger/model/message_outgoing.dart';
import 'package:messenger/widget/chat_message.dart';

const String _name = "me";

class OutgoingChatMessage extends StatelessWidget implements ChatMessage {
  final OutgoingMessage message;
  final AnimationController animationController;

  OutgoingChatMessage(
      {required this.message, required this.animationController})
      : super(key: Key(message.id ?? ""));

  @override
  Widget build(BuildContext context) {
    return Text(message.message);
  }
}
