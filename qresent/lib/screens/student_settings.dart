import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'login_screen.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _Settings createState() => _Settings();
}

class _Settings extends State<Settings> {
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
      appBar: AppBar(centerTitle: true, title: const Text('Settings')),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        height: 80,
        width: 100,
        child: FloatingActionButton(
          onPressed: () {
            signOut();
          },
          child: const Text(
            'SignOut',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
