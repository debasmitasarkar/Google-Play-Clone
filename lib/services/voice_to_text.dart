import 'package:permission/permission.dart';
import 'dart:async';
import 'package:speech_recognition/speech_recognition.dart';

class VoiceToText {
  SpeechRecognition _speech = new SpeechRecognition();
  bool _speechRecognitionAvailable = false;
  bool _isListening = false;
  static final oneSecond = Duration(milliseconds: 100);

  String transcription = '';

  StreamController<dynamic> streamController;
  String _currentLocale = 'en_US';
  PermissionStatus status;

  VoiceToText() {
    this.init();
    streamController = StreamController();
    streamController.add(transcription);
  }

  bool get isSpeechRecognitionAvailable {
    print("SpeechRecognition status- $_speechRecognitionAvailable");
    return _speechRecognitionAvailable;
  }

  bool get isListening {
    return _isListening;
  }

  void init() => getPermissionStatus().then((res) {
        status = res;
        res == PermissionStatus.allow ? activateSpeechRecognizer() : null;
      });

  void startSpeaking() => status != PermissionStatus.allow && !isListening
      ? requestPermission().then(
          (res) => res == PermissionStatus.allow ? activateAndStart() : null)
      : null;

  void activateAndStart() {
    activateSpeechRecognizer();
    start();
  }

  void start() => _speech.listen(locale: _currentLocale).then((result) {
        print(result);
      });

  void cancel() => _speech.cancel().then((result) => _isListening = result);

  void _stop() => _speech.stop().then((result) => _isListening = result);

  stop() {
    _stop();
  }

  void onSpeechAvailability(bool result) => _speechRecognitionAvailable = true;

  void onCurrentLocale(String locale) => _currentLocale = locale;

  void onRecognitionStarted() => _isListening = true;

  void onRecognitionResult(String text) =>
      text != '' ? streamController.add(transcription = text) : '';

  void onRecognitionComplete() => _isListening = false;

  void activateSpeechRecognizer() {
    print('_MyAppState.activateSpeechRecognizer... ');
    _speech = new SpeechRecognition();
    _speech.setAvailabilityHandler(onSpeechAvailability);
    _speech.setCurrentLocaleHandler(onCurrentLocale);
    _speech.setRecognitionStartedHandler(onRecognitionStarted);
    _speech.setRecognitionResultHandler(onRecognitionResult);
    _speech.setRecognitionCompleteHandler(onRecognitionComplete);
    _speech.activate().then((res) {
      _speechRecognitionAvailable = res;
    });
  }

  Future getPermissionStatus() async {
    var res = await Permission.getPermissionStatus([PermissionName.Microphone]);
    return res[0].permissionStatus;
  }

  Future requestPermission() async {
    final res =
        await Permission.requestSinglePermission(PermissionName.Microphone);
    return res;
  }
}
