import 'package:findmybusdriver/Tabs/earningsTab.dart';
import 'package:findmybusdriver/Tabs/homeTab.dart';
import 'package:findmybusdriver/Tabs/profileTab.dart';
import 'package:findmybusdriver/Tabs/ratingsTab.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  static const String id = 'mainpage';
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {

  TabController tabController;
  int selecetdIndex = 0;

  void onItemClicked(int index){
    setState(() {
      selecetdIndex = index;
      tabController.index = selecetdIndex;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: tabController,
        children: <Widget>[
          HomeTab(),
          EarningsTab(),
          RatingsTab(),
          ProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            title: Text('Earnings'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            title: Text('Ratings'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text('Account'),
          ),
        ],
        currentIndex: selecetdIndex,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.amber,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        onTap: onItemClicked,
      ),
    );
  }
}