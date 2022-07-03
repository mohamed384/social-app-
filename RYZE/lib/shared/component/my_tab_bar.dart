import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ryze/screens/chat/chat_page.dart';


class ChatTabBar extends StatefulWidget {
  const ChatTabBar({
     Key? key,
  }) : super(key: key);

  @override
  State<ChatTabBar> createState() => _ChatTabBarState();
}

class _ChatTabBarState extends State<ChatTabBar> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
            height: 80,
            color: Colors.blueGrey,
            child: TabBar(
              onTap: (index){
                setState(() {
                });
              },
              indicator: ShapeDecoration(
                  color: const Color(0xff1b65a8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  )),
              tabs: const [
                Tab(
                  icon: Text(
                    'Chat',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                Tab(
                  icon: Text(
                    'Call',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,

                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration:  BoxDecoration(
                  color:Get.isDarkMode?Colors.grey.shade900: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  )),
              child:  const TabBarView(
                children: [
                  ChatPage(),
                  Center(child: Text('Call')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
