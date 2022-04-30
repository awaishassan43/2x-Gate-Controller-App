import 'package:flutter/material.dart';

class SharingScreen extends StatelessWidget {
  final String deviceID;
  final String deviceName;

  const SharingScreen({
    Key? key,
    required this.deviceID,
    required this.deviceName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Share via"),
        centerTitle: true,
      ),
      body: Column(
        children: [],
      ),
    );
  }
}
