import 'package:flutter/material.dart';
import '/components/button.component.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  late final TextEditingController controller;
  final GlobalKey<FormState> key = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: Colors.transparent),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Feedback"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Form(
                key: key,
                child: TextFormField(
                  decoration: InputDecoration(
                    border: border,
                    focusedErrorBorder: border,
                    enabledBorder: border,
                    focusedBorder: border,
                    errorBorder: border,
                    disabledBorder: border,
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.all(10),
                    hintText: "Send us your message...",
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: Colors.black45,
                    ),
                  ),
                  controller: controller,
                  minLines: 6,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                ),
              ),
            ),
            CustomButton(
              text: "Send Feedback",
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
