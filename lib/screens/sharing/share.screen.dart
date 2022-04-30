import 'package:flutter/material.dart';
import 'package:iot/components/loader.component.dart';

import '../../enum/route.enum.dart';

class SharingScreen extends StatefulWidget {
  const SharingScreen({Key? key}) : super(key: key);

  @override
  State<SharingScreen> createState() => _SharingScreenState();
}

class _SharingScreenState extends State<SharingScreen> {
  bool isLoading = false;
  String? screenError;

  Future<void> scanQR() async {
    setState(() {
      isLoading = true;
    });

    try {} catch (e) {
      setState(() {
        screenError = e.toString();
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add User"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pushNamed(context, Screen.scanner);
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.qr_code_scanner),
                      Column(
                        children: const [
                          Text("Scan QR Code"),
                          Text("to add device via QR code"),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          if (isLoading) const Loader(),
        ],
      ),
    );
  }
}
