import 'package:flutter/material.dart';
//import 'package:get/get.dart';
import 'package:proyecto_flutter/screens/individual_chat.dart';
import 'package:proyecto_flutter/widget/nav_bar.dart';

class ChatPage extends StatelessWidget {
  List images = [
    "assets/chatimages/Christine.jpg",
    "assets/chatimages/Davis.jpg",
    "assets/chatimages/Johnson.jpg",
    "assets/chatimages/Jones Noa.jpg",
    "assets/chatimages/Parker Bee.jpg",
    "assets/chatimages/Smith.jpg",
  ];

  List names = [
    "Christine",
    "Davis",
    "Johnson",
    "Jones Noa",
    "Parker Bee",
    "Smith"
  ];

  List msgTiming = [
    "Mon",
    "12:20",
    "Sun",
    "22:20",
    "05:23",
    "Wed",
  ];

  List msgs = [
    "Hi, How are you?",
    "Where are you?",
    "Hello Dear, is all right",
    "Hello Dear, is all right",
    "Hello Dear, is all right",
    "Hello Dear, is all right",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 3),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(top: 20, left: 15),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: Row(
                    
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Mensajes",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          color: Colors.black54,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.search,
                          size: 35,
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Reciente",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                      letterSpacing: 1),
                ),
                SizedBox(height: 20),

SizedBox(
  height: 100,
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    shrinkWrap: true,
    itemCount: images.length,
    itemBuilder: (context, index) {
      return Padding(
        padding: const EdgeInsets.only(right: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(images[index]),
              minRadius: 30,
            ),
            SizedBox(height: 8),
            Text(
              names[index],
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      );
    },
  ),
),
                SizedBox(height: 10),
                Divider(),
                SizedBox(height: 20),
                ListView.builder(
                  itemCount: images.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => IndividualChat()));
                      },
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(55),
                        child: Image.asset(images[index],
                            height: 55, width: 55, fit: BoxFit.cover),
                      ),
                      title: Text(
                        names[index],
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                          letterSpacing: 1,
                        ),
                      ),
                      subtitle: Text(names[index]),
                      trailing: Text(msgTiming[index]),
                    );
                  },
                )


              ],
            ),
          ),
        ),
      ),
    );
  }
}
