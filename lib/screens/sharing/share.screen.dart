import 'package:flutter/material.dart';
import 'package:iot/components/button.component.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../controllers/user.controller.dart';
import '../../util/functions.util.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text(
                      "Share via QR code",
                      style: TextStyle(),
                    ),
                    const SizedBox(height: 10),
                    QrImageView(
                      data: 'https://google.com/',
                      version: QrVersions.auto,
                      size: 200,
                    ),
                  ],
                ),
              ),
            ),

            /**
             * End of top section
             */

            /**
             * OR SEPERATOR
             */
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text("OR"),
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            /**
             * END OF OR SEPERATOR
             */

            /**
             * Buttons to share
             */
            CustomButton(
              text: "Share via other methods",
              onPressed: () => share(context),
            ),
          ],
        ),
      ),
    );
  }
}
