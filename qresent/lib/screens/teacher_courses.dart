import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  final TextEditingController _intervalController = TextEditingController();

  User? user = FirebaseAuth.instance.currentUser;
  List<CourseModel> _coursesList = [];
  List<CourseModel> _resultsList = [];
  Map<CourseModel, List<String>> intervals = {};

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
    await coursesRef
        .where("UID", whereIn: teacher.assignedCourses)
        .get()
        .then((QuerySnapshot snapshot) {
      for (var documentSnapshot in snapshot.docs) {
        courseListTemp.add(CourseModel.fromMap(documentSnapshot.data()));
      }
    });

    setState(() {
      _coursesList = courseListTemp;
    });
    for (CourseModel course in courseListTemp) {
      getIntervals(course);
    }
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

  getIntervals(CourseModel course) async {
    List<String> tempIntervals = [];
    await coursesRef
        .doc(course.uid)
        .get()
        .then((value) => tempIntervals = List.from(value.get("Intervals")));
    setState(() {
      intervals[course] = tempIntervals;
    });
  }

  void removeInterval(CourseModel course, String interval) async {
    await coursesRef.doc(course.uid).update({
      "Intervals": FieldValue.arrayRemove([interval])
    });
    getIntervals(course);
  }

  void addInterval(CourseModel course, String day, String hour) async {
    await coursesRef.doc(course.uid).update({
      "Intervals": FieldValue.arrayUnion([day + " " + hour])
    });
    getIntervals(course);
  }

  createAddAlertDialog(BuildContext context, CourseModel course) {
    String selectedValueDay = "Luni";
    String selectedValueHour = "8:00-10:00";

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Create New Interval"),
          content:
              const Text("Enter the name of the interval you want to create."),
          actions: <Widget>[
            Container(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: DropdownButtonFormField(
                          value: selectedValueDay,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedValueDay = newValue!;
                            });
                          },
                          items: dropdownItemsDays)),
                  Expanded(
                      child: DropdownButtonFormField(
                          value: selectedValueHour,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedValueHour = newValue!;
                            });
                          },
                          items: dropdownItemsHours)),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    addInterval(course, selectedValueDay, selectedValueHour);
                    Navigator.of(context).pop();
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

  createDeleteAlertDialog(
      BuildContext context, CourseModel course, String interval) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Course"),
          content:
              Text("Are you sure you want to delete the interval ${interval}?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                removeInterval(course, interval);
                Navigator.of(context).pop();
              },
              child: const Text("Yes"),
            )
          ],
        );
      },
    );
  }

  List<DropdownMenuItem<String>> get dropdownItemsDays {
    List<DropdownMenuItem<String>> days = [
      DropdownMenuItem(child: Text("Luni"), value: "Luni"),
      DropdownMenuItem(child: Text("Marti"), value: "Marti"),
      DropdownMenuItem(child: Text("Miercuri"), value: "Miercuri"),
      DropdownMenuItem(child: Text("Joi"), value: "Joi"),
      DropdownMenuItem(child: Text("Vineri"), value: "Vineri"),
    ];
    return days;
  }

  List<DropdownMenuItem<String>> get dropdownItemsHours {
    List<DropdownMenuItem<String>> hours = [
      DropdownMenuItem(child: Text("8:00-10:00"), value: "8:00-10:00"),
      DropdownMenuItem(child: Text("10:00-12:00"), value: "10:00-12:00"),
      DropdownMenuItem(child: Text("12:00-14:00"), value: "12:00-14:00"),
      DropdownMenuItem(child: Text("14:00-16:00"), value: "14:00-16:00"),
      DropdownMenuItem(child: Text("16:00-18:00"), value: "16:00-18:00"),
      DropdownMenuItem(child: Text("18:00-20:00"), value: "18:00-20:00"),
      DropdownMenuItem(child: Text("20:00-22:00"), value: "20:00-22:00"),
    ];
    return hours;
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
                            subtitle: ListView.builder(
                                physics: ClampingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount:
                                    intervals[_resultsList[index]]!.length,
                                itemBuilder: (context, intervalIndex) {
                                  return Card(
                                    child: ListTile(
                                        title: Text(
                                            intervals[_resultsList[index]]!
                                                .elementAt(intervalIndex)),
                                        trailing: IconButton(
                                            onPressed: () {
                                              createDeleteAlertDialog(
                                                  context,
                                                  _resultsList[index],
                                                  intervals[
                                                          _resultsList[index]]!
                                                      .elementAt(
                                                          intervalIndex));
                                            },
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                              size: 32,
                                            ))),
                                  );
                                }),
                            trailing: IconButton(
                                onPressed: () {
                                  createAddAlertDialog(
                                      context, _resultsList[index]);
                                },
                                alignment: Alignment.center,
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.grey,
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
      ),
    );
  }
}
