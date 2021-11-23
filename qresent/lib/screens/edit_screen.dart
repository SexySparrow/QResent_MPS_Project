import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qresent/model/course_model.dart';
import 'package:qresent/model/user_model.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({Key? key}) : super(key: key);

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final CollectionReference usersRef =
      FirebaseFirestore.instance.collection("Users");
  final CollectionReference coursesRef =
      FirebaseFirestore.instance.collection("Courses");

  final TextEditingController _searchController = TextEditingController();

  List<UserModel> _usersList = [];
  List<UserModel> _resultsList = [];
  List<CourseModel> _coursesList = [];
  List<bool> _isChecked = [];

  @override
  void initState() {
    getUsers();
    _searchController.addListener(_onSearchChanged);
    super.initState();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  getUsers() async {
    List<UserModel> userListTemp = [];
    await usersRef.get().then((QuerySnapshot snapshot) {
      for (var documentSnapshot in snapshot.docs) {
        UserModel user = UserModel.fromMap(documentSnapshot.data());
        if (user.accessLevel != "2") {
          userListTemp.add(user);
        }
      }
    });

    setState(() {
      _usersList = userListTemp;
    });
    searchResultList();
  }

  searchResultList() {
    List<UserModel> showResults = [];

    if (_searchController.text != "") {
      for (var doc in _usersList) {
        var userName = "${doc.firstName} ${doc.lastName}".toLowerCase();

        if (userName.contains(_searchController.text.toLowerCase())) {
          showResults.add(doc);
        }
      }
    } else {
      showResults = List.from(_usersList);
    }

    setState(() {
      _resultsList = showResults;
    });
  }

  _onSearchChanged() {
    searchResultList();
  }

  Future<void> getCourses(UserModel user) async {
    List<CourseModel> _coursesListTemp = [];
    List<bool> _isCheckedTemp = [];

    if (user.accessLevel == "0") {
      await coursesRef.get().then((QuerySnapshot snapshot) {
        for (var documentSnapshot in snapshot.docs) {
          CourseModel course = CourseModel.fromMap(documentSnapshot.data());
          _coursesListTemp.add(course);

          if (user.assignedCourses!.isEmpty) {
            _isCheckedTemp.add(false);
          } else if (user.assignedCourses!.contains(course.uid)) {
            _isCheckedTemp.add(true);
          } else {
            _isCheckedTemp.add(false);
          }
        }
      });
    } else {
      await coursesRef.get().then((QuerySnapshot snapshot) {
        for (var documentSnapshot in snapshot.docs) {
          CourseModel course = CourseModel.fromMap(documentSnapshot.data());

          if (user.assignedCourses!.isEmpty) {
            _coursesListTemp.add(course);
            _isCheckedTemp.add(false);
          } else if (user.assignedCourses!.contains(course.uid)) {
            _coursesListTemp.add(course);
            _isCheckedTemp.add(true);
          } else if (course.assignedProfessor == "") {
            _coursesListTemp.add(course);
            _isCheckedTemp.add(false);
          }
        }
      });
    }

    setState(() {
      _isChecked = _isCheckedTemp;
      _coursesList = _coursesListTemp;
    });
  }

  changeAssignedCourses(UserModel user) {
    List<dynamic> newCourses = [];

    for (int index = 0; index < _coursesList.length; index++) {
      if (_isChecked[index]) {
        newCourses.add(_coursesList[index].uid);
      }
    }

    if (user.accessLevel == "0") {
      usersRef.doc(user.uid).update({"AssignedCourses": newCourses});
    } else {
      if (user.assignedCourses!.isNotEmpty) {
        for (int index = 0; index < user.assignedCourses!.length; index++) {
          coursesRef
              .doc(user.assignedCourses![index])
              .update({"AssignedProfessor": ""});
        }
      }

      usersRef.doc(user.uid).update({"AssignedCourses": newCourses});

      setState(() {
        user.assignedCourses = newCourses;
      });

      if (user.assignedCourses!.isNotEmpty) {
        for (int index = 0; index < user.assignedCourses!.length; index++) {
          coursesRef.doc(user.assignedCourses![index]).update(
              {"AssignedProfessor": "${user.firstName} ${user.lastName}"});
        }
      }
    }

    getUsers();
  }

  createEditAlertDialog(BuildContext context, UserModel user) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Courses"),
          content: SingleChildScrollView(
            child: Material(
              child: MyEditDialogContent(
                isChecked: _isChecked,
                courses: _coursesList,
                onChange: (val) {
                  _isChecked = val;
                },
              ),
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    createAllertForSubmit(context, user);
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

  createAllertForSubmit(BuildContext context, UserModel user) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Confirm Submit"),
            content:
                const Text("Are you sure you want to submit these changes?"),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      changeAssignedCourses(user);
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text("Confirm"),
                  ),
                ],
              ),
            ],
          );
        });
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
                      hintText: 'Search a user',
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
                            title: Text(
                                "${_resultsList[index].firstName} ${_resultsList[index].lastName}"),
                            subtitle:
                                Text("email: ${_resultsList[index].email}"),
                            trailing: IconButton(
                                onPressed: () async {
                                  await getCourses(_resultsList[index]);
                                  createEditAlertDialog(
                                      context, _resultsList[index]);
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blueAccent,
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

class MyEditDialogContent extends StatefulWidget {
  const MyEditDialogContent({
    Key? key,
    required this.courses,
    required this.isChecked,
    this.onChange,
  }) : super(key: key);

  final List<CourseModel> courses;
  final List<bool> isChecked;
  final ValueChanged<List<bool>>? onChange;

  @override
  _MyEditDialogContentState createState() => _MyEditDialogContentState();
}

class _MyEditDialogContentState extends State<MyEditDialogContent> {
  _getContent() {
    if (widget.courses.isEmpty) {
      return Container();
    }

    return Column(
      children: [
        Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height / 2,
          width: 300,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(
                  bottom: 20,
                ),
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.courses.length,
                    itemBuilder: (context, index) {
                      return CheckboxListTile(
                        value: widget.isChecked[index],
                        title: Text(widget.courses[index].uid),
                        onChanged: (val) {
                          setState(
                            () {
                              widget.isChecked[index] = val as bool;
                              widget.onChange!(widget.isChecked);
                            },
                          );
                        },
                      );
                    }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _getContent();
  }
}
