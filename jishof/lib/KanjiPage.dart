import 'package:flutter/material.dart';
import 'dart:convert';

class KanjiPage extends StatefulWidget {

  static Map kdic;
  List<String> kanji;

  KanjiPage(List<String> kanji) {
    this.kanji = kanji;
  }

  _KanjiPageState createState() => new _KanjiPageState(kanji);
}

class _KanjiPageState extends State<KanjiPage> {

  List<String> _kanji;
  List<Widget> _kanjiWidgets = <Widget>[];

  _KanjiPageState(List<String> kanji) {
    _kanji = kanji;
  }

  @override
  Widget build(BuildContext context) {
    DefaultAssetBundle
        .of(context)
        .loadString('assets/json_files/kdic2')
        .then((kdic2) {
          KanjiPage.kdic = json.decode(kdic2);
    });
    for (String k in _kanji) {
      _kanjiWidgets.add(KanjiInfoWidget.fromJSONObj(k, KanjiPage.kdic[k]).makeWidget());
    }
    return new Scaffold(body: new Padding(
          padding: new EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
          child: new ListView(children: _kanjiWidgets))
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
class KanjiInfoWidget extends StatelessWidget {

  static final int gradeInd = 0;
  static final int jlptInd = 1;
  static final int readingInd = 2;
  static final int meaningInd = 3;
  static final int nanoriInd = 4;

  final Widget kanjiText;
  final Widget jlpt;
  final Widget grade;
  final Widget meanings;
  final Widget readings;
  final Widget nanori;

  build(BuildContext context) { return makeWidget(); }

  Widget makeWidget() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 5.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        textDirection: TextDirection.ltr,
        children: <Widget>[
          new Row(children: <Widget>[
            new Padding(
                padding: EdgeInsets.fromLTRB(0.0, 0.0, 15.0, 0.0),
                child: jlpt
            ),
            new Padding(
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 30.0, 0.0),
              child: grade
            ),
            kanjiText
          ]),
          meanings,
          readings,
          nanori
        ],
      )
    );
  }

  KanjiInfoWidget.fromJSONObj(String k, List jsonObj) :
      kanjiText = new Text(k, style: new TextStyle(fontSize: 48.0)),
      jlpt = jsonObj[jlptInd] == "" ? new Text('  ', style: new TextStyle(fontSize: 48.0)) :
        new Text('N' + jsonObj[jlptInd], style: new TextStyle(fontSize: 48.0)),
      grade = jsonObj[gradeInd] == "" ? new Text('  ', style: new TextStyle(fontSize: 48.0)) :
        new Text('G' + jsonObj[gradeInd], style: new TextStyle(fontSize: 48.0)),

      readings = jsonObj[readingInd].length == 0 ? new Text(' ', style: new TextStyle(fontSize: 24.0)) :
        new Text('Readings: ' + jsonObj[readingInd].toString().substring(1, jsonObj[readingInd].toString().length - 1), style: new TextStyle(fontSize: 24.0)),
      meanings = jsonObj[meaningInd].length == 0 ? new Text(' ', style: new TextStyle(fontSize: 24.0)) :
        new Text('Meanings: ' + jsonObj[meaningInd].toString().substring(1, jsonObj[meaningInd].toString().length - 1), style: new TextStyle(fontSize: 24.0)),
      nanori =  jsonObj[nanoriInd].length == 0 ? new Text(' ', style: new TextStyle(fontSize: 24.0)) :
        new Text('Name Readings: ' + jsonObj[nanoriInd].toString().substring(1, jsonObj[nanoriInd].toString().length - 1), style: new TextStyle(fontSize: 24.0));
}