import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ryze/shared/component/my_tab_bar.dart';

class HomeChat extends StatefulWidget {
  const HomeChat({Key? key}) : super(key: key);

  @override
  _HomeChatState createState() => _HomeChatState();
}

class _HomeChatState extends State<HomeChat> with TickerProviderStateMixin {
  late TabController tabController;
  int currentTabIndex = 0;

  void onTabChange() {
    setState(() {
      currentTabIndex = tabController.index;
    });
  }

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);

    super.initState();
  }

  @override
  void dispose() {
    tabController.addListener(() {
      onTabChange();
    });

    tabController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.white,
        ),
        centerTitle: true,
        title: Text(
          'Ryze Chat',
          style: GoogleFonts.grandHotel(
            fontSize: 36,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {},
            color: Colors.white,
          )
        ],
        elevation: 0,
      ),
      backgroundColor: Colors.blueGrey,
      body: const ChatTabBar(),
    );
  }
}
