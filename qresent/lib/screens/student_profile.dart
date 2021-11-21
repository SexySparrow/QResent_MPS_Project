import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:cloud_firestore/cloud_firestore.dart';

String emailUser = '-';
String firstNameUser = '-';
String lastNameUser = '-';
String uidUser = '-';
String groupUser = '-';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _Profile createState() => _Profile();
}

class _Profile extends State<Profile> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController groupController = TextEditingController();

  @override
  void initState() {
    getUsers();
    super.initState();
  }

  getUsers() async {
    final User? user = auth.currentUser;
    final uid = user?.uid;

    DocumentSnapshot userData =
        await FirebaseFirestore.instance.collection("Users").doc(uid).get();

    setState(() {
      emailUser = userData["Email"];
      firstNameUser = userData["FirstName"];
      lastNameUser = userData["LastName"];
      uidUser = userData["UID"];
      groupUser = userData["Group"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('Profile')),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FloatingActionButton(
                elevation: 0.0,
                mini: true,
                child: const Icon(Icons.edit, color: Colors.white),
                backgroundColor: Colors.blueAccent,
                onPressed: () {
                  changeCourse();
                })
          ],
        ),
      ),
      body: _body(context),
    );
  }

  _body(BuildContext context) =>
      ListView(physics: const BouncingScrollPhysics(), children: <Widget>[
        Container(
            padding: const EdgeInsets.all(15),
            child: Column(children: <Widget>[_headerSignUp(), _formUI()]))
      ]);
  _headerSignUp() => Column(children: <Widget>[
        const SizedBox(
            height: 80, child: Icon(Icons.supervised_user_circle, size: 90)),
        const SizedBox(height: 12.0),
        Text(firstNameUser + " " + lastNameUser,
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20.0,
                color: Colors.blue)),
      ]);
  _formUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 40.0),
        _email(),
        const SizedBox(height: 40.0),
        _emailUser(),
        const SizedBox(height: 40.0),
        _groupUser(),
        const SizedBox(height: 12.0),
        _uid(),
      ],
    );
  }

  _email() {
    return Row(children: <Widget>[
      _prefixIcon(Icons.email),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Email',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15.0,
                  color: Colors.grey)),
          const SizedBox(height: 1),
          Text(emailUser)
        ],
      )
    ]);
  }

  _emailUser() {
    return Row(children: <Widget>[
      _prefixIcon(Icons.email_outlined),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Institution Email',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15.0,
                  color: Colors.grey)),
          const SizedBox(height: 1),
          Text(firstNameUser.toLowerCase() +
              "." +
              lastNameUser.toLowerCase() +
              "@cs.com")
        ],
      )
    ]);
  }

  _groupUser() {
    return Row(children: <Widget>[
      _prefixIcon(Icons.group),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Group',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15.0,
                  color: Colors.grey)),
          const SizedBox(height: 1),
          Text(groupUser)
        ],
      )
    ]);
  }

  _uid() {
    return Row(children: <Widget>[
      _prefixIcon(Icons.adb_sharp),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('UID',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15.0,
                  color: Colors.grey)),
          const SizedBox(height: 1),
          Text(uidUser)
        ],
      )
    ]);
  }

  _prefixIcon(IconData iconData) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 48.0, minHeight: 48.0),
      child: Container(
          padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
          margin: const EdgeInsets.only(right: 8.0),
          decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  bottomLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                  bottomRight: Radius.circular(10.0))),
          child: Icon(
            iconData,
            size: 20,
            color: Colors.grey,
          )),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  changeCourse() async {
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.white70,
              title: const Text("Change group"),
              content: TextField(
                controller: groupController,
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text(
                    "Save",
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    setState(() {
                      groupUser = groupController.text;
                      changePermanent();
                    });
                    Navigator.pop(context);
                  },
                )
              ],
            ));
  }

  changePermanent() async {
    final User? user = auth.currentUser;
    final uid = user?.uid;

    FirebaseFirestore.instance
        .collection("Users")
        .doc(uid)
        .update({"Group": groupUser});
  }
}
