import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';


class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _Profile createState() => _Profile();
}

// TO DO
// EXTRACTC INFO ABOUT USER FROM FIREBASE DATABASE
// EXTRACT NAME, EMAIL
// CREATE THE PROFILE PAGE
class _Profile extends State<Profile> {
  final fullNameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String userEmail;

  /*void getCurrentUserEmail() async {
    final user = await _firebaseAuth.currentUser().then((value) => userEmail = value.email);
  }*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
    );
  }
}