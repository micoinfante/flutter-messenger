import 'package:messenger/model/message.dart';
import 'package:messenger/model/message_incoming.dart';

class MessageNewCreatedEvent {
  final IncomingMessage message;

  MessageNewCreatedEvent({required this.message});
}

class MessageSentEvent {
  final Message message;

  MessageSentEvent({required this.message});
}

class MessageSendFailedEvent {
  final String id;
  final String error;

  MessageSendFailedEvent({required this.id, required this.error});
}

class MessageReceivedEvent {
  // todo change data type to Message
  final String message;

  MessageReceivedEvent({required this.message});
}

class MessageReceiveFailedEvent {
  final String error;

  MessageReceiveFailedEvent({required this.error});
}
