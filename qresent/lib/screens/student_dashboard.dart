import 'package:flutter/material.dart';
import 'student_settings.dart';
import 'student_profile.dart';


class StudentDashboard extends StatefulWidget {
  const StudentDashboard({Key? key}) : super(key: key);

  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;

  void _onItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _widgetOptions = <Widget>[
    // TO DO SCAN QR CODE HERE
      const Text("Here should be the QR scan"),

    // SETTINGS
      Settings(),

    // PROFILE
      Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        title: const Text('Home Page'),
      ),*/
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        // Incearca sa pastrezi culoarea
        // type: BottomNavigationBarType.shifting,
        mouseCursor: SystemMouseCursors.grab,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        selectedFontSize: 20,
        selectedIconTheme: const IconThemeData(color: Colors.amberAccent, size: 40),
        selectedItemColor: Colors.amberAccent,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'SETTINGS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'PROFILE',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTap,
      ),
    );
  }
}
