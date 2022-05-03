import 'package:flutter/material.dart';

class FamilyScreen extends StatelessWidget {
  const FamilyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Family Devices"),
        centerTitle: true,
      ),
    );
  }
}
