import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qresent/model/attendance_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ScanResult extends StatefulWidget {
  const ScanResult({Key? key, required this.barcode}) : super(key: key);

  final Barcode barcode;

  @override
  _ScanResultState createState() => _ScanResultState();
}

class _ScanResultState extends State<ScanResult> {
  User? user = FirebaseAuth.instance.currentUser;
  String? document;
  AttendanceModel? attendanceModel;
  String? date;
  String? typeOfAttendance;
  final CollectionReference _attendanceRef =
      FirebaseFirestore.instance.collection("Attendance");

  @override
  void initState() {
    splitQRCode();
    getAttendanceModel();
    super.initState();
  }

  splitQRCode() {
    List<String> barcodeParts = widget.barcode.code!.split(" ");

    setState(() {
      document =
          barcodeParts[0] + " " + barcodeParts[1] + " " + barcodeParts[2];
      typeOfAttendance = barcodeParts[3];
      date = barcodeParts[4];
    });
  }

  getAttendanceModel() async {
    await _attendanceRef.doc(document).get().then((value) {
      setState(() {
        attendanceModel = AttendanceModel.fromMap(value.data());
      });
    });
  }

  attendCourse() async {
    if (typeOfAttendance == "attendance") {
      if (!attendanceModel!.dates[date]["present"].contains(user!.email)) {
        attendanceModel!.dates[date]["present"].add(user!.email);
        await _attendanceRef.doc(document).set(attendanceModel!.toMap());
        Fluttertoast.showToast(msg: "Attended Successful");
      } else if (attendanceModel!.dates[date]["present"]
          .contains(user!.email)) {
        Fluttertoast.showToast(msg: "You are already marked as present");
      }
    } else if (typeOfAttendance == "activity") {
      if (attendanceModel!.dates[date]["present"].contains(user!.email) &&
          !attendanceModel!.dates[date]["active"].contains(user!.email)) {
        attendanceModel!.dates[date]["active"].add(user!.email);
        await _attendanceRef.doc(document).set(attendanceModel!.toMap());
        Fluttertoast.showToast(msg: "Attended Successful");
      } else if (!attendanceModel!.dates[date]["present"]
          .contains(user!.email)) {
        Fluttertoast.showToast(msg: "You can't attend for active attendance");
      } else if (attendanceModel!.dates[date]["active"].contains(user!.email)) {
        Fluttertoast.showToast(msg: "You are already marked as active");
      }
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "QResent",
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.barcode.code!),
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Material(
                  elevation: 5,
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.blueAccent,
                  child: MaterialButton(
                    onPressed: () {
                      attendCourse();
                    },
                    padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                    minWidth: 300,
                    child: const Text(
                      "Attend Course",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
