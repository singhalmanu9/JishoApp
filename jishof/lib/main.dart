import 'package:flutter/material.dart';
import 'package:flutter_app/SearchPage.dart';
import 'package:flutter_app/AboutPage.dart';
import 'package:flutter_app/RadicalPage.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Jisho',
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
        routes: <String, WidgetBuilder>{
          '/defaultSearch': (BuildContext context) =>
              new DefaultSearchPage(_MyHomePageState.searchBarController.text.toLowerCase(), _MyHomePageState.romajiOn),
          '/about': (BuildContext context) => new AboutPage(),
          '/radical': (BuildContext context) => new RadicalPage(),
          '/radical/defaultSearch': (BuildContext context) =>
              new DefaultSearchPage(RadicalPage.getSearchBarController().text, _MyHomePageState.romajiOn),
        });
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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
          child: new Padding(
              padding: new EdgeInsets.fromLTRB(0.0, 90.0, 0.0, 0.0),
              child: new Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Image(
                      image: new AssetImage('assets/drawable/download.png'),
                      width: 264.0,
                      height: 128.0,
                    ),
                    new Padding(
                        padding: new EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 40.0),
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
                            onChanged: (bool value) => setState((){_MyHomePageState.romajiOn = value;})
                        )
                    ),
                    new Text(
                      "To translate E -> J, surround with \"  \".",
                      textAlign: TextAlign.center,
                      textScaleFactor: 1.25,
                      style: new TextStyle(color: Colors.black54),
                    ),
                    new Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 0.0),
                        child: new Container(
                          child: new FlatButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/radical'),
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
                            vertical: 35.0, horizontal: 0.0),
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
                        ))
                  ]))),
      floatingActionButton: new Builder(builder: (context) {
        return new FloatingActionButton(
          onPressed: () {
            if (searchBarController.text.length > 0) {
              Navigator.pushNamed(context, '/defaultSearch');
            } else {
              Scaffold.of(context).showSnackBar(new SnackBar(
                  content:
                      new Text("Please enter in a query before searching.")));
            }
          }, //anonymous function deeming whether there is sufficient information to search,
          tooltip: 'Search',
          child: new Icon(Icons.search),
        );
      }),
    );
  }
}
