import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:qresent/model/attendance_model.dart';

class ShowStatistics extends StatefulWidget {
  const ShowStatistics({
    Key? key,
    required this.interval,
    // required this.course,
  }) : super(key: key);
  final String interval;
  // final String course;

  @override
  _ShowStatisticsState createState() => _ShowStatisticsState();
}

class _ShowStatisticsState extends State<ShowStatistics> {
  final CollectionReference attendancesRef =
      FirebaseFirestore.instance.collection("Attendance");
  List<String> datesList = [];
  List<int> presentList = [];
  List<int> activeList = [];

  @override
  void initState() {
    getNoOfPresentAndActive();
    super.initState();
  }

  getNoOfPresentAndActive() async {
    List<int> presentListTemp = [];
    List<int> activeListTemp = [];
    List<String> datesListTemp = [];

    await attendancesRef.doc(widget.interval).get().then((value) {
      AttendanceModel attendance = AttendanceModel.fromMap(value.data());
      for (var date in attendance.dates.entries) {
        presentListTemp.add(date.value["present"].length);
        activeListTemp.add(date.value["active"].length);
        datesListTemp.add(date.key);
      }
    });
    setState(() {
      presentList = presentListTemp;
      activeList = activeListTemp;
      datesList = datesListTemp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendancy statistics"),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            for (var i = 0; i < presentList.length; i++)
              Padding(
                padding: const EdgeInsets.all(15),
                child: CircularPercentIndicator(
                  header: Text(datesList[i]),
                  radius: 130.0,
                  animation: true,
                  animationDuration: 1200,
                  lineWidth: 15.0,
                  percent: activeList[i] / presentList[i],
                  center: Text(
                    activeList[i].toString() +
                        "/" +
                        presentList[i].toString() +
                        " active students",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20.0),
                  ),
                  circularStrokeCap: CircularStrokeCap.butt,
                  backgroundColor: Colors.grey,
                  progressColor: Colors.blue,
                ),
              )
          ],
        ),
      ),
    );
  }
}
