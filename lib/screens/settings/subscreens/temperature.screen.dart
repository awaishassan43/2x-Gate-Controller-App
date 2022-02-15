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
  late final String temperatureUnit;

  late final TextEditingController temperature;

  String formError = '';
  String temperatureError = '';

  @override
  void initState() {
    super.initState();

    temperatureUnit = Provider.of<UserController>(context, listen: false).profile!.temperatureUnit;

    final DeviceController deviceController = Provider.of<DeviceController>(context, listen: false);
    final double? value = deviceController.devices[widget.deviceID]!.deviceSettings.value.temperatureAlert;

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
                        suffixText: '\u00b0$temperatureUnit',
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

                    try {
                      final DeviceController deviceController = Provider.of<DeviceController>(context, listen: false);
                      final Map<String, dynamic> mappedData = deviceController.devices[widget.deviceID]!.deviceSettings.toJson();

                      mappedData['value']['temperatureAlert'] = shouldAlert
                          ? temperatureUnit == "F"
                              ? double.parse(convertFarenheitToCelcius(double.parse(temperature.text)).toStringAsFixed(1))
                              : double.parse(temperature.text)
                          : null;

                      deviceController.devices[widget.deviceID]!.updateWithJSON(deviceSettings: mappedData);
                      await deviceController.updateDevice(widget.deviceID, 'deviceSettings');

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
