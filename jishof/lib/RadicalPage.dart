import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';


//TODO get Navigator route added somewhere... google this.
class RadicalPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _RadicalPageState();
  }
}

class _RadicalPageState extends State<RadicalPage> {
  ///gives access to the search bar.
  static TextEditingController searchBarController =
      new TextEditingController();

  ///Map of kanji that have the key 'radical' present within them.
  Map radicalMapJSON;

  ///Map of kanji that are written with 'key' strokes.
  Map strokeMapJSON;

  /// the set of radicals currently selected.
  Set<String> selectedSet = new Set<String>();

  ///the set of kanji that contain each radical in selectedSet.
  Set<String> conditionedKanji = new Set<String>();

  ///the list of kanji that corresponds to conditionedKanji; used to get access to list operations.
  List<String> condText = new List<String>();

  ///the List of Buttons corresponding to the kanji present in conditionedKanji
  List<Widget> conditionedButtons = new List<Widget>();

  ///a List of Buttons of radicals ordered by their strokes
  /// (and buttons with stroke numbers preceeding them)
  List<Widget> radicalButtons;

  List<Widget> currRadicals;
  String currRadStroke = "0";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if (strokeMapJSON == null || radicalMapJSON == null) {
      getMaps();
    }
    Text lengthMessage = new Text(conditionedButtons.length != 0
        ? "If the desired kanji is not present, refine the search by adding more radicals."
        : "");
    return new Scaffold(
        body: new Padding(
            padding: EdgeInsets.fromLTRB(
                20.0, 40.0, 20.0, 5.0), //TODO these are obviously guesstimates
            child: new Column(children: <Widget>[
              new TextField(
                decoration: const InputDecoration(
                    border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0x00000000))),
                    labelText: "Type your query here:"),
                textAlign: TextAlign.left,
                controller: searchBarController,
              ),
              lengthMessage,
              new Container(
                  height: 100.0,
                  child: new ListView(
                    scrollDirection: Axis.horizontal,
                    children: conditionedButtons,
                  )),
              new Padding(
                  padding: EdgeInsets.symmetric(horizontal:20.0),
                  child: Container(
                      height: 250.0,
                      child: new GridView(
                        gridDelegate:
                            new SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                        ),
                        children: radicalButtons == null
                            ? <Widget>[Text("Loading")]
                            : radicalButtons,
                      ))),
              new Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  height: 200.0,
                  child: currRadicals == null ?
                  new Text("Select radicals to be displayed") :
                  new GridView(
                      gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 8),
                    children: currRadicals,
                  ),
                )
              )
            ])),
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
        }));
  }

  void setCurrentRadical(String strokeNum) {
    List<String> bads = ['5316', '4e2a', '5e76', '5208', '4e5e', '8fbc', '5c1a',
      '5fd9', '624e', '6c41', '72af', '827e', '90a6', '9621', '8001', '6770',
      '793c', '521d', '7594', '6ef4'];
    if (currRadStroke == "0" || currRadStroke != strokeNum) {
      currRadStroke = strokeNum;
      currRadicals = new List<Widget>();
      for (int i = 0; i < strokeMapJSON[strokeNum].length; i++) {
        try {
          String c = strokeMapJSON[strokeNum.toString()][i].toString().codeUnitAt(0).toRadixString(16).toLowerCase();
          if (bads.contains(c)) {
            currRadicals.add(new GridTile(
//              child: new Text(strokeMapJSON[strokeNum.toString()][i].toString(),
//                style: new TextStyle(fontSize: 32.0),
//              ),
            child: new Image.asset('assets/drawable/r' +
                c +
                '.png'),
            ));
          } else {
            currRadicals.add(new GridTile(
              child: new Text(strokeMapJSON[strokeNum.toString()][i].toString(),
                style: new TextStyle(fontSize: 36.0),
              ),
//              child: new Image.asset('assets/drawable/r' +
//                  c +
//                  '.png'),
            ));
          }
        } catch (e) {
//          currRadicals.add(new GridTile(
//            child: new Text(strokeMapJSON[strokeNum.toString()][i].toString(),
//              style: new TextStyle(fontSize: 32.0),
//            ),
//          ));
          print(e.toString());
        }
      }
    } else {
      currRadicals = null;
      currRadStroke = "0";
    }
  }

  void generateRadButtons() {
    List<Widget> _radButtons = new List<Widget>();
    List<String> strokeVals = [
      "1",
      "2",
      "3",
      "4",
      "5",
      "6",
      "7",
      "8",
      "9",
      "10",
      "11",
      "12",
      "13",
      "14",
      "17"
    ];
    for (int i = 0; i < 15 /*strokeMapJSON.length*/; i++) {
      _radButtons.add(new FlatButton(
        onPressed: () {
          setState(() => setCurrentRadical(strokeVals[i]));
        },
        child: new Image.asset(
            'assets/drawable/stroke' + strokeVals[i] + '.png')));
    }
    setState(() {
      radicalButtons = _radButtons;
    });
  }

  void getMaps() {
    DefaultAssetBundle
        .of(context)
        .loadString('assets/json_files/radicalMap')
        .then((radMap) {
      setState(() {
        radicalMapJSON = json.decode(radMap);
      });
    });

    DefaultAssetBundle
        .of(context)
        .loadString('assets/json_files/strokeMap')
        .then((strokeMap) {
      setState(() {
        strokeMapJSON = jsonDecode(strokeMap);
        generateRadButtons();
      });
    });
  }

  ///FUNCTIONS FOR SETS
  ///Adds a radical to selectedSet and computes what is to be displayed.
  void addRadical(String rad) {
    Set radSet = new Set<String>();
    List<String> aw = radicalMapJSON[rad].cast<String>();
    radSet.addAll(aw);

    //TODO GET THIS OFF OF THE UI THREAD
    selectedSet.add(rad);
    if (conditionedKanji.length != 0) {
      conditionedKanji.intersection(radSet);
    } else {
      conditionedKanji = radSet;
    }
    setState(() {
      conditionedButtons.addAll(makeConditionedButtons());
    });
  }

  ///Deletes a radical from selectedSet
  void deleteRadical(String rad) {
    List selectedIter = selectedSet.toList();
    setState(() {
      //TODO GET THIS OFF OF THE UI THREAD
      print(selectedSet.remove(rad));
      print(conditionedButtons.length);
      conditionedKanji.clear();
    });
    for (int i = 0; i < selectedSet.length; i++) {
      addRadical(selectedIter[i]);
    }
  }

  void addOrDeleteRadical(String rad) {
    setState(() {
      conditionedButtons.clear();
    });

    if (selectedSet.contains(rad)) {
      print("cleared conditionedButtons");
      deleteRadical(rad);
    } else {
      addRadical(rad);
    }
  }

  List<Widget> makeConditionedButtons() {
    List<Widget> condButtons = new List<Widget>((50 < conditionedKanji.length
        ? 50
        : conditionedKanji
            .length)); //set max size to 100, for the sake of the UI.
    condText = conditionedKanji.toList(growable: false);
    for (int i = 0; i < condButtons.length; i++) {
      condButtons[i] = new FlatButton(
        onPressed: () => addToSearchBar(condText[i]),
        child: new Text(condText[i]),
      );
      //TODO can see this failing to work correctly
    }
    print(condButtons.length);
    return condButtons;
  }

  void addToSearchBar(String kanji) {
    //TODO works in theory, may not work in practice. we'll see.
    setState(() {
      searchBarController.text = searchBarController.text + kanji;
    });
  }
}
