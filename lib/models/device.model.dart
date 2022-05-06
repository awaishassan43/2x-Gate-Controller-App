// ignore_for_file: non_constant_identifier_names
// Just because bilal said he doesn't want to change the variable names in database to lowercase.. and flutter complains
/// about non-constant identifiers to be starting with uppercase

import 'package:iot/util/functions.util.dart';

class Device {
  Device({
    required this.deviceCommands,
    required this.deviceSettings,
    required this.deviceData,
  });

  DeviceCommands deviceCommands;
  DeviceSettings deviceSettings;
  DeviceData deviceData;

  void updateWithJSON({
    Map<String, dynamic>? deviceCommands,
    Map<String, dynamic>? deviceSettings,
    Map<String, dynamic>? deviceData,
  }) {
    this.deviceCommands = deviceCommands != null ? DeviceCommands.fromJson(deviceCommands) : this.deviceCommands;
    this.deviceSettings = deviceSettings != null ? DeviceSettings.fromJson(deviceSettings) : this.deviceSettings;
    this.deviceData = deviceData != null ? DeviceData.fromJson(deviceData) : this.deviceData;
  }

  factory Device.fromJson(Map<String, dynamic> json) => Device(
        deviceCommands: DeviceCommands.fromJson((json["deviceCommands"] as Map<Object?, Object?>).cast<String, dynamic>()),
        deviceSettings: DeviceSettings.fromJson((json["deviceSettings"] as Map<Object?, Object?>).cast<String, dynamic>()),
        deviceData: DeviceData.fromJson((json["deviceData"] as Map<Object?, Object?>).cast<String, dynamic>()),
      );

  Map<String, dynamic> toJson() => {
        "deviceCommands": deviceCommands.toJson(),
        "deviceSettings": deviceSettings.toJson(),
        // "deviceStateLogs": List<dynamic>.from(deviceStateLogs.map((x) => x.toJson())),
        "deviceData": deviceData.toJson(),
      };
}

class DeviceCommands {
  DeviceCommands({
    required this.request,
    required this.sendToDevice,
    required this.timestamp,
  });

  _Request request;
  String sendToDevice;
  int timestamp;

  factory DeviceCommands.fromJson(Map<String, dynamic> json) => DeviceCommands(
        request: _Request.fromJson((json["request"] as Map<Object?, Object?>).cast<String, dynamic>()),
        sendToDevice: json["sendToDevice"],
        timestamp: json["timestamp"],
      );

  Map<String, dynamic> toJson() => {
        "request": request.toJson(),
        "sendToDevice": sendToDevice,
        "timestamp": timestamp,
      };
}

class _Request {
  _Request({
    required this.action,
    required this.payload,
    required this.reqId,
  });

  String action;
  _RequestPayload payload;
  String reqId;

  factory _Request.fromJson(Map<String, dynamic> json) => _Request(
        action: json["action"],
        payload: _RequestPayload.fromJson((json["payload"] as Map<Object?, Object?>).cast<String, dynamic>()),
        reqId: json["reqId"],
      );

  Map<String, dynamic> toJson() => {
        "action": action,
        "payload": payload.toJson(),
        "reqId": reqId,
      };
}

class _RequestPayload {
  _RequestPayload({
    required this.exp,
    required this.pass,
    required this.state,
    required this.test,
    required this.reboot,
  });

  int exp;
  String pass;
  String state;
  int test;
  int reboot;

  factory _RequestPayload.fromJson(Map<String, dynamic> json) => _RequestPayload(
        exp: json["exp"],
        pass: json["pass"],
        state: json["state"],
        test: json["test"],
        reboot: json["reboot"],
      );

  Map<String, dynamic> toJson() => {
        "exp": exp,
        "pass": pass,
        "state": state,
        "test": test,
        "reboot": reboot,
      };
}

class DeviceSettings {
  DeviceSettings({
    required this.deviceId,
    required this.owner,
    required this.type,
    required this.value,
  });

  String deviceId;
  String owner;
  String type;
  _Value value;

  factory DeviceSettings.fromJson(Map<String, dynamic> json) => DeviceSettings(
        deviceId: json["deviceId"],
        owner: json["owner"],
        type: json["type"],
        value: _Value.fromJson((json["value"] as Map<Object?, Object?>).cast<String, dynamic>()),
      );

  Map<String, dynamic> toJson() => {
        "deviceId": deviceId,
        "owner": owner,
        "type": type,
        "value": value.toJson(),
      };
}

class _Value {
  _Value({
    required this.alertOnClose,
    required this.alertOnOpen,
    required this.nightAlert,
    required this.region,
    required this.temperatureAlert,
    required this.relay1,
    required this.relay2,
  });

  bool alertOnClose;
  bool alertOnOpen;
  bool nightAlert;
  String region;
  double? temperatureAlert;
  _RelaySettings relay1;
  _RelaySettings relay2;

  factory _Value.fromJson(Map<String, dynamic> json) => _Value(
        relay1: _RelaySettings.fromJson((json["Relay1"] as Map<Object?, Object?>).cast<String, Object>()),
        relay2: _RelaySettings.fromJson((json["Relay2"] as Map<Object?, Object?>).cast<String, dynamic>()),
        alertOnClose: json["alertOnClose"],
        alertOnOpen: json["alertOnOpen"],
        nightAlert: json["nightAlert"],
        region: json["region"],
        temperatureAlert: json["temperatureAlert"] != null ? dynamicToDouble(json['temperatureAlert']) : null,
      );

  Map<String, dynamic> toJson() => {
        "Relay1": relay1.toJson(),
        "Relay2": relay2.toJson(),
        "alertOnClose": alertOnClose,
        "alertOnOpen": alertOnOpen,
        "nightAlert": nightAlert,
        "region": region,
        "temperatureAlert": temperatureAlert,
      };
}

class _RelaySettings {
  _RelaySettings({
    required this.extInput,
    required this.name,
    required this.outTime,
    required this.autoClose,
    required this.schedules,
  });

  bool extInput;
  String name;
  int outTime;
  int autoClose;
  List<Schedule> schedules;

  factory _RelaySettings.fromJson(Map<String, dynamic> json) => _RelaySettings(
        extInput: json["ExtInput"],
        name: json["Name"],
        outTime: json["OutTime"],
        autoClose: json["autoClose"],
        schedules: mapToList(json['schedules']).map((e) => Schedule.fromJson(e as Map<String, dynamic>)).toList(),
      );

  Map<String, dynamic> toJson() => {
        "ExtInput": extInput,
        "Name": name,
        "OutTime": outTime,
        "autoClose": autoClose,
        "schedules": schedules.map((e) => e.toJson()).toList(),
      };
}

class Schedule {
  bool repeat;
  DateTime executionTime;
  Map<String, bool> days;
  bool enabled;

  Schedule({
    required this.repeat,
    required this.executionTime,
    required this.days,
    required this.enabled,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
        repeat: json['repeat'],
        days: json['days'],
        executionTime: DateTime.parse(json['executionTime']),
        enabled: json['enabled'],
      );

  Map<String, dynamic> toJson() => {
        "repeat": repeat,
        "days": days,
        "executionTime": executionTime,
        "enabled": enabled,
      };
}

class DeviceData {
  DeviceData({
    required this.name,
    required this.online,
    required this.owner,
    required this.state,
    required this.timestamp,
    required this.type,
  });

  String name;
  bool online;
  String owner;
  _DeviceState state;
  int timestamp;
  String type;

  factory DeviceData.fromJson(Map<String, dynamic> json) => DeviceData(
        name: json["name"],
        online: json["online"],
        owner: json["owner"],
        state: _DeviceState.fromJson((json["state"] as Map<Object?, Object?>).cast<String, dynamic>()),
        timestamp: json["timestamp"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "online": online,
        "owner": owner,
        "state": state.toJson(),
        "timestamp": timestamp,
        "type": type,
      };
}

class _DeviceState {
  _DeviceState({
    required this.action,
    required this.payload,
    required this.reqId,
  });

  String action;
  _StatePayload payload;
  String reqId;

  factory _DeviceState.fromJson(Map<String, dynamic> json) => _DeviceState(
        action: json["action"],
        payload: _StatePayload.fromJson((json["payload"] as Map<Object?, Object?>).cast<String, dynamic>()),
        reqId: json["reqId"],
      );

  Map<String, dynamic> toJson() => {
        "action": action,
        "payload": payload.toJson(),
        "reqId": reqId,
      };
}

class _StatePayload {
  _StatePayload({
    required this.exp,
    required this.pass,
    required this.state1,
    required this.state2,
    required this.Temp,
    required this.humidity,
    required this.Ip,
    required this.Mac,
    required this.Strength,
  });

  int exp;
  String pass;
  int state1;
  int state2;
  int Temp;
  int humidity;
  String Ip;
  String Mac;
  int Strength;

  factory _StatePayload.fromJson(Map<String, dynamic> json) => _StatePayload(
        exp: json["exp"],
        pass: json["pass"],
        state1: json["state1"],
        state2: json["state2"],
        Temp: json["Temp"],
        humidity: json["humidity"],
        Ip: json["Ip"],
        Mac: json["Mac"],
        Strength: json["Strength"],
      );

  Map<String, dynamic> toJson() => {
        "exp": exp,
        "pass": pass,
        "state1": state1,
        "state2": state2,
        "Temp": Temp,
        "humidity": humidity,
        "Ip": Ip,
        "Mac": Mac,
        "Strength": Strength,
      };
}

Device getEmptyDeviceData(String deviceID, String ownerID) {
  final Device device = Device(
    deviceCommands: DeviceCommands(
      request: _Request(
        action: 'OPEN GATE',
        payload: _RequestPayload(
          exp: DateTime.now().millisecondsSinceEpoch,
          pass: "1234",
          state: "OPEN",
          reboot: 0,
          test: 1,
        ),
        reqId: '1234',
      ),
      sendToDevice: "OK",
      timestamp: DateTime.now().millisecondsSinceEpoch,
    ),
    deviceSettings: DeviceSettings(
      deviceId: deviceID,
      owner: ownerID,

      ///TODO: That's a bit sus
      type: "garage",
      value: _Value(
        alertOnClose: false,
        alertOnOpen: false,
        nightAlert: false,
        region: "UK",
        temperatureAlert: null,
        relay1: _RelaySettings(extInput: true, name: 'Front Gate', outTime: 10, autoClose: 20, schedules: []),
        relay2: _RelaySettings(extInput: true, name: 'Back Gate', outTime: 10, autoClose: 20, schedules: []),
      ),
    ),
    deviceData: DeviceData(
      name: 'Gate Controller',
      online: true,
      owner: ownerID,
      state: _DeviceState(
        action: "DOOR_ACTIVITY",
        payload: _StatePayload(
          exp: DateTime.now().millisecondsSinceEpoch,
          pass: '1234',
          state1: 0,
          Ip: "",
          Mac: "",
          Strength: 0,
          state2: 1,
          Temp: 20,
          humidity: 20,
        ),
        reqId: "123412412123124",
      ),
      timestamp: DateTime.now().millisecondsSinceEpoch,
      type: "garage",
    ),
  );
  return device;
}
