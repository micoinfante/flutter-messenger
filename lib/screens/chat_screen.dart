import 'package:flutter/material.dart';
import 'package:messenger/blocs/application_bloc.dart';
import 'package:messenger/blocs/bloc_provider.dart';
import 'package:messenger/blocs/message_event.dart';
import 'package:messenger/model/message.dart';
import 'package:messenger/model/message_incoming.dart';
import 'package:messenger/model/message_outgoing.dart';
import 'package:messenger/model/user.dart';
import 'package:flutter/cupertino.dart';

import 'package:messenger/widget/chat_message.dart';
import 'package:messenger/widget/chat_message_incoming.dart';
import 'package:messenger/widget/chat_message_outgoing.dart';
import 'package:uuid/uuid.dart';

class ChatScreen extends StatefulWidget {
  final User user;

  ChatScreen({required this.user});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  late ApplicationBloc _appBloc;
  final List<ChatMessage> _messages = <ChatMessage>[];
  final TextEditingController _textEditingController = TextEditingController();
  bool _isComposing = false;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInit == false) {
      _appBloc = BlocProvider.of<ApplicationBloc>(context)!;
      _isInit = false;
    }
  }

  @override
  void dispose() {
    super.dispose();
    for (ChatMessage message in _messages) {
      message.animationController.dispose();
    }
  }

  _buildMessage(Message message, bool isMe) {
    final Container msg = Container(
        margin: isMe
            ? EdgeInsets.only(top: 8.0, bottom: 8.0, left: 80.0)
            : EdgeInsets.only(top: 8.0, bottom: 8.0),
        padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
        width: MediaQuery.of(context).size.width * 0.75,
        decoration: BoxDecoration(
          color: !isMe ? Color(0xFFFFEFEE) : Theme.of(context).accentColor,
          borderRadius: isMe
              ? BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  bottomLeft: Radius.circular(15.0),
                )
              : BorderRadius.only(
                  topRight: Radius.circular(15.0),
                  bottomRight: Radius.circular(15.0),
                ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              message.time,
              style: TextStyle(
                color: Colors.blueGrey,
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              message.message,
              style: TextStyle(
                color: Colors.blueGrey,
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ));

    if (isMe) {
      return msg;
    }

    return Row(
      children: <Widget>[
        msg,
        IconButton(
          onPressed: () {},
          icon: message.isLiked
              ? Icon(Icons.favorite)
              : Icon(Icons.favorite_border),
          iconSize: 30.0,
          color: message.isLiked
              ? Theme.of(context).primaryColor
              : Colors.blueGrey,
        )
      ],
    );
  }

  void _handleSubmitted(String text) {
    _isComposing = false;
    _appBloc.inNewMessageCreated.add(MessageNewCreatedEvent(
        message: IncomingMessage(
            id: Uuid().v1(),
            isLiked: false,
            message: text,
            sender: currentUser,
            time: DateTime.now().toString(),
            unread: true)));
    showAlertDialog(context);
  }

  void _updateMessages(List<Message> messages) {
    for (var message in messages) {
      int i = _messages.indexWhere((msg) => msg.message.id == message.id);
      if (i != -1) {
        // update existing message
        print('Got outgoing message ${message.id}}');
        if (message is OutgoingMessage) {
          var chatMessage = _messages[i];
          if (chatMessage is OutgoingChatMessage) {
            if (chatMessage.message.status != message.status) {
              chatMessage.animationController.dispose();
              _messages[i] = OutgoingChatMessage(
                  message: OutgoingMessage.copy(message),
                  animationController: AnimationController(
                    duration: Duration.zero,
                    vsync: this,
                  ));
            }
            _messages[i].animationController.forward();
          } else {
            assert(false, 'Message must be OutcomingMessage type');
          }
        }
      } else {
        late ChatMessage chatMessage;
        var animationController = AnimationController(
            vsync: this, duration: Duration(milliseconds: 700));
        if (message is OutgoingMessage) {
          chatMessage = OutgoingChatMessage(
              message: OutgoingMessage.copy(message),
              animationController: animationController);
        } else if (message is IncomingMessage) {
          chatMessage = IncomingChatMessage(
              message: IncomingMessage.copy(message),
              animationController: animationController);
        } else {
          assert(false, 'unknown message type');
        }
        _messages.insert(0, chatMessage);
        chatMessage.animationController.forward();
      }
    }
  }

  // For debugging purpose
  showAlertDialog(BuildContext context) {
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Message sent"),
      content: Text(""),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _buildMessageComposer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      height: 70.0,
      color: Colors.white,
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.photo),
            iconSize: 25.0,
            color: Theme.of(context).primaryColor,
          ),
          Expanded(
            child: TextField(
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.send,
              controller: _textEditingController,
              onChanged: (String text) {
                setState(() {
                  _isComposing = text.length > 0;
                });
              },
              onSubmitted: _isComposing ? _handleSubmitted : null,
              decoration: InputDecoration.collapsed(
                hintText: 'Send a message...',
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              if (_isComposing) {
                _handleSubmitted(_textEditingController.text);
              }
            },
            icon: Icon(Icons.send),
            iconSize: 25.0,
            color: Theme.of(context).primaryColor,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          widget.user.name,
          style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_horiz),
            iconSize: 30.0,
            color: Colors.white,
          )
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
                  ),
                  child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        topRight: Radius.circular(30.0),
                      ),
                      child: StreamBuilder<List<Message>>(
                        stream: _appBloc.outMessages,
                        builder:
                            (context, AsyncSnapshot<List<Message>> snapshot) {
                          if (snapshot.hasError) {
                            return Text("Error: ${snapshot.error}");
                          } else if (snapshot.hasData) {
                            _updateMessages(snapshot.data!);
                          }
                          return ListView.builder(
                            reverse: true,
                            padding: EdgeInsets.only(top: 15.0),
                            itemCount: _messages.length,
                            itemBuilder: (BuildContext context, int index) {
                              final message = _messages[index].message;
                              final bool isMe =
                                  message.sender.id == currentUser.id;
                              return _buildMessage(message, isMe);
                            },
                          );
                        },
                      ))),
            ),
            _buildMessageComposer(),
          ],
        ),
      ),
    );
  }
}
