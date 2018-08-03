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
                      height: 300.0,
                      child: new GridView(
                        gridDelegate:
                            new SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                        ),
                        children: radicalButtons == null
                            ? <Widget>[Text("Loading")]
                            : radicalButtons,
                      )))
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

  void generateRadButtons() {
    List<Widget> _radButtons = new List<Widget>();
    List<List<PopupMenuItem>> _popupList = new List<List<PopupMenuItem>>();
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
    //generate popupList
    for (int i = 0; i < 15 /*strokeMapJSON.length*/; i++) {
      _popupList.add(new List<PopupMenuItem>());
      for (int j = 0; j < strokeMapJSON[strokeVals[i]].length; j++) {
        _popupList[i].add(
          new PopupMenuItem(
              child: new Container(
                  decoration: new BoxDecoration(
                    image: new DecorationImage(
                        image: new AssetImage('assets/drawable/r' +
                            (strokeMapJSON[strokeVals[i]][j].toString())
                                .codeUnitAt(
                                    0) 
                                .toRadixString(16) +
                            '.png'),
                        fit: BoxFit.fill),
                  ),
                  child: new FlatButton(
                    onPressed: (() {
                      addOrDeleteRadical(String.fromCharCode(
                          (strokeMapJSON[strokeVals[i]][j].toString())
                              .codeUnitAt(0)));
                    }),
                    child: null,
                  ))),
        );
      }
    }
    for (int i = 0; i < 15 /*strokeMapJSON.length*/; i++) {
      _radButtons.add(new PopupMenuButton(
          itemBuilder: (buildContext) {
            return _popupList[i];
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
