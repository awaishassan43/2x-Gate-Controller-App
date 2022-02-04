class Device {
  Device({
    required this.deviceCommands,
    required this.deviceSettings,
    required this.deviceData,
  });

  final _DeviceCommands deviceCommands;
  final _DeviceSettings deviceSettings;
  final _DeviceData deviceData;

  Device updateWithJSON({
    Map<String, dynamic>? deviceCommands,
    Map<String, dynamic>? deviceSettings,
    Map<String, dynamic>? deviceData,
  }) =>
      Device(
        deviceCommands: deviceCommands != null ? _DeviceCommands.fromJson(deviceCommands) : this.deviceCommands,
        deviceSettings: deviceSettings != null ? _DeviceSettings.fromJson(deviceSettings) : this.deviceSettings,
        deviceData: deviceData != null ? _DeviceData.fromJson(deviceData) : this.deviceData,
      );

  factory Device.fromJson(Map<String, dynamic> json) => Device(
        deviceCommands: _DeviceCommands.fromJson((json["deviceCommands"] as Map<Object?, Object?>).cast<String, dynamic>()),
        deviceSettings: _DeviceSettings.fromJson((json["deviceSettings"] as Map<Object?, Object?>).cast<String, dynamic>()),
        deviceData: _DeviceData.fromJson((json["deviceData"] as Map<Object?, Object?>).cast<String, dynamic>()),
      );

  Map<String, dynamic> toJson() => {
        "deviceCommands": deviceCommands.toJson(),
        "deviceSettings": deviceSettings.toJson(),
        // "deviceStateLogs": List<dynamic>.from(deviceStateLogs.map((x) => x.toJson())),
        "deviceData": deviceData.toJson(),
      };
}

class _DeviceCommands {
  _DeviceCommands({
    required this.request,
    required this.sendToDevice,
    required this.timestamp,
  });

  final _Request request;
  final String sendToDevice;
  final int timestamp;

  _DeviceCommands updateWithJSON({
    _Request? request,
    String? sendToDevice,
    int? timestamp,
  }) =>
      _DeviceCommands(
        request: request ?? this.request,
        sendToDevice: sendToDevice ?? this.sendToDevice,
        timestamp: timestamp ?? this.timestamp,
      );

  factory _DeviceCommands.fromJson(Map<String, dynamic> json) => _DeviceCommands(
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

  final String action;
  final _Payload payload;
  final String reqId;

  _Request updateWithJSON({
    String? action,
    _Payload? payload,
    String? reqId,
  }) =>
      _Request(
        action: action ?? this.action,
        payload: payload ?? this.payload,
        reqId: reqId ?? this.reqId,
      );

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

  final int exp;
  final String pass;
  final String state;
  final int test;
  final String? dummy;

  _Payload updateWithJSON({
    int? exp,
    String? pass,
    String? state,
    int? test,
    String? dummy,
  }) =>
      _Payload(
        exp: exp ?? this.exp,
        pass: pass ?? this.pass,
        state: state ?? this.state,
        test: test ?? this.test,
        dummy: dummy ?? this.dummy,
      );

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

class _DeviceData {
  _DeviceData({
    required this.name,
    required this.online,
    required this.owner,
    required this.state,
    required this.timestamp,
    required this.type,
  });

  final String name;
  final bool online;
  final String owner;
  final _Request state;
  final int timestamp;
  final String type;

  _DeviceData updateWithJSON({
    String? name,
    bool? online,
    String? owner,
    _Request? state,
    int? timestamp,
    String? type,
  }) =>
      _DeviceData(
        name: name ?? this.name,
        online: online ?? this.online,
        owner: owner ?? this.owner,
        state: state ?? this.state,
        timestamp: timestamp ?? this.timestamp,
        type: type ?? this.type,
      );

  factory _DeviceData.fromJson(Map<String, dynamic> json) => _DeviceData(
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

class _DeviceSettings {
  _DeviceSettings({
    required this.deviceId,
    required this.owner,
    required this.type,
    required this.value,
  });

  final String deviceId;
  final String owner;
  final String type;
  final _Value value;

  _DeviceSettings updateWithJSON({
    String? deviceId,
    String? owner,
    String? type,
    _Value? value,
  }) =>
      _DeviceSettings(
        deviceId: deviceId ?? this.deviceId,
        owner: owner ?? this.owner,
        type: type ?? this.type,
        value: value ?? this.value,
      );

  factory _DeviceSettings.fromJson(Map<String, dynamic> json) => _DeviceSettings(
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

  final bool alertOnClose;
  final bool alertOnOpen;
  final bool nightAlert;
  final String region;
  final double temperatureAlert;
  final _RelaySettings relay1;
  final _RelaySettings relay2;

  _Value updateWithJSON({
    bool? alertOnClose,
    bool? alertOnOpen,
    bool? nightAlert,
    String? region,
    double? temperatureAlert,
    _RelaySettings? relay1,
    _RelaySettings? relay2,
  }) =>
      _Value(
        relay1: relay1 ?? this.relay1,
        relay2: relay2 ?? this.relay2,
        alertOnClose: alertOnClose ?? this.alertOnClose,
        alertOnOpen: alertOnOpen ?? this.alertOnOpen,
        nightAlert: nightAlert ?? this.nightAlert,
        region: region ?? this.region,
        temperatureAlert: temperatureAlert ?? this.temperatureAlert,
      );

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

  final bool extInput;
  final String name;
  final int outTime;
  final bool scheduled;
  final int autoClose;

  _RelaySettings updateWithJSON({
    bool? extInput,
    String? name,
    int? outTime,
    bool? scheduled,
    int? autoClose,
  }) =>
      _RelaySettings(
        extInput: extInput ?? this.extInput,
        name: name ?? this.name,
        outTime: outTime ?? this.outTime,
        scheduled: scheduled ?? this.scheduled,
        autoClose: autoClose ?? this.autoClose,
      );

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

  final String deviceId;
  final DateTime publishedAt;
  final _DeviceLogState state;
  final int timestamp;

  _DeviceLog updateWithJSON({
    String? deviceId,
    DateTime? publishedAt,
    _DeviceLogState? state,
    int? timestamp,
  }) =>
      _DeviceLog(
        deviceId: deviceId ?? this.deviceId,
        publishedAt: publishedAt ?? this.publishedAt,
        state: state ?? this.state,
        timestamp: timestamp ?? this.timestamp,
      );

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

  final String doorActiveState;
  final int fw;
  final int heap;
  final double humidity;
  final String mqttPublishType;
  final double pressure;
  final int rangeFound;
  final int signalRssi;
  final double temperature;

  _DeviceLogState updateWithJSON({
    String? doorActiveState,
    int? fw,
    int? heap,
    double? humidity,
    String? mqttPublishType,
    double? pressure,
    int? rangeFound,
    int? signalRssi,
    double? temperature,
  }) =>
      _DeviceLogState(
        doorActiveState: doorActiveState ?? this.doorActiveState,
        fw: fw ?? this.fw,
        heap: heap ?? this.heap,
        humidity: humidity ?? this.humidity,
        mqttPublishType: mqttPublishType ?? this.mqttPublishType,
        pressure: pressure ?? this.pressure,
        rangeFound: rangeFound ?? this.rangeFound,
        signalRssi: signalRssi ?? this.signalRssi,
        temperature: temperature ?? this.temperature,
      );

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
