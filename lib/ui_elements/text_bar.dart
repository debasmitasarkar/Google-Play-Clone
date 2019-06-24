import 'package:flutter/material.dart';
import '../scoped_models/auth.dart';
import '../services/voice_to_text.dart';

class TextBar extends StatefulWidget {
  final bool isTextBarExpanded;
  final Function sendTextMessage;
  TextBar({this.isTextBarExpanded, this.sendTextMessage});

  @override
  State<StatefulWidget> createState() {
    return _TextBarState();
  }
}

class _TextBarState extends State<TextBar> {
  VoiceToText _speech = new VoiceToText();
  AuthModel model = AuthModel();

  final TextEditingController _textController = new TextEditingController();
  bool isListening = false;

  final Decoration _textBarContainerDecoration = BoxDecoration(
    border: Border.all(color: Colors.grey),
    borderRadius: BorderRadius.all(Radius.elliptical(23.0, 23.0)),
  );

  _buildTextFieldContainer(model) {
    return Container(
        height: 30.0,
        constraints: BoxConstraints(maxHeight: 30.0),
        child: TextFormField(
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.justify,
          enabled: widget.isTextBarExpanded,
          autofocus: widget.isTextBarExpanded,
          controller: _textController,
          onFieldSubmitted: (_) =>
              _textMessageSubmitted(_textController.text, model),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(left: 10.0, top: 10.0),
            hintText: widget.isTextBarExpanded ? "Type message" : 'Type...',
            border: InputBorder.none,
          ),
        ));
  }

  _makeVoiceToText() {
    _speech.isSpeechRecognitionAvailable && !_speech.isListening
        ? _speech.start()
        : _speech.startSpeaking();
    // setState(() {
    //   isListening = _speech.isListening;
    // });
    _speech.streamController.stream.asBroadcastStream().listen((transcription) {
      setState(() {
        _textController.text = transcription;
      });
    });
  }

  _buildVoiceIconButton() {
    return Positioned(
        right: 45.0,
        top: 8.0,
        child: GestureDetector(
          behavior: HitTestBehavior.deferToChild,
          onLongPress: () => _makeVoiceToText(),
          child: Icon(
            Icons.mic,
            color: isListening ? Colors.blue : Colors.grey,
            size: isListening ? 30.0 : 25.0,
          ),
        ));
  }

  Widget _buildSendButton(model) {
    return Positioned(
        right: 0.0,
        bottom: -4.0,
        child: IconButton(
          iconSize: 25.0,
          color: Colors.blue[800],
          onPressed: () => _textController.text.isNotEmpty
              ? _textMessageSubmitted(_textController.text, model)
              : null,
          icon: Icon(Icons.send),
        ));
  }

  Widget _buildTextField(model) {
    return Container(
        decoration: _textBarContainerDecoration,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            Positioned(child: _buildTextFieldContainer(model)),
            widget.isTextBarExpanded ? _buildVoiceIconButton() : null,
            widget.isTextBarExpanded ? _buildSendButton(model) : null
          ].where((child) => child != null).toList(),
        ));
  }

  _textMessageSubmitted(String text, AuthModel model) {
    text.isNotEmpty ? widget.sendTextMessage(message: text, model: model) : '';
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity, height: 60.0, child: _buildTextField(model));
  }
}
