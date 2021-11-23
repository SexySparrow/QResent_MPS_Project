import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GenerateQRPage extends StatefulWidget {
  const GenerateQRPage({
    Key? key,
    required this.interval,
    required this.course,
  }) : super(key: key);
  final String interval;
  final String course;

  @override
  _GenerateQRPageState createState() => _GenerateQRPageState();
}

class _GenerateQRPageState extends State<GenerateQRPage> {
  TextEditingController controller = TextEditingController();
  String date = DateFormat('dd-MM-yyyy').format(DateTime.now());
  int buttonPressed = 0;
  String qrType = "";

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Scan QR Code'),
        ),
        body: Center(
          child: (buttonPressed != 0)
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    QrImage(
                      data: widget.course +
                          " " +
                          widget.interval +
                          " " +
                          qrType +
                          " " +
                          date.toString(),
                      size: 300,
                      embeddedImageStyle:
                          QrEmbeddedImageStyle(size: const Size(80, 80)),
                    ),
                    Container(
                      margin: const EdgeInsets.all(20),
                    ),
                    const Text(
                        "Scan this QR code in order to be marked as present")
                  ],
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Material(
                        elevation: 5,
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.blueAccent,
                        child: MaterialButton(
                          onPressed: () {
                            setState(() {
                              buttonPressed = 1;
                              qrType = "attendance";
                            });
                          },
                          padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                          minWidth: 300,
                          child: const Text(
                            "QR for Attendance",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: Material(
                          elevation: 5,
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.blueAccent,
                          child: MaterialButton(
                            onPressed: () {
                              setState(() {
                                buttonPressed = 1;
                                qrType = "activity";
                              });
                            },
                            padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                            minWidth: 300,
                            child: const Text(
                              "QR for Activity",
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
