import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/OfflineModeUtils.dart';
import 'package:flutter_app/main.dart';
import 'dart:async';
import 'dart:convert';
import 'romanizer.dart' as romanizer;
import 'package:flutter_app/OfflineModeUtils.dart';
import 'Trie.dart';
import 'Answer.dart';

class OfflineSearchPage extends StatefulWidget {
  String searchTextField;
  bool romajiOn = false;
  static Trie JPRoot;
  static Trie ENRoot;
  static Map answerMap;
  static Set<String> _searchKanji;
  OfflineSearchPage(String searchTextField, bool romajiOn) {
    this.searchTextField = searchTextField;
    this.romajiOn = romajiOn;
    _searchKanji = Set();
  }

  static void setKanji(Set<String> kanjiList) {
    _searchKanji.addAll(kanjiList);
  }

  static Set<String> getKanjiList() {
    return _searchKanji;
  }

  @override
  _OfflineSearchPageState createState() =>
      new _OfflineSearchPageState(searchTextField, romajiOn);




}

class _OfflineSearchPageState extends State<OfflineSearchPage> {
  List<Widget> _defWidgets = <Widget>[];
  String searchTextField;
  bool fullQuery;
  bool romajiOn;
  static Key scaffold;
  static BuildContext _context;

  static copyDialogue(String copiedWord) {
    var context = _context;
    print(context);
    Scaffold.of(_context).showSnackBar(new SnackBar(
        content: new Text("copied \"" + copiedWord + "\" to clipboard")));
  }
  _OfflineSearchPageState(String searchTextField, bool romajiOn) {
    this.searchTextField = searchTextField;
    this.romajiOn = romajiOn;
    this.romajiOn = romajiOn;
  }

  @override
  Widget build(BuildContext context) {

    if (fullQuery) {

      if (_defWidgets.length > 0) {
        return new Scaffold(appBar: new AppBar(title: new Text("Search Results")),body: new Builder(builder: (BuildContext context) {
          _context = context;
          return new Padding(
              padding: new EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
              child: new ListView(children: _defWidgets));
        }));
      } else {
        return new Scaffold(appBar: new AppBar(title: new Text("Search Results")),
            body: new Padding(
              padding: new EdgeInsets.symmetric(vertical: 30.0, horizontal: 10.0),
              child: new Text("Loading Query"),
            ));
      }
    } else {
      return new Scaffold(appBar: new AppBar(title: new Text("Search Results")),
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
    loadInDefinitions();

  }
  void loadInDefinitions() async{
    String mode;
    Map answerMap = OfflineSearchPage.answerMap;
    Trie root;
    if(romajiOn) { //TODO this isn't right. need to test the input string to see of it's kana-izable or if it has quotes
      mode = "JP";
      if (OfflineSearchPage.JPRoot == null) {
        print("ASDF:LK");
        await loadJPRoot();
      }
      root = OfflineSearchPage.JPRoot;
    } else {
      mode = "EN";
      print("ASDLGKJ");
      if (OfflineSearchPage.ENRoot == null) {
        print("ASDLFKJT");
        await loadENRoot();
      }
      root = OfflineSearchPage.ENRoot;
    }
    List<Answer> answers = await OfflineModeUtils.searchTrie(searchTextField, root, mode, answerMap);
    //TODO build widgets based off of answers...
    //Make text look nice
    //Link up Kanji when possible.
    answers.forEach((Answer a) {
      Column JPSubWidget = getJapaneseSubWidget(a);
      Column ENSubWidget = getEnglishSubWidget(a);
      setState(() {
        _defWidgets.add(JPSubWidget);
        _defWidgets.add(ENSubWidget);
        fullQuery = true;
      });
      //set state
    });
    if (_defWidgets.length == 0) {
      setState(() {
        fullQuery = false;
      });
    }
  }
  Column getEnglishSubWidget(Answer a) {
    List<Widget> structuredDefs = List();
    a.defs.forEach((Map m) {
      if (m.containsKey('pos'))
        if(m['pos'].length > 0) {
        List<Widget> PoSRow = List();
        if (m['pos'].length != 0) {
          m['pos'].forEach(( s) {
            PoSRow.add(
                Text(s, textScaleFactor: .6,)); //TODO double check scale factor
                print(s);
          });
        }
        structuredDefs.add(new Row(crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          textDirection: TextDirection.ltr,
          children: PoSRow,));
      }
      if (m.containsKey('definition')){
        structuredDefs.add(new Text(m['definition']));
      }
    });
    return new Column(crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        textDirection: TextDirection.ltr,
        children:structuredDefs);
  }

   Column getJapaneseSubWidget(Answer a) {
    Widget mainFormReadingText = new Text(
      a.kanaStr,
      textScaleFactor: 1.5,
    );

    Widget mainFormReading = new InkWell(
        onLongPress: () {
          Clipboard.setData(ClipboardData(
              text: a.kanaStr));
              _OfflineSearchPageState.copyDialogue(
              a.kanaStr);
        },
        child: mainFormReadingText);
    Widget mainFormWordText = new Text(
      a.kanjiStr,
      textScaleFactor: 3.0,
    );
    Widget mainFormWord = new InkWell(
        onTap: () {
          Set<String> searchKanji = new Set();
          for (String c in a.kanjiStr.split('')) {
            if (!romanizer.kanaToRomaji.containsKey(c)) {
              searchKanji.add(c);
            }
          }
          OfflineSearchPage.setKanji(searchKanji);
          Navigator.pushNamed(context, '/offlineSearch/kanjiInfo');
        },
        onLongPress: () {
          Clipboard.setData(ClipboardData(
              text: a.kanjiStr));
          _OfflineSearchPageState
              .copyDialogue(a.kanjiStr);
        },
        child: mainFormWordText); //TODO make this look pretty

    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      textDirection: TextDirection.ltr,
      children: <Widget>[
        mainFormReading,
        mainFormWord,      ],
    );
  }


}