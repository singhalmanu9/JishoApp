import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';

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
  Set<String> selectedSet;

  ///the set of kanji that contain each radical in selectedSet.
  Set<String> conditionedKanji;

  ///the list of kanji that corresponds to conditionedKanji; used to get access to list operations.
  List<String> condText;

  ///the List of Buttons corresponding to the kanji present in conditionedKanji
  List<Widget> conditionedButtons;

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
    generateRadButtons();
    if (selectedSet == null) {
      setState(() {
        selectedSet = new Set();
      });
    }
    if (conditionedKanji == null) {
      setState(() {
        conditionedKanji = new Set();
        condText = new List();
      });
    }
    if (conditionedButtons == null) {
      setState(() {
        conditionedButtons = new List();
      });
    }
    if (strokeMapJSON == null || radicalMapJSON == null) {
      getMaps();
    }
    Text lengthMessage = new Text(conditionedButtons.length == 0
        ? "If the desired kanji is not present, refine the search by adding more radicals."
        : "");
    return new Scaffold(
        body: new Padding(
            padding: EdgeInsets.fromLTRB(
                20.0, 40.0, 20.0, 25.0), //TODO these are obviously guesstimates
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
              new ListView(
                scrollDirection: Axis.horizontal,
                children: conditionedButtons,
              ),
              new GridView(
                gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                ),
                children: radicalButtons,
              )
            ])));
  }

  void generateRadButtons() {
    List<Widget> _radButtons = new List();
    for (int i = 1; i < strokeMapJSON.length; i++) {
      if (i < 15 || i > 16) {
        //bypass stroke numbers without radicals (and stroke # images)
        _radButtons.add(new Image(
            image: new AssetImage(
                'assets/drawable/stroke' + i.toString() + '.png')));
        for (int j = 0; j < (strokeMapJSON[i] as List).length; i++) {
          _radButtons.add(new CheckedPopupMenuItem(
              child: new Image(
                  image: new AssetImage('assets/drawable/r' +
                      (strokeMapJSON[i][j].toString())
                          .codeUnitAt(
                              0) //TODO possibly change this if codeUnitAt doesn't give correct unicode
                          .toString())))); //TODO add visual feedback to checked items (that stays after push)
        }
      }
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
      });
    });
  }

  ///FUNCTIONS FOR SETS
  ///Adds a radical to selectedSet and computes what is to be displayed.
  void addRadical(String rad) {
    Set radSet = new Set();
    radSet.addAll(radicalMapJSON[rad]);
    setState(() {
      //TODO GET THIS OFF OF THE UI THREAD
      selectedSet.add(rad);
      if (conditionedKanji.length != 0) {
        conditionedKanji.intersection(radSet);
      } else {
        conditionedKanji = radSet;
      }
      conditionedButtons.addAll(makeConditionedButtons());
    });
  }

  ///Deletes a radical from selectedSet
  void deleteRadical(String rad) {
    Iterator selectedIter = selectedSet.iterator;
    setState(() {
      //TODO GET THIS OFF OF THE UI THREAD
      selectedSet.remove(rad);
      conditionedKanji.clear();
      conditionedKanji.addAll(selectedIter.current);
    });
    selectedIter.moveNext();
    for (int x = 1; x < selectedSet.length; x++) {
      addRadical(selectedIter.current);
      selectedIter.moveNext();
    }
  }

  List<Widget> makeConditionedButtons() {
    List<Widget> condButtons = new List<Widget>((100 < conditionedKanji.length
        ? 100
        : conditionedKanji
            .length)); //set max size to 100, for the sake of the UI.
    setState(() => condText = conditionedKanji.toList(growable: false));
    //TODO try to find a pragma omp equiv??
    for (int i = 0; i < condButtons.length; i++) {
      condButtons[i] = new MaterialButton(
        onPressed: () => addToSearchBar(condText[i]),
        child: new Text(condText[i]),
      );
      //TODO can see this failing to work correctly
    }
    return condButtons;
  }

  void addToSearchBar(String kanji) {
    //TODO works in theory, may not work in practice. we'll see.
    setState(() {
      searchBarController.text = searchBarController.text + kanji;
    });
  }
}
