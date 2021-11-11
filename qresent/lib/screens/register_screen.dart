import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

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
                                return 'Please Enter Student\'s First Name';
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
                                return 'Please Enter Student\'s Last Name';
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
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.vpn_key),
                              contentPadding:
                                  const EdgeInsets.fromLTRB(20, 15, 20, 15),
                              hintText: "Confirm Password",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (input) {
                              if (input!.isEmpty) {
                                return 'Please Confirm Your Password';
                              }
                            },
                            onSaved: (input) =>
                                passwordController.text = input!,
                            obscureText: true,
                          ),
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
                      onPressed: () {},
                      padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                      minWidth: 300,
                      child: const Text(
                        "SignUp",
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
}
