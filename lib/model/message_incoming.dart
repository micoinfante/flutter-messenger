import 'package:messenger/model/user.dart';

import 'message.dart';

class IncomingMessage extends Message {
  IncomingMessage({
    String? id,
    required User sender,
    required String message,
    required String time,
    required bool isLiked,
    required bool unread,
  }) : super(
            id: id,
            sender: sender,
            message: message,
            time: time,
            isLiked: isLiked,
            unread: unread);

  IncomingMessage.copy(IncomingMessage original)
      : super(
            id: original.id,
            sender: original.sender,
            message: original.message,
            time: original.time,
            isLiked: original.isLiked,
            unread: original.unread);
}
