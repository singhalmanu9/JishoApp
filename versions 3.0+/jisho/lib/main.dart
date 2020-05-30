import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/OfflineModeUtils.dart';
import 'package:flutter_app/OfflineSearchPage.dart';
import 'package:flutter_app/SearchPage.dart';
import 'package:flutter_app/AboutPage.dart';
import 'package:flutter_app/RadicalPage.dart';
import 'package:flutter_app/KanjiPage.dart';
import 'dart:convert';
import 'package:flutter_app/Trie.dart';
import 'dart:typed_data';

void main() => runApp(new MyApp());

///Used for page transitions. Stops the initial page from having a transition
///effect.
final String initialRouteName = 'initial';

/// Loading the Trie root for the Japanese trie. This resource is
/// used in offline mode.
void loadJPRoot() async {
  String jsonString;
  print("entering loading JPRoot");
  final ByteData data = await rootBundle.load('assets/json_files/JPTrie/root');
  jsonString = utf8.decode(data.buffer.asUint8List());

  print(jsonString.length);
  var jsonMap = jsonDecode(jsonString);
  Trie root = Trie()..fromMap(jsonMap);
  OfflineSearchPage.jpRoot = root;
  print("loaded JPRoot");
}

/// Loading the Trie root for the English Trie. This resource is
/// used in offline mode.
void loadENRoot() async {
  String jsonString;
  print("entering loading ENRoot");
  final ByteData data = await rootBundle.load('assets/json_files/ENTrie/root');
  jsonString = utf8.decode(data.buffer.asUint8List());
  var jsonMap = jsonDecode(jsonString);
  Trie root = Trie()..fromMap(jsonMap);
  OfflineSearchPage.enRoot = root;
  print("loaded ENRoot");
  print(root.toMap());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Jisho',
      initialRoute: initialRouteName,
      theme: new ThemeData(
        primarySwatch: MaterialColor(
            0xFF56d926,
            new Map.fromIterables([
              50,
              100,
              200,
              300,
              400,
              500,
              600,
              700,
              800,
              900
            ], [
              Color(0xFFedfbe8),
              Color(0xFFd3f5c5),
              Color(0xFFb4ee9e),
              Color(0xFF93e673),
              Color(0xFF75e050),
              Color(0xFF56d926),
              Color(0xFF44c81d),
              Color(0xFF22b310),
              Color(0xFF009f00),
              Color(0xFF007c00)
            ])),
      ),
      home: new MyHomePage(),
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/':
            return new CustomRoute(
                builder: (_) => new MyHomePage(), settings: settings);
          case '/defaultSearch':
            return new CustomRoute(
                builder: (_) => new DefaultSearchPage(
                    _MyHomePageState.searchBarController.text,
                    _MyHomePageState.romajiOn),
                settings: settings);
          case '/offlineSearch':
            return new CustomRoute(
                builder: (_) => new OfflineSearchPage(
                    _MyHomePageState.searchBarController.text,
                    _MyHomePageState.romajiOn),
                settings: settings);
          case '/about':
            return new CustomRoute(
                builder: (_) => new AboutPage(), settings: settings);
          case '/radical':
            return new CustomRoute(
                builder: (_) => new RadicalPage(), settings: settings);
          case '/radical/defaultSearch':
            return new CustomRoute(
                builder: (_) => new DefaultSearchPage(
                    RadicalPage.getSearchBarController().text,
                    _MyHomePageState.romajiOn),
                settings: settings);
          case '/radical/offlineSearch':
            return new CustomRoute(
                builder: (_) => new OfflineSearchPage(
                    RadicalPage.getSearchBarController().text,
                    _MyHomePageState.romajiOn),
                settings: settings);
          // ignore: missing_return
          case '/defaultSearch/kanjiInfo':
            return new CustomRoute(
                builder: (_) => new KanjiPage(DefaultSearchPage.getKanjiList()),
                settings: settings);
          case '/offlineSearch/kanjiInfo':
            return new CustomRoute(
                builder: (_) => new KanjiPage(OfflineSearchPage.getKanjiList()),
                settings: settings);
        }
        return null;
      },
    );
  }

  static bool OfflineModeOn() {
    return _MyHomePageState.offlineModeOn;
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static bool romajiOn = false;
  static TextEditingController searchBarController =
      new TextEditingController();
  static bool kdicLoaded = false;
  static bool offlineModeOn = false;

  static bool ENRootLoaded = false;
  static bool JPRootLoaded = false;

  static void _loadkDic(BuildContext context) async {
    final ByteData data = await rootBundle.load('assets/json_files/kdic2');
    String jsonString = utf8.decode(data.buffer.asUint8List());
    KanjiPage.kdic = jsonDecode(jsonString);
    print('loaded kanjidic2');

    kdicLoaded = true;
  }

  static void _loadENRoot(BuildContext context) async {
    loadENRoot();
    ENRootLoaded = true;
  }

  static void _loadJPRoot(BuildContext context) async {
    loadJPRoot();
    JPRootLoaded = true;
  }

  @override
  Widget build(BuildContext context) {
    if (!kdicLoaded) {
      _loadkDic(context);
      kdicLoaded = true;
    }
    return new Scaffold(
      body: new Center(
          child: new Padding(
              padding: new EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
              child: new Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Image(
                      image: new AssetImage('assets/drawable/download.png'),
                      width: 264.0,
                      height: 128.0,
                    ),
                    new Padding(
                        padding: new EdgeInsets.fromLTRB(40.0, 12.0, 40.0, 8.0),
                        child: new TextField(
                          decoration: const InputDecoration(
                              border: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0x00000000))),
                              labelText: "Type your query here:"),
                          textAlign: TextAlign.left,
                          controller: searchBarController,
                        )),
                    new Padding(
                        padding: EdgeInsets.symmetric(horizontal: 100.0),
                        child: new CheckboxListTile(
                            title: new Text('Click for romaji results: '),
                            value: _MyHomePageState.romajiOn,
                            onChanged: (bool value) => setState(() {
                                  _MyHomePageState.romajiOn = value;
                                }))),
                    new Text(
                      "To translate E -> J, surround with \"  \".",
                      textAlign: TextAlign.center,
                      textScaleFactor: 1.25,
                      style: new TextStyle(color: Colors.black54),
                    ),
                    new Text(
                      "Queries are case-sensitive!",
                      textAlign: TextAlign.center,
                      textScaleFactor: 1.25,
                      style: new TextStyle(color: Colors.black54),
                    ),
                    new Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 100.0),
                        child: new CheckboxListTile(
                          title: Text("Offline Mode"), //    <-- label
                          value: offlineModeOn,
                          onChanged: (newValue) {
                            setState(() {
                              offlineModeOn = newValue;
                            });
                          },
                        )),
                    new Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 0.0),
                        child: new Container(
                          child: new FlatButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/radical');
                              },
                              child: new Text(
                                "Radical Search",
                                textDirection: TextDirection.ltr,
                              )),
                          decoration: new BoxDecoration(
                            color: Colors.black12,
                          ),
                          padding: new EdgeInsets.all(3.0),
                        )),
                    new Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 0.0),
                        child: new Container(
                          child: new FlatButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/about'),
                              child: new Text(
                                "About",
                                textDirection: TextDirection.ltr,
                              )),
                          decoration: new BoxDecoration(
                            color: Colors.black12,
                          ),
                          padding: new EdgeInsets.all(3.0),
                        )),
                  ]))),
      floatingActionButton: new Builder(builder: (context) {
        return new FloatingActionButton(
          onPressed: () {
            if (searchBarController.text.length > 0) {
              if (!offlineModeOn) {
                Navigator.pushNamed(context, '/defaultSearch');
              } else {
                if (!ENRootLoaded) {
                  _loadENRoot(context);
                }
                if (!JPRootLoaded) {
                  _loadJPRoot(context);
                }
                Navigator.pushNamed(context, '/offlineSearch');
              }
            } else {
              Scaffold.of(context).showSnackBar(new SnackBar(
                  content:
                      new Text("Please enter in a query before searching.")));
            }
          },
          //anonymous function deeming whether there is sufficient information to search,
          tooltip: 'Search',
          child: new Icon(Icons.search),
        );
      }),
    );
  }
}

///A helper class that creates transition effects between pages.
class CustomRoute<T> extends MaterialPageRoute<T> {
  CustomRoute({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    if (settings.name == initialRouteName) {
      return child;
    }
    return new SlideTransition(
      position:
          new Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
              .animate(animation),
      child: child,
    );
  }
}
