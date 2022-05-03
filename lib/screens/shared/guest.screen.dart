import 'package:flutter/material.dart';

class GuestsScreen extends StatelessWidget {
  const GuestsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Guest Devices"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [],
        ),
      ),
    );
  }
}
