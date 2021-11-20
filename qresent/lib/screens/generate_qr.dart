import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GenerateQRPage extends StatefulWidget {
  const GenerateQRPage({Key? key, required this.interval, required this.course})
      : super(key: key);
  final String interval;
  final String course;

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
          title: const Text('Scan QR code'),
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
                      date.toString(),
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
