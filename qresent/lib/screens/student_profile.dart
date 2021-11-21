import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:cloud_firestore/cloud_firestore.dart';

String emailUser = '-';
String firstNameUser = '-';
String lastNameUser = '-';
String uidUser = '-';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _Profile createState() => _Profile();
}

class _Profile extends State<Profile> {
  final FirebaseAuth auth = FirebaseAuth.instance;

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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('Profile')),
      body: _body(context),
    );
  }

  _body(BuildContext context) =>
      ListView(physics: BouncingScrollPhysics(), children: <Widget>[
        Container(
            padding: EdgeInsets.all(15),
            child: Column(children: <Widget>[_headerSignUp(), _formUI()]))
      ]);
  _headerSignUp() => Column(children: <Widget>[
        Container(
            height: 80, child: Icon(Icons.supervised_user_circle, size: 90)),
        const SizedBox(height: 12.0),
        Text(firstNameUser + " " + lastNameUser,
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20.0,
                color: Colors.blue)),
      ]);
  _formUI() {
    return new Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 40.0),
          _email(),
          SizedBox(height: 12.0),
          _UID(),
        ],
      ),
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

  _UID() {
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
}
