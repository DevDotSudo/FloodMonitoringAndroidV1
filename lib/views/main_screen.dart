import 'package:flood_monitoring_android/views/screens/home_page.dart';
import 'package:flood_monitoring_android/views/screens/profile_screen.dart';
import 'package:flood_monitoring_android/views/screens/weather_screen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    HomePage(), 
    WeatherPage(), 
    ProfilePage(), 
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Flood Monitoring', 
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.w600,
            fontSize: 22,
            ),
          ),
        backgroundColor: Color(0xFF3F51B5), 
        ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud), // Weather icon
            label: 'Weather',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF7B91FF),
        unselectedItemColor: const Color.fromARGB(255, 255, 255, 255), 
        onTap: _onItemTapped,
        backgroundColor:  Color(0xFF3F51B5),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
