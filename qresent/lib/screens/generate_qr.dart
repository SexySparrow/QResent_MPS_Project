import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qresent/screens/teacher_dashboard.dart';

class GenerateQRPage extends StatefulWidget {
  const GenerateQRPage({Key? key}) : super(key: key);

  @override
  _GenerateQRPageState createState() => _GenerateQRPageState();
}

class _GenerateQRPageState extends State<GenerateQRPage> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR GENERATOR'),
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const TeacherDashboard()));
          },
          child: Icon(
            Icons.arrow_back,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              QrImage(
                data: controller.text,
                size: 300,
                embeddedImage: AssetImage('images/logo.png'),
                embeddedImageStyle:
                    QrEmbeddedImageStyle(size: const Size(80, 80)),
              ),
              Container(
                margin: const EdgeInsets.all(20),
                child: TextFormField(
                  controller: controller,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: 'Enter URL'),
                  validator: (input) {
                    if (input == null || input.isEmpty) {
                      return 'Please enter a link';
                    }
                    if (!RegExp(
                            "https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)")
                        .hasMatch(input)) {
                      return 'No valid link format';
                    }
                    return null;
                  },
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    setState(() {});
                  },
                  child: const Text('GENERATE QR')),
            ],
          ),
        ),
      ),
    );
  }
}
