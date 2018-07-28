import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class DefaultSearchPage extends StatefulWidget {
  String searchTextField;

  DefaultSearchPage(String searchTextField)
      : this.searchTextField = searchTextField;

  @override
  _DefaultSearchPageState createState() =>
      new _DefaultSearchPageState(searchTextField);
}

class _DefaultSearchPageState extends State<DefaultSearchPage> {
  List<Widget> _defWidgets = <Widget>[];
  String searchTextField;
  bool fullQuery;
  _DefaultSearchPageState(String searchTextField)
      : this.searchTextField = searchTextField;

  @override
  Widget build(BuildContext context) {
    if (fullQuery) {
      if (_defWidgets.length > 0) {
        return new Scaffold(
            body: new Padding(
          padding: new EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
          child: new ListView(children: _defWidgets),
        ));
      } else {
        return new Scaffold(
            body: new Padding(
          padding: new EdgeInsets.symmetric(vertical: 30.0, horizontal: 10.0),
          child: new Text("Loading Query"),
        ));
      }
    } else {
      return new Scaffold(
          body: new Padding(
              padding:
                  new EdgeInsets.symmetric(vertical: 30.0, horizontal: 10.0),
              child: new Text("Query had no results.")));
    }
  }

  @override
  void initState() {
    super.initState();
    fullQuery = true;
    listenForDefinitions();
  }

  listenForDefinitions() async {
    var stream = await getJSON();
    stream.listen((json) => setState(() => _defWidgets.add(json.getWidget())));
    if (_defWidgets.length == 0) {
      setState(() {
        fullQuery = false;
      });
    }
  }

  Future<Stream<DefinitionWidget>> getJSON() async {
    final String api = "https://jisho.org/api/v1/search/words?keyword=";
    var url = api + searchTextField;
    var client = new http.Client();
    var streamedRes =
        await client.send(new http.Request('get', Uri.parse(url)));
    return streamedRes.stream
        .transform(UTF8.decoder)
        .transform(JSON.decoder)
        .expand((jsonBody) => (jsonBody as Map)['data'])
        .map((jsonDefinition) => DefinitionWidget.fromJson(jsonDefinition));
  }
}

class DefinitionWidget {
  final Widget isCommon;
  final Widget tags;
  final Column japanese;
  final Column senses;
  final Map attribution;
  static Paint isCommonPaint = new Paint();
  static Paint tagsPaint = new Paint();

  Widget getWidget() {
    isCommonPaint.color = new Color(0x8abc83);
    tagsPaint.color = new Color(0x909dc0);
    if (isCommon != null) {
      return new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        textDirection: TextDirection.ltr,
        children: <Widget>[
          new Row(children: <Widget>[isCommon, tags]),
          japanese,
          senses
        ], //TODO if we can get jlpt info like the site has, it goes in the row
      );
    } else {
      return new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        textDirection: TextDirection.ltr,
        children: <Widget>[
          tags,
          japanese,
          senses
        ], //TODO see above block on jlpt info
      );
    }
  }

  DefinitionWidget.fromJson(Map jsonMap)
      : isCommon = jsonMap['is_common'] == true
            ? new Container(
                child: new Text('common',
                    style: new TextStyle(
                        color: Colors.white, background: isCommonPaint)),
                decoration: new BoxDecoration(
                  borderRadius: new BorderRadius.all(new Radius.circular(10.0)),
                  color: new Color(0xff8abc83),
                ),
                padding: new EdgeInsets.all(3.0),
              )
            : null,
        tags = createTagsWidget(jsonMap['tags']),
        japanese = createJapaneseSubwidget(
            (jsonMap['japanese'] as List).elementAt(0) as Map),
        //TODO get other forms, (elements 1 and above). these would go at the bottom of the definitionwidget
        senses = createSensesSubwidget(jsonMap['senses']),
        attribution = jsonMap['attribution'];

  static Column createJapaneseSubwidget(Map jsonMap) {
    Widget mainFormReading = new Text(
      jsonMap['reading'],
      textScaleFactor: 1.5,
    ); //TODO make this look pretty
    Widget mainFormWord = new Text(
      jsonMap['word'],
      textScaleFactor: 3.0,
    ); //TODO make this look pretty
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      textDirection: TextDirection.ltr,
      children: <Widget>[
        mainFormReading,
        mainFormWord,
      ],
    );
  }

  static Column createSensesSubwidget(List jsonList) {
    List<Widget> subsenses = new List();
    for (int i = 0; i < jsonList.length; i++) {
      subsenses.add(
        getSubsense(jsonList[i], i + 1),
      );
      subsenses.add(new Text(''));
    }
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      textDirection: TextDirection.ltr,
      children: subsenses,
    );
  }

  static Widget getSubsense(Map jsonMap, int index) {
    //TODO QUERY AKUMA AND LOOK FOR TAGS ON API. THIS IS IMPORTANT
    //TODO eventually add links tags restrictions, see_also, antonyms, source, and info procedures
    StringBuffer engDefBuffer = new StringBuffer();
    List engDefs = jsonMap['english_definitions'];
    for (int i = 0; i < engDefs.length - 1; i++) {
      engDefBuffer.write(engDefs[i]); //TODO same as above
      engDefBuffer.write('; ');
    }
    if (engDefs.length > 0) {
      engDefBuffer.write(engDefs[engDefs.length - 1]);
    }
    Widget engDefString = new Text(
        index.toString() + '. ' + engDefBuffer.toString()); //TODO more styling

    StringBuffer partSpeechBuffer = new StringBuffer();
    List partSpeechMap = jsonMap['parts_of_speech'];
    for (int i = 0; i < partSpeechMap.length - 1; i++) {
      partSpeechBuffer.write(partSpeechMap[i]); //TODO same as above
      partSpeechBuffer.write('; ');
    }
    if (partSpeechMap.length > 0) {
      partSpeechBuffer.write(partSpeechMap[partSpeechMap.length - 1]);
    }
    String partSpeech = partSpeechBuffer.toString();
    Widget partSpeechString = new Text(
      partSpeechBuffer.toString(),
      style: new TextStyle(color: Colors.black45),
      textScaleFactor: .8,
    ); //TODO styling
    if (partSpeech.length > 0) {
      return new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          textDirection: TextDirection.ltr,
          children: <Widget>[partSpeechString, engDefString]);
    } else {
      return new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        textDirection: TextDirection.ltr,
        children: <Widget>[engDefString],
      );
    }
  }

  static Widget createTagsWidget(List jsonList) {
    StringBuffer tagBuffer = new StringBuffer();

    for (int i = 0; i < jsonList.length - 1; i++) {
      tagBuffer.write(jsonList[i]); //TODO same as above
      tagBuffer.write('; ');
    }
    if (jsonList.length > 0) {
      tagBuffer.write(jsonList[jsonList.length - 1]);
      return new Container(
        child: Text(tagBuffer.toString(),
            style: new TextStyle(color: Colors.white, background: tagsPaint)),
        decoration: new BoxDecoration(
          borderRadius: new BorderRadius.all(new Radius.circular(10.0)),
          color: new Color(0xff909dc0),
        ),
        padding: new EdgeInsets.all(3.0),
      );
    } else {
      return new Text('');
    }
    //TODO more styling
  }
}
