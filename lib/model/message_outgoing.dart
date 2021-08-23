import 'package:messenger/model/user.dart';

import 'message.dart';

enum OutgoingMessageStatus { NEW, SENT, FAILED }

class OutgoingMessage extends Message {
  OutgoingMessageStatus status;

  OutgoingMessage(
      {String? id,
      required User sender,
      required String message,
      required String time,
      required bool isLiked,
      required bool unread,
      OutgoingMessageStatus status = OutgoingMessageStatus.NEW})
      : this.status = status,
        super(
            id: id,
            sender: sender,
            message: message,
            time: time,
            isLiked: isLiked,
            unread: unread);
}
