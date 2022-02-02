class Device {
  _DeviceCommands deviceCommands;
  _DeviceSettings deviceSettings;
  _DeviceData deviceData;

  Device({required this.deviceCommands, required this.deviceSettings, required this.deviceData});

  factory Device.fromJson(Map<String, dynamic> json) {
    try {
      return Device(
        deviceCommands: _DeviceCommands.fromJson((json['deviceCommands'] as Map<Object?, Object?>).cast<String, dynamic>()),
        deviceSettings: _DeviceSettings.fromJson((json['deviceSettings'] as Map<Object?, Object?>).cast<String, dynamic>()),
        deviceData: _DeviceData.fromJson((json['deviceData'] as Map<Object?, Object?>).cast<String, dynamic>()),
      );
    } catch (e) {
      throw "Failed to convert data to class: ${e.toString()}";
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['deviceCommands'] = deviceCommands.toJson();
    data['deviceSettings'] = deviceSettings.toJson();
    data['deviceData'] = deviceData.toJson();
    return data;
  }
}

class _DeviceCommands {
  _Request request;
  String sendToDevice;
  int timestamp;

  _DeviceCommands({required this.request, required this.sendToDevice, required this.timestamp});

  factory _DeviceCommands.fromJson(Map<String, dynamic> json) {
    return _DeviceCommands(
      request: _Request.fromJson((json['request'] as Map<Object?, Object?>).cast<String, dynamic>()),
      sendToDevice: json['sendToDevice'],
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['request'] = request.toJson();
    data['sendToDevice'] = sendToDevice;
    data['timestamp'] = timestamp;
    return data;
  }
}

class _Request {
  String action;
  _Payload payload;
  String reqId;

  _Request({required this.action, required this.payload, required this.reqId});

  factory _Request.fromJson(Map<String, dynamic> json) {
    return _Request(
      action: json['action'],
      payload: _Payload.fromJson((json['payload'] as Map<Object?, Object?>).cast<String, dynamic>()),
      reqId: json['reqId'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['action'] = action;
    data['payload'] = payload.toJson();
    data['reqId'] = reqId;
    return data;
  }
}

class _State {
  String action;
  _Payload payload;
  String reqId;

  _State({required this.action, required this.payload, required this.reqId});

  factory _State.fromJson(Map<String, dynamic> json) {
    return _State(
      action: json['action'],
      payload: _Payload.fromJson((json['payload'] as Map<Object?, Object?>).cast<String, dynamic>()),
      reqId: json['reqId'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['action'] = action;
    data['payload'] = payload.toJson();
    data['reqId'] = reqId;
    return data;
  }
}

class _Payload {
  int exp;
  String pass;
  String state;
  int test;

  _Payload({required this.exp, required this.pass, required this.state, required this.test});

  factory _Payload.fromJson(Map<String, dynamic> json) {
    return _Payload(
      exp: json['exp'],
      pass: json['pass'],
      state: json['state'],
      test: json['test'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['exp'] = exp;
    data['pass'] = pass;
    data['state'] = state;
    data['test'] = test;
    return data;
  }
}

class _DeviceSettings {
  String deviceId;
  String owner;
  String type;
  _Value value;

  _DeviceSettings({required this.deviceId, required this.owner, required this.type, required this.value});

  factory _DeviceSettings.fromJson(Map<String, dynamic> json) {
    return _DeviceSettings(
      deviceId: json['deviceId'],
      owner: json['owner'],
      type: json['type'],
      value: _Value.fromJson((json['value'] as Map<Object?, Object?>).cast<String, dynamic>()),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['deviceId'] = deviceId;
    data['owner'] = owner;
    data['type'] = type;
    data['value'] = value.toJson();
    return data;
  }
}

class _Value {
  bool alertOnClose;
  bool alertOnOpen;
  int autoClose;
  bool buzzer;
  bool ledLight;
  bool nightAlert;
  String region;
  bool scheduled;
  double temperatureAlert;

  _Value(
      {required this.alertOnClose,
      required this.alertOnOpen,
      required this.autoClose,
      required this.buzzer,
      required this.ledLight,
      required this.nightAlert,
      required this.region,
      required this.scheduled,
      required this.temperatureAlert});

  factory _Value.fromJson(Map<String, dynamic> json) {
    return _Value(
      alertOnClose: json['alertOnClose'],
      alertOnOpen: json['alertOnOpen'],
      autoClose: json['autoClose'],
      buzzer: json['buzzer'],
      ledLight: json['ledLight'],
      nightAlert: json['nightAlert'],
      region: json['region'],
      scheduled: json['scheduled'],
      temperatureAlert: json['temperatureAlert'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['alertOnClose'] = alertOnClose;
    data['alertOnOpen'] = alertOnOpen;
    data['autoClose'] = autoClose;
    data['buzzer'] = buzzer;
    data['ledLight'] = ledLight;
    data['nightAlert'] = nightAlert;
    data['region'] = region;
    data['scheduled'] = scheduled;
    data['temperatureAlert'] = temperatureAlert;
    return data;
  }
}

class _DeviceData {
  String name;
  bool online;
  String owner;
  _State state;
  int timestamp;
  String type;

  _DeviceData({required this.name, required this.online, required this.owner, required this.state, required this.timestamp, required this.type});

  factory _DeviceData.fromJson(Map<String, dynamic> json) {
    return _DeviceData(
      name: json['name'],
      online: json['online'],
      owner: json['owner'],
      state: _State.fromJson((json['state'] as Map<Object?, Object?>).cast<String, dynamic>()),
      timestamp: json['timestamp'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['online'] = online;
    data['owner'] = owner;
    data['state'] = state.toJson();
    data['timestamp'] = timestamp;
    data['type'] = type;
    return data;
  }
}
