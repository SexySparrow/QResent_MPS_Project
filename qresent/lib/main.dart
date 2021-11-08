import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_dashboard.dart';
import 'model/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

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

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "QResent",
        ),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
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
                    'assets/images/img_login.png',
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
                          return 'Please enter an email';
                        }

                        if (!RegExp("^[a-zA-Z0-9++.-]+@[a-zA-Z0-9.-]+.[a-z].")
                            .hasMatch(input)) {
                          return 'Please enter a valid email';
                        }

                        return null;
                      },
                      textInputAction: TextInputAction.next,
                      onSaved: (input) => emailController.text = input!,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 30.0,
                      left: 50.0,
                      right: 50.0,
                    ),
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
                          return 'Please Enter Your Password';
                        }
                      },
                      onSaved: (input) => passwordController.text = input!,
                      obscureText: true,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                //TODO FORGOT PASSWORD SCREEN GOES HERE
              },
              child: const Text(
                'Forgot Password',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 15,
                ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<void> signIn(String email, String password) async {
    final formState = _formKey.currentState;

    if (formState!.validate()) {
      formState.save();
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
                // De schimbat StudentDashboard cu clasa TeacherDashboard cand aceasta o sa fie creata
                MaterialPageRoute(
                    builder: (context) => const StudentDashboard()));
            Fluttertoast.showToast(msg: "Login Successful");
          } else if (currentUser.accessLevel == '2') {
            Navigator.of(context).pushReplacement(
                // De schimbat StudentDashboard cu clasa AdminDashboard cand aceasta o sa fie creata
                MaterialPageRoute(
                    builder: (context) => const StudentDashboard()));
            Fluttertoast.showToast(msg: "Login Successful");
          }
        });
      }).catchError((e) {
        Fluttertoast.showToast(msg: e!.message);
      });
    }
  }
}
