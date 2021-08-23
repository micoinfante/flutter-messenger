import 'dart:isolate';
import 'dart:io';
import 'package:grpc/grpc.dart';

import 'package:messenger/blocs/message_event.dart';
import 'package:messenger/model/message_outgoing.dart';

import 'v1/chat.pbgrpc.dart' as grpc;
import 'v1/google/protobuf/empty.pb.dart';
import 'v1/google/protobuf/wrappers.pb.dart';

const serverIP = "127.0.0.1";
const serverPort = 3000;

class ChatService {
  late Isolate _isolateSending;
  late SendPort _portSending;
  ReceivePort _portSendStatus;
  late Isolate _isolateReceiving;
  ReceivePort _portReceiving;

  final void Function(MessageSentEvent event) onMessageSent;
  final void Function(MessageSendFailedEvent event) onMessageSendFailed;
  final void Function(MessageReceivedEvent event) onMessageReceived;
  final void Function(MessageReceiveFailedEvent event) onMessageReceivedFailed;

  ChatService(
      {required this.onMessageSent,
      required this.onMessageSendFailed,
      required this.onMessageReceivedFailed,
      required this.onMessageReceived})
      : _portSendStatus = ReceivePort(),
        _portReceiving = ReceivePort();

  void start() {
    _startSending();
    _startReceiving();
  }

  void _startSending() async {
    _isolateSending =
        await Isolate.spawn(_sendingIsolate, _portSendStatus.sendPort);

    await for (var event in _portSendStatus) {
      if (event is SendPort) {
        _portSending = event;
      } else if (event is MessageSentEvent) {
        if (onMessageSent != null) {
          onMessageSent(event);
        }
      } else if (event is MessageSendFailedEvent) {
        if (onMessageSendFailed != null) {
          onMessageSendFailed(event);
        }
      } else {
        assert(false, 'Unknown event type ${event.runtimeType}');
      }
    }
  }

  static void _sendingIsolate(SendPort portSendStatus) async {
    ReceivePort portSendMessages = ReceivePort();
    ClientChannel? client;

    portSendStatus.send(portSendMessages.sendPort);

    await for (OutgoingMessage message in portSendMessages) {
      var sent = false;
      do {
        client ??= ClientChannel(serverIP,
            port: serverPort,
            options: ChannelOptions(
                credentials: ChannelCredentials.insecure(),
                idleTimeout: Duration(seconds: 1)));

        try {
          var request = StringValue.create();
          request.value = message.message;
          await grpc.ChatServiceClient(client).send(request);
          portSendStatus.send(MessageSentEvent(message: message));
          sent = true;
        } catch (e) {
          portSendStatus.send(MessageSendFailedEvent(
              id: message.id.toString(), error: e.toString()));
          client.shutdown();
          client = null;
        }
        if (!sent) {
          sleep(Duration(seconds: 5));
        }
      } while (!sent);
    }
  }

  void _startReceiving() async {
    // start thread to receive messages
    _isolateReceiving =
        await Isolate.spawn(_receivingIsolate, _portReceiving.sendPort);

    // listen for incoming messages
    await for (var event in _portReceiving) {
      if (event is MessageReceivedEvent) {
        if (onMessageReceived != null) {
          onMessageReceived(event);
        }
      } else if (event is MessageReceiveFailedEvent) {
        if (onMessageReceivedFailed != null) {
          onMessageReceivedFailed(event);
        }
      }
    }
  }

  static void _receivingIsolate(SendPort portReceive) async {
    ClientChannel? client;

    do {
      client ??= ClientChannel(serverIP,
          port: serverPort,
          options: ChannelOptions(
              credentials: ChannelCredentials.insecure(),
              idleTimeout: Duration(seconds: 1)));

      var stream = grpc.ChatServiceClient(client).subscribe(Empty.create());

      try {
        await for (var message in stream) {
          portReceive.send(MessageReceivedEvent(message: message.text));
        }
      } catch (e) {
        portReceive.send(MessageReceiveFailedEvent(error: e.toString()));
        client.shutdown();
        client = null;
      }
      sleep(Duration(seconds: 5));
    } while (true);
  }

  void shutdown() {
    _isolateSending.kill(priority: Isolate.immediate);
    // _isolateSending = null;
    _portSendStatus.close();
    // _portSendStatus = null;

    _isolateReceiving.kill(priority: Isolate.immediate);
    // _isolateReceving = null;
    _portReceiving.close();
  }

  void send(OutgoingMessage message) {
    assert(_portSending != null, "Port is null");
    _portSending.send(message);
  }
}
