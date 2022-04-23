import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iot/util/functions.util.dart';
import 'package:provider/provider.dart';

import '../../../components/loader.component.dart';
import '../../../controllers/user.controller.dart';
import '../../../util/constants.util.dart';
import '/components/button.component.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  // State variables
  bool isLoading = false;
  late final TextEditingController controller;
  final GlobalKey<FormState> key = GlobalKey<FormState>();

  // errors
  String? feedbackError;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  Future<void> sendFeedback(BuildContext context) async {
    try {
      setState(() {
        isLoading = true;

        if (feedbackError != null) {
          feedbackError = null;
        }
      });

      // Validating the input field
      final String feedback = controller.text;

      if (feedback.isEmpty) {
        throw "Please add some feedback before submitting";
      }

      final String email = Provider.of<UserController>(context, listen: false).getUserEmail();

      final Uri uri = Uri.parse(feedbackURL);
      await http.post(uri, body: {
        "email": email,
        "feedback": controller.text,
      });

      setState(() {
        isLoading = false;
      });

      showMessage(context, "Feedback sent successfully!");
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        isLoading = false;
        feedbackError = e.toString();
      });
    }
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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (feedbackError != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                    child: Text(
                      feedbackError!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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
                  onPressed: () => sendFeedback(context),
                ),
              ],
            ),
          ),
          if (isLoading) const Loader(message: "Sending feedback"),
        ],
      ),
    );
  }
}
