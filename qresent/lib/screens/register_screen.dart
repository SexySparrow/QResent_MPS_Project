import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qresent/model/user_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _auth = FirebaseAuth.instance;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String? dropdownValue;
  List listItem = ["Student", "Teacher"];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "Register",
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 30.0,
                          left: 50.0,
                          right: 50.0,
                        ),
                        child: SizedBox(
                          width: 300,
                          child: TextFormField(
                            controller: firstNameController,
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.account_circle),
                              contentPadding:
                                  const EdgeInsets.fromLTRB(20, 15, 20, 15),
                              hintText: "First Name",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (input) {
                              if (input!.isEmpty) {
                                return 'Please enter First Name';
                              }
                            },
                            textInputAction: TextInputAction.next,
                            onSaved: (input) =>
                                firstNameController.text = input!,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 30.0,
                          left: 50.0,
                          right: 50.0,
                        ),
                        child: SizedBox(
                          width: 300,
                          child: TextFormField(
                            controller: lastNameController,
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.account_circle),
                              contentPadding:
                                  const EdgeInsets.fromLTRB(20, 15, 20, 15),
                              hintText: "Last Name",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (input) {
                              if (input!.isEmpty) {
                                return 'Please enter Last Name';
                              }
                            },
                            textInputAction: TextInputAction.next,
                            onSaved: (input) =>
                                lastNameController.text = input!,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 30.0,
                          left: 50.0,
                          right: 50.0,
                        ),
                        child: SizedBox(
                          width: 300,
                          child: TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.mail),
                              contentPadding:
                                  const EdgeInsets.fromLTRB(20, 15, 20, 15),
                              hintText: "Email",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (input) {
                              if (input!.isEmpty) {
                                return 'Please enter an email';
                              }

                              if (!RegExp(
                                      "^[a-zA-Z0-9++.-]+@[a-zA-Z0-9.-]+.[a-z].")
                                  .hasMatch(input)) {
                                return 'Please enter a valid email';
                              }
                            },
                            textInputAction: TextInputAction.next,
                            onSaved: (input) => emailController.text = input!,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 30.0,
                          left: 50.0,
                          right: 50.0,
                        ),
                        child: SizedBox(
                          width: 300,
                          child: TextFormField(
                            controller: passwordController,
                            textInputAction: TextInputAction.next,
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
                                return 'Please Enter Password';
                              }
                              if (input.length < 6) {
                                return ("Password should be min. 6 characters long");
                              }
                            },
                            onSaved: (input) =>
                                passwordController.text = input!,
                            obscureText: true,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 30.0,
                          left: 50.0,
                          right: 50.0,
                        ),
                        child: SizedBox(
                          width: 300,
                          child: TextFormField(
                            controller: confirmPasswordController,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.vpn_key),
                              contentPadding:
                                  const EdgeInsets.fromLTRB(20, 15, 20, 15),
                              hintText: 'Confirm Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (input) {
                              if (input!.isEmpty &&
                                  passwordController.text != "") {
                                return 'Please Confirm Your Password';
                              }
                              if (passwordController.text.length >= 6 &&
                                  passwordController.text != input) {
                                return 'Password dont\'t match';
                              }
                            },
                            onSaved: (input) =>
                                passwordController.text = input!,
                            obscureText: true,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 30.0,
                          left: 50.0,
                          right: 50.0,
                        ),
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(
                              left: 16,
                              top: 10,
                              bottom: 10,
                            ),
                            prefixIcon:
                                const Icon(Icons.supervised_user_circle),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          hint: const Text("Select User Type"),
                          value: dropdownValue,
                          icon: const Icon(Icons.arrow_drop_down),
                          iconSize: 30,
                          elevation: 16,
                          isExpanded: true,
                          validator: (input) {
                            if (input == null) {
                              return 'Please Select a User Type';
                            }
                          },
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                          onChanged: (newValue) {
                            setState(() {
                              dropdownValue = newValue!;
                            });
                          },
                          items: listItem.map((value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 30.0,
                    left: 50.0,
                    right: 50.0,
                  ),
                  child: Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.blueAccent,
                    child: MaterialButton(
                      onPressed: () {
                        signUp(emailController.text, passwordController.text);
                      },
                      padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                      minWidth: 300,
                      child: const Text(
                        "Register User",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void signUp(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) => postDetailsToFirestore())
          .catchError((e) {
        Fluttertoast.showToast(msg: e!.message);
      });
    }
  }

  postDetailsToFirestore() async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;

    UserModel userModel = UserModel();

    userModel.email = user!.email;
    userModel.firstName = firstNameController.text;
    userModel.lastName = lastNameController.text;
    if (dropdownValue == 'Student') {
      userModel.accessLevel = '0';
    } else if (dropdownValue == 'Teacher') {
      userModel.accessLevel = '1';
    }

    await firebaseFirestore
        .collection("Users")
        .doc(user.uid)
        .set(userModel.toMap());
    Fluttertoast.showToast(msg: "Account created successfully");

    Navigator.pop(context);
  }
}
