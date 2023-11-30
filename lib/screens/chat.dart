import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyecto_flutter/api/models/room_model.dart';
import 'package:proyecto_flutter/api/services/room_service.dart';
import 'package:proyecto_flutter/api/services/user_service.dart';
import 'package:proyecto_flutter/api/utils/http_api.dart';
//import 'package:get/get.dart';
import 'package:proyecto_flutter/screens/individual_chat.dart';
import 'package:proyecto_flutter/widget/nav_bar.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Map<String, dynamic> userData = {};
  Map<String, dynamic> userData2 = {};
  Map<String, dynamic> roomData = {};
  List<Map<String, dynamic>> usersWithRoomIds = [];

  @override
  void initState() {
    super.initState();
    obtenerDatosUsuario();
  }

  Future<void> obtenerDatosUsuario() async {
    ApiResponse response = await UserService.getUserById();
    setState(() {
      userData = response.data;
    });
    await obtenerRooms(userData['_id']);
  }

  Future<void> obtenerRooms(String userId) async {
    ApiResponse response = await RoomService.readRoomsByUserId(userId);
    setState(() {
      roomData = response.data;
    });

    usersWithRoomIds = obtenerUsuariosConIdsDeSala(roomData, userId);
    setState(() {});
  }

  Future<void> _obtenerDatosUsuario2(String userid) async {
    ApiResponse response = await UserService.getCreadorById(userid);
    setState(() {
      userData2 = response.data;
      print(userData2);
    });
  }

  List<Map<String, dynamic>> obtenerUsuariosConIdsDeSala(
      Map<String, dynamic> roomData, String usuarioId) {
    List<Map<String, dynamic>> usersWithRoomIds = [];

    if (roomData.containsKey('rooms')) {
      List<dynamic> rooms = roomData['rooms'];

      for (var room in rooms) {
        String userId1 = room['userId1'];
        String userId2 = room['userId2'];
        String roomId = room['_id'];

        if (userId1 != usuarioId) {
          usersWithRoomIds.add({
            'userId': userId1,
            'roomId': roomId,
          });
        }

        if (userId2 != usuarioId) {
          usersWithRoomIds.add({
            'userId': userId2,
            'roomId': roomId,
          });
        }
      }
    }

    return usersWithRoomIds;
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 3),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Chat'),
          ListView.builder(
            shrinkWrap: true,
            itemCount: usersWithRoomIds.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                       Get.to(
                      IndividualChat(
                        roomId: usersWithRoomIds[index]['roomId'],
                        userId2: usersWithRoomIds[index]['userId'],
                      ),
                    );
                },
                child: ListTile(
                  title: Text('Usuario ID: ${usersWithRoomIds[index]['userId']}'),
                  subtitle: Text('Sala ID: ${usersWithRoomIds[index]['roomId']}'),
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}
}
