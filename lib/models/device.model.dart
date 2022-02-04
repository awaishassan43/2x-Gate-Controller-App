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
  _Payload payload;
  String reqId;

  factory _Request.fromJson(Map<String, dynamic> json) => _Request(
        action: json["action"],
        payload: _Payload.fromJson((json["payload"] as Map<Object?, Object?>).cast<String, dynamic>()),
        reqId: json["reqId"],
      );

  Map<String, dynamic> toJson() => {
        "action": action,
        "payload": payload.toJson(),
        "reqId": reqId,
      };
}

class _Payload {
  _Payload({
    required this.exp,
    required this.pass,
    required this.state,
    required this.test,
    required this.dummy,
  });

  int exp;
  String pass;
  String state;
  int test;
  String? dummy;

  factory _Payload.fromJson(Map<String, dynamic> json) => _Payload(
        exp: json["exp"],
        pass: json["pass"],
        state: json["state"],
        test: json["test"],
        dummy: json["dummy"],
      );

  Map<String, dynamic> toJson() => {
        "exp": exp,
        "pass": pass,
        "state": state,
        "test": test,
        "dummy": dummy,
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
  _Request state;
  int timestamp;
  String type;

  factory DeviceData.fromJson(Map<String, dynamic> json) => DeviceData(
        name: json["name"],
        online: json["online"],
        owner: json["owner"],
        state: _Request.fromJson((json["state"] as Map<Object?, Object?>).cast<String, dynamic>()),
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
  double temperatureAlert;
  _RelaySettings relay1;
  _RelaySettings relay2;

  factory _Value.fromJson(Map<String, dynamic> json) => _Value(
        relay1: _RelaySettings.fromJson((json["Relay1"] as Map<Object?, Object?>).cast<String, Object>()),
        relay2: _RelaySettings.fromJson((json["Relay2"] as Map<Object?, Object?>).cast<String, dynamic>()),
        alertOnClose: json["alertOnClose"],
        alertOnOpen: json["alertOnOpen"],
        nightAlert: json["nightAlert"],
        region: json["region"],
        temperatureAlert: json["temperatureAlert"].toDouble(),
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
    required this.scheduled,
    required this.autoClose,
  });

  bool extInput;
  String name;
  int outTime;
  bool scheduled;
  int autoClose;

  factory _RelaySettings.fromJson(Map<String, dynamic> json) => _RelaySettings(
        extInput: json["ExtInput"],
        name: json["Name"],
        outTime: json["OutTime"],
        scheduled: json["Scheduled"],
        autoClose: json["autoClose"],
      );

  Map<String, dynamic> toJson() => {
        "ExtInput": extInput,
        "Name": name,
        "OutTime": outTime,
        "Scheduled": scheduled,
        "autoClose": autoClose,
      };
}

class _DeviceLog {
  _DeviceLog({
    required this.deviceId,
    required this.publishedAt,
    required this.state,
    required this.timestamp,
  });

  String deviceId;
  DateTime publishedAt;
  _DeviceLogState state;
  int timestamp;

  factory _DeviceLog.fromJson(Map<String, dynamic> json) => _DeviceLog(
        deviceId: json["deviceId"],
        publishedAt: DateTime.parse(json["published_at"]),
        state: _DeviceLogState.fromJson((json["state"] as Map<Object?, Object?>).cast<String, dynamic>()),
        timestamp: json["timestamp"],
      );

  Map<String, dynamic> toJson() => {
        "deviceId": deviceId,
        "published_at": publishedAt.toIso8601String(),
        "state": state.toJson(),
        "timestamp": timestamp,
      };
}

class _DeviceLogState {
  _DeviceLogState({
    required this.doorActiveState,
    required this.fw,
    required this.heap,
    required this.humidity,
    required this.mqttPublishType,
    required this.pressure,
    required this.rangeFound,
    required this.signalRssi,
    required this.temperature,
  });

  String doorActiveState;
  int fw;
  int heap;
  double humidity;
  String mqttPublishType;
  double pressure;
  int rangeFound;
  int signalRssi;
  double temperature;

  factory _DeviceLogState.fromJson(Map<String, dynamic> json) => _DeviceLogState(
        doorActiveState: json["doorActiveState"],
        fw: json["fw"],
        heap: json["heap"],
        humidity: json["humidity"].toDouble(),
        mqttPublishType: json["mqttPublishType"],
        pressure: json["pressure"].toDouble(),
        rangeFound: json["rangeFound"],
        signalRssi: json["signalRssi"],
        temperature: json["temperature"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "doorActiveState": doorActiveState,
        "fw": fw,
        "heap": heap,
        "humidity": humidity,
        "mqttPublishType": mqttPublishType,
        "pressure": pressure,
        "rangeFound": rangeFound,
        "signalRssi": signalRssi,
        "temperature": temperature,
      };
}
