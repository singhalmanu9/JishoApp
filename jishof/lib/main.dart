import 'package:flutter/material.dart';
import 'package:flutter_app/SearchPage.dart';

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
    return new Scaffold(
      body: new Center(
          child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
            new Image(
              image: new AssetImage('assets/drawable/download.png'),
              width: 264.0,
              height: 128.0,
            ),
            new Padding(
                padding:
                    new EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
                child: new TextField(
                  decoration: const InputDecoration(
                      border: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0x00000000))),
                      labelText: "Type your query here:"),
                  textAlign: TextAlign.left,
                  controller: searchBarController,
                )),
          ])),
      floatingActionButton: new FloatingActionButton(
        onPressed: _search,
        tooltip: 'Search',
        child: new Icon(Icons.search),
      ),
    );
  }
}
