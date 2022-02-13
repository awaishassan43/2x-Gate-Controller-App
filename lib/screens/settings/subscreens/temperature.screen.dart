import 'package:flutter/material.dart';
import 'package:iot/components/button.component.dart';
import 'package:iot/components/input.component.dart';
import 'package:iot/components/loader.component.dart';
import 'package:iot/models/device.model.dart';
import 'package:iot/util/functions.util.dart';
import 'package:provider/provider.dart';
import '/controllers/device.controller.dart';
import '/controllers/user.controller.dart';

class TemperatureAlertScreen extends StatefulWidget {
  final String deviceID;
  const TemperatureAlertScreen({Key? key, required this.deviceID}) : super(key: key);

  @override
  State<TemperatureAlertScreen> createState() => _TemperatureAlertScreenState();
}

class _TemperatureAlertScreenState extends State<TemperatureAlertScreen> {
  bool isLoading = false;
  late bool shouldAlert;

  late final TextEditingController temperature;
  late final DeviceController deviceController;
  late final UserController userController;
  late final Device device;

  String formError = '';
  String temperatureError = '';

  @override
  void initState() {
    super.initState();

    userController = Provider.of<UserController>(context, listen: false);
    deviceController = Provider.of<DeviceController>(context, listen: false);
    device = deviceController.devices[widget.deviceID]!;

    final double? value = device.deviceSettings.value.temperatureAlert;

    temperature = TextEditingController(
      text: value != null
          ? getTemperatureValue(
              context,
              value,
              withUnit: false,
              decimalPlaces: 1,
              onNullMessage: '',
            )
          : '0',
    );

    shouldAlert = value != null;
  }

  bool validateTemperature() {
    if (!shouldAlert) {
      return true;
    }

    if (temperature.text == "") {
      setState(() {
        temperatureError = "This field cannot be empty!";
      });

      return false;
    } else if (double.tryParse(temperature.text) == null) {
      setState(() {
        temperatureError = "Temperature must be a valid number";
      });

      return false;
    }

    if (temperatureError != '') {
      setState(() {
        temperatureError = '';
      });
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Temperature alert"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SwitchListTile(
                        title: const Text(
                          "Alert",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          shouldAlert ? "Set to alert" : "Don't alert",
                          style: const TextStyle(fontSize: 11),
                        ),
                        value: shouldAlert,
                        onChanged: (value) {
                          setState(() {
                            shouldAlert = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomInput(
                        label: "Temperature Alert",
                        icon: Icons.sensors,
                        disabled: !shouldAlert,
                        error: temperatureError,
                        controller: temperature,
                        suffixText: '\u00b0${userController.profile!.temperatureUnit}',
                      ),
                      if (formError != '')
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            formError,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                CustomButton(
                  text: "Update temperature alert",
                  onPressed: () async {
                    final bool isTemperatureValid = validateTemperature();

                    if (!isTemperatureValid) {
                      return;
                    }

                    setState(() {
                      isLoading = true;
                    });

                    // final double? previousValue = widget.device.temperatureAlert;

                    try {
                      final String unit = Provider.of<UserController>(context, listen: false).profile!.temperatureUnit;

                      // deviceController.devices[widget.id]!.temperatureAlert = shouldAlert
                      //     ? unit == "F"
                      //         ? double.parse(convertFarenheitToCelcius(double.parse(temperature.text)).toStringAsFixed(1))
                      //         : double.parse(temperature.text)
                      //     : null;
                      // await deviceController.updateDevice(controller.devices[widget.device.id]!);

                      showMessage(context, "Controller updated successfully!");
                      Navigator.pop(context);
                    } catch (e) {
                      setState(() {
                        formError = e.toString();
                        isLoading = false;
                      });

                      showMessage(context, "Failed to update the controller");
                    }
                  },
                ),
              ],
            ),
          ),
          if (isLoading) const Loader(message: "Updating controller"),
        ],
      ),
    );
  }
}
