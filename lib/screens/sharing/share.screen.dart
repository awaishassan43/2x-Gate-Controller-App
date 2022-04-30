import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:iot/controllers/user.controller.dart';
import 'package:iot/util/constants.util.dart';
import 'package:iot/util/functions.util.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class SharingScreen extends StatelessWidget {
  final String deviceID;
  final String deviceName;

  const SharingScreen({
    Key? key,
    required this.deviceID,
    required this.deviceName,
  }) : super(key: key);

  Future<void> share(BuildContext context) async {
    try {
      final UserController controller = Provider.of<UserController>(context, listen: false);
      final String userID = controller.getUserID();
      final String name = controller.profile!.name;

      /**
       * Creating the dynamic link
       */
      final String link = await generateDynamicLink('/addUser?deviceID=$deviceID&ownerID=$userID');

      final String shareText = "$name has provided you access to the $deviceName. Please follow the link: $link";

      await Share.share(shareText);
    } catch (e) {
      showMessage(context, "Failed to share the link: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sharing"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Text("Share via QR code"),
          QrImageView(
            data: 'https://google.com/',
            version: QrVersions.auto,
            size: 200,
          ),

          /**
           * Buttons to share
           */
          MaterialButton(
            onPressed: () => share(context),
            child: const Text("Share via other methods"),
          ),
        ],
      ),
    );
  }
}
