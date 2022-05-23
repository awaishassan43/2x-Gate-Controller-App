import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:iot/components/error.component.dart';
import 'package:iot/components/loader.component.dart';
import 'package:iot/controllers/user.controller.dart';
import 'package:iot/util/functions.util.dart';
import 'package:provider/provider.dart';

import '../../components/button.component.dart';
import '../../enum/route.enum.dart';
import '../../util/themes.util.dart';

class DeviceAcceptingScreen extends StatefulWidget {
  const DeviceAcceptingScreen({Key? key}) : super(key: key);

  @override
  State<DeviceAcceptingScreen> createState() => _DeviceAcceptingScreenState();
}

class _DeviceAcceptingScreenState extends State<DeviceAcceptingScreen> {
  late Future<void> attachDevice;

  @override
  void initState() {
    super.initState();
    attachDevice = attachingDevice(context);
  }

  Future<void> attachingDevice(BuildContext context) async {
    try {
      final AppLinks _appLinks = AppLinks();
      final Uri? uri = await _appLinks.getInitialAppLink();

      final String? sharingKey = uri?.queryParameters["key"];

      if (sharingKey == null) {
        showMessage(context, "Failed to get the sharable link");
        Navigator.pushNamedAndRemoveUntil(context, Screen.dashboard, (route) => false);

        return;
      }

      final UserController controller = Provider.of<UserController>(context, listen: false);
      await controller.addRemoteDevice(sharingKey);
      showMessage(context, "Added device successfully!");
    } catch (e) {
      showMessage(context, e.toString());
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Adding New Device"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          FutureBuilder(
            future: attachDevice,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Loader(message: "Adding new device");
              }

              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    snapshot.hasError || snapshot.error != null
                        ? ErrorMessage(message: snapshot.error!.toString())
                        : Column(
                            children: const [
                              Icon(
                                Icons.done,
                                color: Colors.green,
                                size: 30,
                              ),
                              Text(
                                "Device added successfully!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                    const Spacer(),
                    CustomButton(
                      onPressed: () {
                        Navigator.pushNamed(context, Screen.dashboard);
                      },
                      text: "Go to dashboard",
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
