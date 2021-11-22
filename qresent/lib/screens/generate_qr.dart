import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GenerateQRPage extends StatefulWidget {
  const GenerateQRPage(
      {Key? key,
      required this.interval,
      required this.course,
      required this.type})
      : super(key: key);
  final String interval;
  final String course;
  final String type;

  @override
  _GenerateQRPageState createState() => _GenerateQRPageState();
}

class _GenerateQRPageState extends State<GenerateQRPage> {
  TextEditingController controller = TextEditingController();
  String date = DateFormat('dd-MM-yyyy').format(DateTime.now());
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: widget.type == "present"
              ? const Text('Scan QR code for attendance')
              : const Text('Scan QR code for activity'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                QrImage(
                  data: widget.course +
                      " " +
                      widget.interval +
                      " " +
                      date.toString() +
                      " " +
                      widget.type,
                  size: 300,
                  embeddedImageStyle:
                      QrEmbeddedImageStyle(size: const Size(80, 80)),
                ),
                Container(
                  margin: const EdgeInsets.all(20),
                ),
                const Text("Scan this QR code in order to be marked as present")
              ],
            ),
          ),
        ),
      ),
    );
  }
}
