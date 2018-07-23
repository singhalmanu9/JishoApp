import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Flutter Demo',
        theme: new ThemeData(
          primarySwatch: Colors.lightGreen,
        ),
        home: new MyHomePage(),
        routes: <String, WidgetBuilder>{
          '/defaultSearch': (BuildContext context) =>
              new DefaultSearchPage(_MyHomePageState.searchBarController.text)
        });
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  static TextEditingController searchBarController =
      new TextEditingController();

  void _search() {
    Navigator.pushNamed(context, '/defaultSearch');
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
      body: new Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: new Column(
          // Column is also layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug paint" (press "p" in the console where you ran
          // "flutter run", or select "Toggle Debug Paint" from the Flutter tool
          // window in IntelliJ) to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Padding(
                padding:
                    new EdgeInsets.symmetric(vertical: 0.0, horizontal: 40.0),
                child: new SearchTextField(
                    child: new TextField(
                  decoration: const InputDecoration(
                      border: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0x00000000))),
                      labelText: "Type your query here:"),
                  textAlign: TextAlign.left,
                  controller: searchBarController,
                ))),
            new Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _search,
        tooltip: 'Search',
        child: new Icon(Icons.search),
      ),
    );
  }
}

class SearchTextField extends InheritedWidget {
  const SearchTextField({Key key, @required Widget child})
      : assert(child != null),
        super(key: key, child: child);

  final TextField textField;

  @override
  bool updateShouldNotify(SearchTextField stv) => textField != stv.textField;
}

class DefaultSearchPage extends StatefulWidget {
  String searchTextField;

  DefaultSearchPage(String searchTextField)
      : this.searchTextField = searchTextField;

  @override
  _DefaultSearchPageState createState() =>
      new _DefaultSearchPageState(searchTextField);
}

class _DefaultSearchPageState extends State<DefaultSearchPage> {
  List<DefinitionWidget> _defWidgets = <DefinitionWidget>[];
  String searchTextField;

  _DefaultSearchPageState(String searchTextField)
      : this.searchTextField = searchTextField;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    List<Widget> defList = new List();
    for (int i = 0; i < _defWidgets.length; i++) {
      defList.add(_defWidgets[i].getWidget());
    }
    return new Scaffold(
      body: new ListView(children: defList),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listenForDefinitions();
  }

  listenForDefinitions() async {
    var stream = await getJSON();
    stream.listen((json) => setState(() => _defWidgets.add(json)));
  }

  Future<Stream<DefinitionWidget>> getJSON() async {
    final String API = "https://jisho.org/api/v1/search/words?keyword=";
    var url = API + searchTextField;
    var client = new http.Client();
    var streamedRes =
        await client.send(new http.Request('get', Uri.parse(url)));
    return streamedRes.stream
        .transform(UTF8.decoder)
        .transform(JSON.decoder)
        .expand((jsonBody) => (jsonBody as Map)['data'])
        .map((jsonDefinition) => DefinitionWidget.fromJson(
            jsonDefinition)); //TODO change this into the search process. dynamically build the list of widgets from thereon.
  }
}

class DefinitionWidget {
  final Text isCommon;
  final Text tags;
  final Column japanese;
  final Column senses;
  final Map attribution;

  var _tags;
  final Map _japanese;
  var _sensess;
  var _attribution;

  Widget getWidget() {
    if (isCommon != null) {
      return new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        textDirection: TextDirection.ltr,
        children: <Widget>[isCommon, tags, japanese, senses],
      );
    } else {
      return new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        textDirection: TextDirection.ltr,
        children: <Widget>[tags, japanese, senses],
      );
    }
  }

  DefinitionWidget.fromJson(Map jsonMap)
      : isCommon = jsonMap['is_common'] == true ? new Text('common') : null,
        _tags = jsonMap['tags'],
        tags = createTagsWidget(jsonMap['tags']),
        _japanese = (jsonMap['japanese'] as List).elementAt(0) as Map,
        japanese = createJapaneseSubwidget(
            (jsonMap['japanese'] as List).elementAt(0) as Map),
        //TODO get other forms, (elements 1 and above)
        senses = createSensesSubwidget(jsonMap['senses']),
        attribution = jsonMap['attribution'];

  static Column createJapaneseSubwidget(Map jsonMap) {
    Widget mainFormReading =
        new Text(jsonMap['reading']); //TODO make this look pretty
    Widget mainFormWord =
        new Text(jsonMap['word']); //TODO make this look pretty
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
        getSubsense(jsonList[i], i),
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
    Widget partSpeechString =
        new Text(partSpeechBuffer.toString()); //TODO styling
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
    }
    return new Text(tagBuffer.toString()); //TODO more styling
  }
}
