import 'package:flutter/material.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {}

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  /// Stores the narrative text from the AI API response
  String _narrativeText = 'La historia comenzara aqui...\n';
  String get narrativeText => _narrativeText;
  set narrativeText(String value) {
    _narrativeText = value;
  }

  String _sessionId = '';
  String get sessionId => _sessionId;
  set sessionId(String value) {
    _sessionId = value;
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
  }

  dynamic _currentChoices;
  dynamic get currentChoices => _currentChoices;
  set currentChoices(dynamic value) {
    _currentChoices = value;
  }
}
