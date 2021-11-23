import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qresent/model/course_model.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({Key? key}) : super(key: key);

  @override
  _CoursesScreenState createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final CollectionReference coursesRef =
      FirebaseFirestore.instance.collection("Courses");

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _courseNameController = TextEditingController();

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
    await coursesRef.get().then((QuerySnapshot snapshot) {
      for (var documentSnapshot in snapshot.docs) {
        courseListTemp.add(CourseModel.fromMap(documentSnapshot.data()));
      }
    });

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

  createDeleteAlertDialog(BuildContext context, CourseModel course) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Course"),
          content: Text("Are you sure you want to delete ${course.uid}?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                removeCourse(course);
                Navigator.of(context).pop();
              },
              child: const Text("Yes"),
            )
          ],
        );
      },
    );
  }

  createAddAlertDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Create New Course"),
          content:
              const Text("Enter the name of the course you want to create."),
          actions: <Widget>[
            Container(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: TextField(
                controller: _courseNameController,
                decoration: const InputDecoration(hintText: "Course Name"),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _courseNameController.text = "";
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    addCourse(_courseNameController.text);
                    Navigator.of(context).pop();
                    _courseNameController.text = "";
                  },
                  child: const Text("Submit"),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void removeCourse(CourseModel course) async {
    await coursesRef.doc(course.uid).delete().then((_) => {
          getCourses(),
          Fluttertoast.showToast(msg: "Course deleted successfully"),
        });
  }

  void addCourse(String courseName) async {
    CourseModel courseModel =
        CourseModel(uid: courseName, assignedProfessor: "", information: "");
    courseModel.intervals = [];

    var alreadyExists = 0;

    for (var doc in _coursesList) {
      if (doc.uid.toLowerCase() == courseName.toLowerCase()) {
        alreadyExists = 1;
        break;
      }
    }

    if (alreadyExists == 1) {
      Fluttertoast.showToast(msg: "Course already exists");
    } else {
      await coursesRef.doc(courseName).set(courseModel.toMap()).then((_) => {
            getCourses(),
            Fluttertoast.showToast(msg: "Course $courseName created"),
          });
    }
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
                          elevation: 4,
                          child: ListTile(
                            title: Text(_resultsList[index].uid),
                            subtitle: Text(
                                "Professor: ${_resultsList[index].assignedProfessor}"),
                            trailing: IconButton(
                                onPressed: () {
                                  createDeleteAlertDialog(
                                      context, _resultsList[index]);
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 32,
                                )),
                          ),
                        );
                      }),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          label: const Text("Create New Course"),
          icon: const Icon(Icons.add),
          onPressed: () {
            createAddAlertDialog(context);
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
