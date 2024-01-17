import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
//import 'package:proyecto_flutter/api/models/room_model.dart';
import 'package:proyecto_flutter/api/services/room_service.dart';
import 'package:proyecto_flutter/api/services/user_service.dart';
import 'package:proyecto_flutter/api/utils/http_api.dart';
import 'package:proyecto_flutter/screens/individual_chat.dart';
import 'package:proyecto_flutter/utils/constants.dart';
import 'package:proyecto_flutter/widget/nav_bar.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Map<String, dynamic> userData = {};
  Map<String, dynamic> roomData = {};
  List<Map<String, dynamic>> usersWithRoomIds = [];
  List<Map<String, dynamic>> usersDataList =
      []; // List to store userData2 for each user
  String _errorMessage = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // obtenerDatosUsuario();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    try {
      await obtenerDatosUsuario();
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> obtenerDatosUsuario() async {
    ApiResponse response = await UserService.getUserById();
    setState(() {
      userData = response.data;
    });
    await obtenerRooms(userData['_id']);
    // Reset usersDataList for each call
    usersDataList = [];
    for (var user in usersWithRoomIds) {
      await _obtenerDatosUsuario2(user['userId']);
    }
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
      Map<String, dynamic> userData2 =
          response.data; // Separate userData2 for each user
      usersDataList.add(userData2);
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 3),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: screenHeight * 0.02),
            ChatText(),
            SizedBox(height: screenHeight * 0.01),
            Divider(color: Theme.of(context).colorScheme.onPrimary),
            _isLoading
                ? CircularProgressIndicator()
                : usersWithRoomIds.isEmpty
                    ? Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Lottie.asset(
                              'assets/json/desierto3.json',
                              width: screenWidth * 0.8, // Responsive width
                              height: screenHeight * 0.4, // Responsive height
                            ),
                          ],
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: usersWithRoomIds.length,
                          itemBuilder: (BuildContext context, int index) {
                            if (index < usersDataList.length) {
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
                                  leading: CircleAvatar(
                                    backgroundImage: usersDataList[index]['profileImage'] != null
                                        ? NetworkImage(usersDataList[index]['profileImage']!)
                                        : AssetImage('assets/images/profile.png') as ImageProvider<Object>,
                                    maxRadius: screenWidth * 0.07, // Responsive radius
                                  ),
                                  title: Text(
                                    '${usersDataList[index]['username']}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenWidth * 0.04, // Responsive font size
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Sala ID: ${usersWithRoomIds[index]['roomId']}',
                                    style: TextStyle(
                                      color: Theme.of(context).shadowColor,
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return SizedBox.shrink();
                            }
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}

class ChatText extends StatelessWidget {
  const ChatText({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return FadeInDown(
      delay: Duration(milliseconds: 125),
      child: Container(
        margin: EdgeInsets.only(top: 10, left: screenWidth * 0.05),
        width: screenWidth * 0.8,
        child: Text(
          "Chat",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.05,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}

