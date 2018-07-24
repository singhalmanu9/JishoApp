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
  static TextEditingController searchBarController =
      new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
          child: new Padding(padding: new EdgeInsets.fromLTRB(0.0, 90.0, 0.0, 0.0) ,child:new Column(
              mainAxisAlignment: MainAxisAlignment.start,
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
          ]))),
      floatingActionButton: new Builder(builder: (context){return new FloatingActionButton(
        onPressed: ()
    {
    if (searchBarController.text.length > 0) {
    Navigator.pushNamed(context, '/defaultSearch');
    } else {
    Scaffold.of(context).showSnackBar(new SnackBar(
    content: new Text("Please enter in a query before searching.")));
    }
    }, //anonymous function deeming whether there is sufficient information to search,
        tooltip: 'Search',
        child: new Icon(Icons.search),
      );}),
    );
  }
}
