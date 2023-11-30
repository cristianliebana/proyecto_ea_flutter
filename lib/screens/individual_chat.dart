import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyecto_flutter/api/services/user_service.dart';
import 'package:proyecto_flutter/api/utils/http_api.dart';
import 'package:proyecto_flutter/screens/chat.dart';
import 'package:proyecto_flutter/screens/chat_message_item.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class ChatMessage {
  final bool isMeChatting;
  final String messageBody;
  

  ChatMessage({required this.isMeChatting, required this.messageBody});
}

class IndividualChat extends StatefulWidget {
  final String roomId;
  final String userId2;
  const IndividualChat({Key? key, required this.roomId, required this. userId2,req}) : super(key: key);

  @override
  _IndividualChatState createState() => _IndividualChatState();
}

class _IndividualChatState extends State<IndividualChat> {
  Map<String, dynamic> userData = {};
   Map<String, dynamic> userData2 = {};
  late io.Socket socket;
  TextEditingController messageController = TextEditingController();
  List<ChatMessage> messages = [];
  bool isDisconnected = false;

  @override
  void initState() {
    super.initState();
    iniciarChat();
  }

  Future<void> iniciarChat() async {
    await obtenerDatosUsuario();
    obtenerDatosUsuario2(widget.userId2);
    connectToSocket();
  }

  Future<void> obtenerDatosUsuario() async {
    ApiResponse response = await UserService.getUserById();
    setState(() {
      userData = response.data;
      print(userData);
    });
  }

    Future<void> obtenerDatosUsuario2(String userId2) async {
    ApiResponse response = await UserService.getCreadorById(userId2);
    setState(() {
      userData2 = response.data;
    });
  }

  void connectToSocket() {
    socket = io.io('http://localhost:9090', <String, dynamic>{
      'transports': ['websocket'],
    });

    socket.on('connect', (_) {
      print('Conectado al servidor Socket.IO');
      socket.emit('join room', {'userId': userData['_id'], 'roomId': widget.roomId});
    });

    socket.on('chat message', (data) {
      String senderId = data['userId'];
      String message = data['message'];
      bool isMe = senderId == userData['_id'];

      setState(() {
        messages.add(ChatMessage(isMeChatting: isMe, messageBody: message));
      });
    });

    socket.on('disconnect', (_) {
      if (!isDisconnected) {
        print('Desconectado del servidor Socket.IO');
        isDisconnected = true;
      }
    });
  }

  void sendMessage() {
    String message = messageController.text;
    if (message.isNotEmpty) {
      Map<String, dynamic> messageData = {
        'message': message,
        'userId': userData['_id'],
        'roomId': widget.roomId,
      };

      socket.emit('chat message', messageData);

      messageController.clear();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              height: 85,
              color: Color(0xFF486D28),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
BackButton(
  color: Color(0xFFFFFCEA),
  onPressed: () {
    Get.to(ChatPage());
  },
),
                  SizedBox(width: 5),
                  CircleAvatar(
                    backgroundImage:
                        AssetImage("assets/chatimages/Jones Noa.jpg"),
                    maxRadius: 28,
                  ),
                  SizedBox(width: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userData2['username'] ?? 'Username not available',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFFCEA),
                        ),
                      ),
  Text(
  widget.roomId,
  style: TextStyle(
    fontWeight: FontWeight.w500,
    color: Color(0xFFFFFCEA).withOpacity(0.7),
  ),
),
                    ],
                  ),
                  Spacer(),
                  IconButton(
  onPressed: () {
 
  },
  icon: Icon(
    Icons.more_vert,
    color: Color(0xFFFFFCEA), 
  ),
),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Color(0xFFFFFCEA),
                child: ListView(
                  padding: EdgeInsets.all(15),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Today",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    for (var message in messages)
                      Align(
                        alignment: message.isMeChatting
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: ChatMessageItem(
                          isMeChatting: message.isMeChatting,
                          messageBody: message.messageBody,
                        ),
                      ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
  bottomNavigationBar: Container(
    height: 70,
    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
    margin: EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Color(0xFFFFFCEA),
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: Color(0xFF486D28),width: 3.0), 
    ),
        child: Container(
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Escribe algo...",
                    hintStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF486D28),
                    ),
                  ),
                  maxLines: 10,
                  minLines: 1,
                ),
              ),
              SizedBox(width: 20),
              InkWell(
                onTap: () {
                  sendMessage();
                },
                hoverColor: Colors.white,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(0xFF486D28),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  alignment: Alignment.center,
                  child:
                      Icon(Icons.send_rounded, color: Color(0xFFFFFCEA), size: 25),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}