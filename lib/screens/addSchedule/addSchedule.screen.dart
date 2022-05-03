import 'package:flutter/material.dart';

class AddScheduleScreen extends StatelessWidget {
  const AddScheduleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Schedule"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          /**
           * TOP Section
           */
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SwitchListTile(
                    onChanged: (value) {},
                    value: false,
                  ),
                ],
              ),
            ),
          ),
          /**
           * END of TOP section
           */

          /**
           * Bottom button
           */
        ],
      ),
    );
  }
}
