import 'package:messenger/blocs/bloc_provider.dart';
import 'package:messenger/blocs/message_event.dart';
import 'package:messenger/model/message.dart';
import 'package:messenger/model/message_incoming.dart';
import 'package:messenger/model/message_outgoing.dart';
import 'package:messenger/model/user.dart';

import 'package:rxdart/rxdart.dart';
import 'dart:collection';

class ApplicationBloc implements BlocBase {
  final _messages = Set<Message>();

  // handle notifying new created message
  final _messageCreatedController =
      new BehaviorSubject<MessageNewCreatedEvent>();
  Sink<MessageNewCreatedEvent> get inNewMessageCreated =>
      _messageCreatedController.sink;

  // message sender to server
  final _messageSendController = new BehaviorSubject<MessageNewCreatedEvent>();
  Sink<MessageNewCreatedEvent> get inMessageSend => _messageSendController.sink;
  Stream<MessageNewCreatedEvent> get outMessageSend =>
      _messageSendController.stream;

  // notify sent message to the server
  final _messageSentController = new BehaviorSubject<MessageSentEvent>();
  Sink<MessageSentEvent> get inMessageSent => _messageSentController.sink;

  // notify failed message
  final _messageSendFailedController =
      new BehaviorSubject<MessageSendFailedEvent>();
  Sink<MessageSendFailedEvent> get inMessageSendFailed =>
      _messageSendFailedController.sink;

  final _messageReceivedController =
      new BehaviorSubject<MessageReceivedEvent>();
  Sink<MessageReceivedEvent> get inMessageReceived =>
      _messageReceivedController.sink;

  final _messagesController = new BehaviorSubject<List<Message>>.seeded([]);
  Sink<List<Message>> get _inMessages => _messagesController.sink;
  Stream<List<Message>> get outMessages => _messagesController.stream;

  ApplicationBloc() {
    _messageCreatedController.listen(_onNewMessageCreated);
    _messageSentController.listen(_onMessageSent);
    _messageSendFailedController.listen(_onMessageSendFailed);
    _messageReceivedController.listen(_onMessageReceived);
  }

  @override
  void dispose() {
    _messageCreatedController.close();
    _messageSendController.close();
    _messageSentController.close();
    _messageSendFailedController.close();
    _messageReceivedController.close();
    _messagesController.close();
  }

  void _notify() {
    _inMessages.add(UnmodifiableListView(_messages));
  }

  void _onNewMessageCreated(MessageNewCreatedEvent event) {
    _messages.add(event.message);
    _notify();
    _messageSendController.add(event);
  }

  void _onMessageSent(MessageSentEvent event) {
    _findOutgoingMessage(event.message.id.toString()).status =
        OutgoingMessageStatus.SENT;
    _notify();
  }

  void _onMessageSendFailed(MessageSendFailedEvent event) {
    _findOutgoingMessage(event.id).status = OutgoingMessageStatus.FAILED;
    _notify();
  }

  void _onMessageReceived(MessageReceivedEvent event) {
    final user = User(id: 0, name: "Test", photoURL: "");
    _messages.add(IncomingMessage(
        sender: user,
        message: event.message,
        time: DateTime.now().toString(),
        isLiked: false,
        unread: false));
    _notify();
  }

  OutgoingMessage _findOutgoingMessage(String id) {
    var message = _messages.firstWhere((message) => message.id == id);
    assert(message != null,
        'Sent message with id="$id" is not found in the state');
    assert(message is OutgoingMessage,
        'Invalid message (id="$id") type ${message.runtimeType}; must be OutgoingMessage');
    return message as OutgoingMessage;
  }
}
