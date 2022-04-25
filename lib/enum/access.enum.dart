import 'package:flutter/foundation.dart';

enum AccessType {
  guest,
  owner,
  family,
}

extension AccessTypeExtension on AccessType {
  String get value {
    return describeEnum(this);
  }

  static AccessType getAccessType(String value) {
    return AccessType.values.firstWhere((element) => element.value == value);
  }
}
