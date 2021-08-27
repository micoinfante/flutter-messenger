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

  OutgoingMessage.copy(OutgoingMessage original)
      : this.status = original.status,
        super(
            id: original.id,
            sender: original.sender,
            message: original.message,
            time: original.time,
            isLiked: original.isLiked,
            unread: original.unread);
}
