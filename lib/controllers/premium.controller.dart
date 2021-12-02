import 'package:flutter/cupertino.dart';

class ProController extends ChangeNotifier {
  bool _isPro = false;

  bool get isPro => _isPro;
  set isPro(bool value) {
    _isPro = value;
    notifyListeners();
  }
}
