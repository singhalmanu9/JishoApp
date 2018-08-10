import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';


//TODO get Navigator route added somewhere... google this.
class RadicalPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return new _RadicalPageState();
  }
  static TextEditingController getSearchBarController() {
    var x = _RadicalPageState.searchBarController;
    return x;
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
    if (strokeMapJSON == null || radicalMapJSON == null) {
      getMaps();
    }
    Text lengthMessage = new Text(selectedSet.length != 0 ?
      'current radicals: ' + selectedSet.toString().substring(1, selectedSet.toString().length-1) : 'Input some radicals!');
    return new Scaffold(
        body: new Padding(
            padding: EdgeInsets.fromLTRB(
                20.0, 40.0, 20.0, 5.0),
            child: new Column(children: <Widget>[
              new TextField(
                decoration: const InputDecoration(
                    border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0x00000000))),
                    labelText: "Type your query here:"),
                textAlign: TextAlign.left,
                controller: searchBarController,
              ),
              new Padding(
                padding : EdgeInsets.all(10.0),
                child: lengthMessage
              ),
              new Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: new Container(
                  height: 50.0,
                  child: new ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, int index) {
                      return index < conditionedButtons.length ? conditionedButtons[index] : null;
                    }
                  ))
              ),
              new Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Container(
                  height: 200.0,
                  child: currRadicals == null ?
                    new Text("Select radicals to be displayed") :
                    new GridView(
                      gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        mainAxisSpacing: 0.0
                      ),
                      children: currRadicals,
                  ),
                )
              ),
              new Padding(
                padding: EdgeInsets.symmetric(horizontal:10.0),
                child: Container(
                    height: 250.0,
                    child: new GridView(
                      gridDelegate:
                          new SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            mainAxisSpacing: 0.0
                          ),
                      children: radicalButtons == null
                          ? <Widget>[Text("Loading")]
                          : radicalButtons,
                    ))),

            ])),
        floatingActionButton: new Builder(builder: (context) {
          return new FloatingActionButton(
            onPressed: () {
              if (searchBarController.text.length > 0) {
                Navigator.pushNamed(context, '/radical/defaultSearch');
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
        String c = strokeMapJSON[strokeNum.toString()][i].toString().codeUnitAt(0).toRadixString(16).toLowerCase();
        if (bads.contains(c)) {
          currRadicals.add(new GridTile(
            child: new RaisedButton(
              color: selectedSet.contains(strokeMapJSON[strokeNum.toString()][i].toString()) ? Colors.green : Colors.white,
              onPressed: () {
                setState(() => addOrDeleteRadical(strokeMapJSON[strokeNum.toString()][i].toString()));
              },
              child: new Image.asset(
                'assets/drawable/r' + c + '.png',
                fit: BoxFit.contain,
              ),
            ),
          ));
        } else {
          currRadicals.add(new GridTile(
              child: new RaisedButton(
                color: selectedSet.contains(strokeMapJSON[strokeNum.toString()][i].toString()) ? Colors.green : Colors.white,
                onPressed: () {
                  setState(() => addOrDeleteRadical(strokeMapJSON[strokeNum.toString()][i].toString()));
                },
                child: new Text(strokeMapJSON[strokeNum.toString()][i].toString(),
                  style: new TextStyle(fontSize: 28.0),
                ),
              )
          ));
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
      _radButtons.add(new RaisedButton(
        onPressed: () {
          setState(() => setCurrentRadical(strokeVals[i]));
        },
        child: new Text(strokeVals[i], style: new TextStyle(fontSize: 28.0, color: Colors.black))));
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
      conditionedKanji = conditionedKanji.intersection(radSet);
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
      selectedSet.remove(rad);
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
      deleteRadical(rad);
    } else {
      addRadical(rad);
    }
  }

  List<Widget> makeConditionedButtons() {
    List<Widget> condButtons = new List<Widget>(math.min(50, conditionedKanji.length)); //set max size to 50, for the sake of the UI.
    condText = conditionedKanji.toList();
    for (int i = 0; i < condButtons.length; i++) {
      condButtons[i] = new RaisedButton(
        onPressed: () => setState(() => addToSearchBar(condText[i])),
        color: Theme.of(context).accentColor,
        child: new Text(condText[i], style: TextStyle(fontSize: 24.0)),
      );
    }
    return condButtons;
  }

  void addToSearchBar(String kanji) {
    setState(() {
      searchBarController.text = searchBarController.text + kanji;
    });
  }
}
