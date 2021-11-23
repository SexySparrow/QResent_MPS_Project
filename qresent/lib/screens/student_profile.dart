import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qresent/screens/login_screen.dart';

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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController groupController = TextEditingController();

  @override
  void initState() {
    getUsers();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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

  getUsers() async {
    final User? user = _auth.currentUser;

    DocumentSnapshot userData = await FirebaseFirestore.instance
        .collection("Users")
        .doc(user?.uid)
        .get();

    setState(() {
      emailUser = userData["Email"];
      firstNameUser = userData["FirstName"];
      lastNameUser = userData["LastName"];
      uidUser = userData["UID"];
      groupUser = userData["Group"];
      groupController.text = groupUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.edit),
        onPressed: () {
          changeCourse();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: _body(context),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () {
              signOut();
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
    );
  }

  _body(BuildContext context) => ListView(
        physics: const BouncingScrollPhysics(),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: <Widget>[
                _headerSignUp(),
                _formUI(),
              ],
            ),
          ),
        ],
      );

  _headerSignUp() => Column(
        children: <Widget>[
          const SizedBox(
            height: 80,
            child: Icon(
              Icons.account_circle,
              color: Colors.blueAccent,
              size: 90,
            ),
          ),
          const SizedBox(
            height: 12.0,
          ),
          Text(
            firstNameUser + " " + lastNameUser,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20.0,
              color: Colors.blueAccent,
            ),
          ),
        ],
      );

  _formUI() {
    return SizedBox(
      width: 400,
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 40.0),
            _email(),
            const SizedBox(height: 40.0),
            _emailUser(),
            const SizedBox(height: 40.0),
            _groupUser(),
            const SizedBox(height: 12.0),
          ],
        ),
      ),
    );
  }

  _email() {
    return Row(children: <Widget>[
      _prefixIcon(Icons.email),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Email',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15.0,
              color: Colors.grey,
            ),
          ),
          const SizedBox(
            height: 1,
          ),
          Text(emailUser)
        ],
      )
    ]);
  }

  _emailUser() {
    return Row(
      children: <Widget>[
        _prefixIcon(Icons.email_outlined),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Institution Email',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15.0,
                  color: Colors.grey),
            ),
            const SizedBox(height: 1),
            Text(
                firstNameUser.toLowerCase() + "." + lastNameUser.toLowerCase()),
          ],
        )
      ],
    );
  }

  _groupUser() {
    return Row(
      children: <Widget>[
        _prefixIcon(Icons.group),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Group',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15.0,
                  color: Colors.grey),
            ),
            const SizedBox(
              height: 1,
            ),
            Text(groupUser)
          ],
        )
      ],
    );
  }

  _prefixIcon(IconData iconData) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 48.0,
        minHeight: 48.0,
      ),
      child: Container(
        padding: const EdgeInsets.only(
          top: 16.0,
          bottom: 16.0,
        ),
        margin: const EdgeInsets.only(
          right: 8.0,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30.0),
            bottomLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
            bottomRight: Radius.circular(10.0),
          ),
        ),
        child: Icon(
          iconData,
          size: 20,
          color: Colors.grey,
        ),
      ),
    );
  }

  changeCourse() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Change group",
          textAlign: TextAlign.center,
        ),
        content: TextField(
          controller: groupController,
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton(
                child: const Text(
                  "Save",
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                onPressed: () {
                  setState(
                    () {
                      groupUser = groupController.text;
                      changePermanent();
                    },
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  changePermanent() async {
    final User? user = _auth.currentUser;

    FirebaseFirestore.instance
        .collection("Users")
        .doc(user?.uid)
        .update({"Group": groupUser});
  }
}
