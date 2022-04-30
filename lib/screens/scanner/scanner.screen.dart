import 'package:flutter/material.dart';
import 'package:iot/util/constants.util.dart';
import 'package:iot/util/functions.util.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/loader.component.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({Key? key}) : super(key: key);

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool isLoading = false;
  final MobileScannerController cameraController = MobileScannerController();

  Future<void> onCodeDetected(BuildContext context, Barcode barcode, MobileScannerArguments? _) async {
    if (barcode.rawValue == null) {
      return;
    }

    // Checking for the scanned value to confirm it contains the dynamic link
    final String code = barcode.rawValue!;

    if (!code.startsWith(dynamicLink)) {
      debugPrint("Code read - Dynamic link not found");
      return;
    }

    debugPrint("Code read - dynamic link found");

    try {
      if (await canLaunch(code)) {
        await launch(code);
      }
    } catch (e) {
      showMessage(context, "Failed to scan the link");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan QR"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          MobileScanner(
            allowDuplicates: false,
            controller: cameraController,
            onDetect: (code, args) => onCodeDetected(context, code, args),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    color: Colors.white,
                    icon: ValueListenableBuilder(
                      valueListenable: cameraController.torchState,
                      builder: (context, state, child) {
                        switch (state as TorchState) {
                          case TorchState.off:
                            return const Icon(Icons.flash_off, color: Colors.grey);
                          case TorchState.on:
                            return const Icon(Icons.flash_on, color: Colors.yellow);
                        }
                      },
                    ),
                    iconSize: 32.0,
                    onPressed: () => cameraController.toggleTorch(),
                  ),
                  IconButton(
                    color: Colors.white,
                    icon: ValueListenableBuilder(
                      valueListenable: cameraController.cameraFacingState,
                      builder: (context, state, child) {
                        switch (state as CameraFacing) {
                          case CameraFacing.front:
                            return const Icon(Icons.camera_front);
                          case CameraFacing.back:
                            return const Icon(Icons.camera_rear);
                        }
                      },
                    ),
                    iconSize: 32.0,
                    onPressed: () => cameraController.switchCamera(),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading) const Loader(),
        ],
      ),
    );
  }
}
