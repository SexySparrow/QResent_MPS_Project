import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qresent/screens/register_screen.dart';
import 'package:qresent/screens/courses_screen.dart';
import 'package:qresent/screens/edit_screen.dart';
import 'login_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _auth = FirebaseAuth.instance;

  Future<void> signOut() async {
    await _auth.signOut().then((result) {
      Fluttertoast.showToast(msg: "Signed Out");
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()));
    }).catchError((e) {
      Fluttertoast.showToast(msg: e!.message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Dashboard",
        ),
        actions: [
          IconButton(
            onPressed: () {
              signOut();
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(
                top: 10,
                bottom: 10,
              ),
              width: 200,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue[500]!.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: MaterialButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const RegisterScreen()));
                },
                child: const Text(
                  "Register User",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                top: 10,
                bottom: 10,
              ),
              width: 300,
              height: 1,
              color: Colors.grey[300],
            ),
            Container(
              margin: const EdgeInsets.only(
                top: 10,
                bottom: 10,
              ),
              width: 200,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue[500]!.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: MaterialButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const EditScreen()));
                },
                child: const Text(
                  "Edit User",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                top: 10,
                bottom: 10,
              ),
              width: 300,
              height: 1,
              color: Colors.grey[300],
            ),
            Container(
              margin: const EdgeInsets.only(
                top: 10,
                bottom: 10,
              ),
              width: 200,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue[500]!.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: MaterialButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const CoursesScreen()));
                },
                child: const Text(
                  "Courses",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
