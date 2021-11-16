import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qresent/model/course_model.dart';
import 'package:qresent/model/user_model.dart';

class TeacherCourses extends StatefulWidget {
  const TeacherCourses({Key? key}) : super(key: key);

  @override
  _TeacherCoursesState createState() => _TeacherCoursesState();
}

class _TeacherCoursesState extends State<TeacherCourses> {
  final CollectionReference coursesRef =
      FirebaseFirestore.instance.collection("Courses");
  final CollectionReference teachersRef =
      FirebaseFirestore.instance.collection("Users");

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _courseNameController = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;
  List<CourseModel> _coursesList = [];
  List<CourseModel> _resultsList = [];

  @override
  void initState() {
    getCourses();
    _searchController.addListener(_onSearchChanged);
    super.initState();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  getCourses() async {
    List<CourseModel> courseListTemp = [];
    UserModel teacher = UserModel();
    await teachersRef
        .where("Email", isEqualTo: user?.email)
        .get()
        .then((QuerySnapshot snapshot) {
      for (var documentSnapshot in snapshot.docs) {
        teacher = UserModel.fromMap(documentSnapshot.data());
      }
    });
    if (teacher != null) {
      await coursesRef
          .where("UID", whereIn: teacher.assignedCourses)
          .get()
          .then((QuerySnapshot snapshot) {
        for (var documentSnapshot in snapshot.docs) {
          courseListTemp.add(CourseModel.fromMap(documentSnapshot.data()));
        }
      });
    }

    setState(() {
      _coursesList = courseListTemp;
    });
    searchResultList();
  }

  searchResultList() {
    List<CourseModel> showResults = [];

    if (_searchController.text != "") {
      for (var doc in _coursesList) {
        var courseName = doc.uid.toLowerCase();

        if (courseName.contains(_searchController.text.toLowerCase())) {
          showResults.add(doc);
        }
      }
    } else {
      showResults = List.from(_coursesList);
    }

    setState(() {
      _resultsList = showResults;
    });
  }

  _onSearchChanged() {
    searchResultList();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            "Courses",
          ),
        ),
        body: Center(
          child: Container(
            width: 500,
            padding: const EdgeInsets.only(
              left: 10,
              right: 10,
              top: 10,
            ),
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search a course',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(35)),
                      ),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: _resultsList.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Text(_resultsList[index].uid),
                          ),
                        );
                      }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
