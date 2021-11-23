import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qresent/model/attendance_model.dart';
import 'package:qresent/model/course_model.dart';
import 'package:qresent/model/user_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qresent/screens/login_screen.dart';
import 'package:excel/excel.dart';

import 'generate_qr.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({Key? key}) : super(key: key);

  @override
  _TeacherDashboardState createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final _auth = FirebaseAuth.instance;
  final CollectionReference coursesRef =
      FirebaseFirestore.instance.collection("Courses");
  final CollectionReference teachersRef =
      FirebaseFirestore.instance.collection("Users");
  final CollectionReference attendancesRef =
      FirebaseFirestore.instance.collection("Attendance");

  final TextEditingController _searchController = TextEditingController();

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

  Future<void> signOut() async {
    await _auth.signOut().then((result) {
      Fluttertoast.showToast(msg: "Signed Out");
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()));
    }).catchError((e) {
      Fluttertoast.showToast(msg: e!.message);
    });
  }

  Future<void> generateQR(String course, String interval) async {
    String date = DateFormat('dd-MM-yyyy').format(DateTime.now());
    await attendancesRef.doc(course + " " + interval).get().then((value) {
      AttendanceModel attendance = AttendanceModel.fromMap(value.data());
      attendance.dates.putIfAbsent(date, () => {"present": [], "active": []});
      attendancesRef.doc(course + " " + interval).set(attendance.toMap());
    });

    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            GenerateQRPage(course: course, interval: interval)));
  }

  Future<void> exportAttendancyList(String course, String interval) async {
    await attendancesRef.doc(course + " " + interval).get().then((value) {
      AttendanceModel attendance = AttendanceModel.fromMap(value.data());
    });
  }

  getCourses() async {
    List<CourseModel> courseListTemp = [];
    UserModel teacher = UserModel();
    await teachersRef
        .where("Email", isEqualTo: user?.email)
        .get()
        .then((QuerySnapshot snapshot) {
      teacher = UserModel.fromMap(snapshot.docs[0].data());
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
    for (CourseModel course in _coursesList) {
      await getIntervals(course);
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
    await attendancesRef.doc(course.uid + " " + interval).delete();
    getIntervals(course);
  }

  void addInterval(CourseModel course, String day, String hour) async {
    await coursesRef.doc(course.uid).update({
      "Intervals": FieldValue.arrayUnion([day + " " + hour])
    });
    AttendanceModel attendance =
        AttendanceModel(dates: <String, Map<String, int>>{}, total: 0);
    await attendancesRef
        .doc(course.uid + " " + day + " " + hour)
        .set(attendance.toMap());
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
                          setState(
                            () {
                              selectedValueDay = newValue!;
                            },
                          );
                        },
                        items: dropdownItemsDays),
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                        value: selectedValueHour,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedValueHour = newValue!;
                          });
                        },
                        items: dropdownItemsHours),
                  ),
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

  createEdtiAlertDialog(BuildContext context, CourseModel course) {
    final TextEditingController _courseInformation = TextEditingController();

    setState(() {
      _courseInformation.text = course.information!;
    });

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            course.uid,
            textAlign: TextAlign.center,
          ),
          content: TextField(
            controller: _courseInformation,
            maxLines: null,
            keyboardType: TextInputType.multiline,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    addCourseInformation(_courseInformation.text, course);
                    Navigator.of(context).pop();
                  },
                  child: const Text("Save"),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  addCourseInformation(String information, CourseModel course) async {
    await coursesRef.doc(course.uid).update({"Information": information});
    getCourses();
  }

  createInfoAlertDialog(BuildContext context, CourseModel course) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            course.uid,
            textAlign: TextAlign.center,
          ),
          content: Text(course.information!),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Exit"),
                ),
              ],
            )
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
              Text("Are you sure you want to delete the interval $interval?"),
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
      const DropdownMenuItem(child: Text("Luni"), value: "Luni"),
      const DropdownMenuItem(child: Text("Marti"), value: "Marti"),
      const DropdownMenuItem(child: Text("Miercuri"), value: "Miercuri"),
      const DropdownMenuItem(child: Text("Joi"), value: "Joi"),
      const DropdownMenuItem(child: Text("Vineri"), value: "Vineri"),
    ];
    return days;
  }

  List<DropdownMenuItem<String>> get dropdownItemsHours {
    List<DropdownMenuItem<String>> hours = [
      const DropdownMenuItem(child: Text("8:00-10:00"), value: "8:00-10:00"),
      const DropdownMenuItem(child: Text("10:00-12:00"), value: "10:00-12:00"),
      const DropdownMenuItem(child: Text("12:00-14:00"), value: "12:00-14:00"),
      const DropdownMenuItem(child: Text("14:00-16:00"), value: "14:00-16:00"),
      const DropdownMenuItem(child: Text("16:00-18:00"), value: "16:00-18:00"),
      const DropdownMenuItem(child: Text("18:00-20:00"), value: "18:00-20:00"),
      const DropdownMenuItem(child: Text("20:00-22:00"), value: "20:00-22:00"),
    ];
    return hours;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Courses",
        ),
        actions: [
          IconButton(
            onPressed: () {
              signOut();
            },
            icon: const Icon(Icons.logout),
          )
        ],
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
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(_resultsList[index].uid),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    createInfoAlertDialog(
                                        context, _resultsList[index]);
                                  },
                                  alignment: Alignment.center,
                                  icon: const Icon(
                                    Icons.info,
                                    color: Colors.blueAccent,
                                    size: 32,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    createEdtiAlertDialog(
                                        context, _resultsList[index]);
                                  },
                                  alignment: Alignment.center,
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.grey,
                                    size: 32,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    createAddAlertDialog(
                                      context,
                                      _resultsList[index],
                                    );
                                  },
                                  alignment: Alignment.center,
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.grey,
                                    size: 32,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        subtitle: ListView.builder(
                          physics: const ClampingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: intervals[_resultsList[index]]!.length,
                          itemBuilder: (context, intervalIndex) {
                            return Card(
                              elevation: 4,
                              child: ListTile(
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          intervals[_resultsList[index]]!
                                              .elementAt(intervalIndex),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        IconButton(
                                          onPressed: () {
                                            createDeleteAlertDialog(
                                              context,
                                              _resultsList[index],
                                              intervals[_resultsList[index]]!
                                                  .elementAt(intervalIndex),
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size: 32,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            generateQR(
                                              _resultsList[index].uid,
                                              intervals[_resultsList[index]]!
                                                  .elementAt(intervalIndex),
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.qr_code_2,
                                            size: 32,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            exportAttendancyList(
                                              _resultsList[index].uid,
                                              intervals[_resultsList[index]]!
                                                  .elementAt(intervalIndex),
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.download,
                                            size: 32,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
