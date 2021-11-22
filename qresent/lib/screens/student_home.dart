import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qresent/screens/login_screen.dart';
import 'scan_qr.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  final CollectionReference coursesRef =
      FirebaseFirestore.instance.collection("Users");
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<dynamic> _courses = [];
  List<String> courses = [];
  var stringWord = '';

  @override
  void initState() {
    getCourses();
    super.initState();
  }

  Future<void> signOut() async {
    await _auth.signOut().then((result) {
      Fluttertoast.showToast(msg: "Signed Out");
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()));
    }).catchError((e) {
      Fluttertoast.showToast(msg: e!.message);
    });
  }

  getCourses() async {
    final User? user = _auth.currentUser;
    final uid = user?.uid;

    DocumentSnapshot userData =
        await FirebaseFirestore.instance.collection("Users").doc(uid).get();

    setState(() {
      _courses = userData["AssignedCourses"];
      courses = _courses.cast<String>();
      stringWord = courses.join("\n");
    });
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      primary: Colors.black,
      minimumSize: const Size(88, 44),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(2.0)),
      ),
      backgroundColor: Colors.blue,
    );
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Home"),
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
              TextButton(
                style: flatButtonStyle,
                child: const Text("Courses"),
                onPressed: () {
                  _showCourses();
                },
              ),
              TextButton(
                  style: flatButtonStyle,
                  onPressed: () {
                    _showScan();
                  },
                  child: const Text("Scan QR")),
            ],
          ),
        ));
  }

  _showScan() async {
    await showDialog(context: context, builder: (context) => const Scan());
  }

  _showCourses() async {
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.lightBlue,
              title: const Text("Courses\n"),
              actions: <Widget>[
                Text(
                  stringWord,
                  textAlign: TextAlign.left,
                )
              ],
            ));
  }
}
