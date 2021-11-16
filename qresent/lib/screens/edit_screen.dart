import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qresent/model/user_model.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({Key? key}) : super(key: key);

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final CollectionReference usersRef =
      FirebaseFirestore.instance.collection("Users");

  final TextEditingController _searchController = TextEditingController();

  List<UserModel> _usersList = [];
  List<UserModel> _resultsList = [];

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

  createEditAlertDialog(BuildContext context, UserModel user) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Courses"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
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
                          child: ListTile(
                            title: Text(
                                "${_resultsList[index].firstName} ${_resultsList[index].lastName}"),
                            subtitle:
                                Text("email: ${_resultsList[index].email}"),
                            trailing: IconButton(
                                onPressed: () {
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
