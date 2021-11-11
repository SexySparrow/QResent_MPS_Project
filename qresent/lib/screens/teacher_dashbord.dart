import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'login_screen.dart';
import 'generate_qr.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({Key? key}) : super(key: key);

  @override
  _TeacherDashboardState createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
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

  Future<void> generateQR() async {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => GenerateQRPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Teacher Dashboard'),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: TextButton(
                onPressed: () {
                  signOut();
                },
                child: const Text(
                  'SIGN OUT',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 25,
                  ),
                )),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: TextButton(
                onPressed: () {
                  generateQR();
                },
                child: const Text(
                  'GENERATE NEW QR CODE',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 25,
                  ),
                )),
          ),
        ],
      )),
    );
  }
}
