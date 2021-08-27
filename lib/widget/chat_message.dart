import 'package:flutter/material.dart';

import 'package:messenger/model/message.dart';

abstract class ChatMessage extends Widget {
  Message get message;

  AnimationController get animationController;
}
