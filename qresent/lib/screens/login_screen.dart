import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qresent/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:qresent/screens/teacher_dashboard.dart';
import 'student_dashboard.dart';
import 'admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "QResent",
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                top: 60.0,
                bottom: 30.0,
              ),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    "assets/images/img_login.png",
                    height: 200,
                    width: 200,
                  ),
                ),
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 30.0,
                      bottom: 30.0,
                      left: 50.0,
                      right: 50.0,
                    ),
                    child: SizedBox(
                      width: 300,
                      child: TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email),
                          contentPadding:
                              const EdgeInsets.fromLTRB(20, 15, 20, 15),
                          hintText: "Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (input) {
                          if (input!.isEmpty) {
                            return "Please enter an email";
                          }

                          if (!RegExp("^[a-zA-Z0-9++.-]+@[a-zA-Z0-9.-]+.[a-z].")
                              .hasMatch(input)) {
                            return "Please enter a valid email";
                          }
                        },
                        textInputAction: TextInputAction.next,
                        onSaved: (input) => emailController.text = input!,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 30.0,
                      left: 50.0,
                      right: 50.0,
                    ),
                    child: SizedBox(
                      width: 300,
                      child: TextFormField(
                        controller: passwordController,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.vpn_key),
                          contentPadding:
                              const EdgeInsets.fromLTRB(20, 15, 20, 15),
                          hintText: "Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (input) {
                          if (input!.isEmpty) {
                            return "Please Enter Your Password";
                          }
                        },
                        onSaved: (input) => passwordController.text = input!,
                        obscureText: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Material(
              elevation: 5,
              borderRadius: BorderRadius.circular(30),
              color: Colors.blueAccent,
              child: MaterialButton(
                onPressed: () {
                  signIn(emailController.text, passwordController.text);
                },
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                minWidth: 300,
                child: const Text(
                  "Login",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
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

  Future<void> signIn(String email, String password) async {
    final formState = _formKey.currentState;

    if (formState!.validate()) {
      formState.save();

      try {
        await _auth
            .signInWithEmailAndPassword(email: email, password: password)
            .then((uid) {
          User? user = FirebaseAuth.instance.currentUser;
          UserModel currentUser = UserModel();

          FirebaseFirestore.instance
              .collection("Users")
              .doc(user!.uid)
              .get()
              .then((DocumentSnapshot ds) {
            currentUser = UserModel.fromMap(ds.data());

            if (currentUser.accessLevel == '0') {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const StudentDashboard()));
              Fluttertoast.showToast(msg: "Login Successful");
            } else if (currentUser.accessLevel == '1') {
              Navigator.of(context).pushReplacement(
                  // To change StudentDashboard with TeacherDashboard when this one will be created
                  MaterialPageRoute(
                      builder: (context) => const TeacherDashboard()));
              Fluttertoast.showToast(msg: "Login Successful");
            } else if (currentUser.accessLevel == '2') {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const AdminDashboard()));
              Fluttertoast.showToast(msg: "Login Successful");
            }
          });
        });
      } on FirebaseAuthException catch (error) {
        switch (error.code) {
          case "invalid-email":
            errorMessage = "Your email address appears to be malformed.";
            break;
          case "wrong-password":
            errorMessage = "Your password is wrong.";
            break;
          case "user-not-found":
            errorMessage = "User with this email doesn't exist.";
            break;
          case "user-disabled":
            errorMessage = "User with this email has been disabled.";
            break;
          case "too-many-requests":
            errorMessage = "Too many requests";
            break;
          case "operation-not-allowed":
            errorMessage = "Signing in with Email and Password is not enabled.";
            break;

          default:
            errorMessage = "An undefined Error happened.";
        }
        Fluttertoast.showToast(msg: errorMessage!);
      }
    }
  }
}
