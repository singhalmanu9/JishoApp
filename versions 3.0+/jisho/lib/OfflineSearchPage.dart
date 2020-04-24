import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/OfflineModeUtils.dart';
import 'package:flutter_app/main.dart';

import 'dart:convert';
import 'romanizer.dart' as romanizer;

import 'Trie.dart';
import 'Answer.dart';
import 'package:flutter_app/KanaConverters/RomanKanaConverter.dart' as convert;

class OfflineSearchPage extends StatefulWidget {
  String searchTextField;
  bool romajiOn = false;
  static Trie jpRoot;
  static Trie enRoot;

  static Map pos;
  static Map fields;
  static Map dialects;
  static Map misc;
  static Map rInf;

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
    return new Scaffold(
        appBar: new AppBar(title: new Text("Search Results")),
        body: new Builder(builder: (BuildContext context) {
          _context = context;
          return new Padding(
              padding: new EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
              child: new ListView(children: _defWidgets));
        }));
  }

  @override
  void initState() {
    super.initState();
    fullQuery = true;
    loadInDefinitions();
  }




  void loadMisc() async {
    if (OfflineSearchPage.misc == null) {
      OfflineSearchPage.misc = jsonDecode(
          await rootBundle.loadString('assets/json_files/miscInfo.json'));
    }
  }

  void loadRInf() async {
    if (OfflineSearchPage.rInf == null) {
      OfflineSearchPage.rInf = jsonDecode(
          await rootBundle.loadString('assets/json_files/readingInfo.json'));
    }
  }

  void loadDialects() async {
    if (OfflineSearchPage.dialects == null) {
      OfflineSearchPage.dialects = jsonDecode(
          await rootBundle.loadString('assets/json_files/dialectInfo.json'));
    }
  }

  void loadFields() async {
    if (OfflineSearchPage.fields == null) {
      OfflineSearchPage.fields = jsonDecode(
          await rootBundle.loadString('assets/json_files/fieldUsage.json'));
    }
  }
  void loadPos() async {
    if (OfflineSearchPage.pos == null) {
      OfflineSearchPage.pos = jsonDecode(
          await rootBundle.loadString('assets/json_files/partOfSpeech.json'));
    }
  }
  void loadInAuxMaps() async {
    loadMisc();
    loadRInf();
    loadDialects();
    loadFields();
    loadPos();
  }

  void loadInDefinitions() async {
    setState(() {
      _defWidgets.add(new Text("Loading Query"));
    });
    String mode;
    Trie root;
    loadInAuxMaps();
    String transliteration = convert.transliterate(searchTextField);

    if (convert.cleanTransliteration(transliteration)) {
      mode = "JP";
      if (OfflineSearchPage.jpRoot == null) {
         loadJPRoot();
      }
      searchTextField = transliteration;
      root = OfflineSearchPage.jpRoot;
    } else {
      mode = "EN";
      if (OfflineSearchPage.enRoot == null) {
        loadENRoot();
      }
      if (searchTextField.substring(0,1) == '"' && searchTextField.substring(searchTextField.length - 1) == '"') {
        searchTextField = searchTextField.substring(1,searchTextField.length - 1);
      }
      root = OfflineSearchPage.enRoot;
    }
    List<Answer> answers =
        await OfflineModeUtils.searchTrie(searchTextField, root, mode);

    List<Widget> defWidgets = List();
    answers.forEach((Answer a) {
      Column jpSubWidget = getJapaneseSubWidget(a);
      Column enSubWidget = getEnglishSubWidget(a);
      Widget commonWidget = getCommonWidget(a);
        if (commonWidget != null) {
          defWidgets.add(new Row(
              children: [commonWidget], mainAxisSize: MainAxisSize.min));
        }
        defWidgets.add(jpSubWidget);
        defWidgets.add(enSubWidget);
        fullQuery = true;
    });
    if (defWidgets.length == 0) {
      setState(() {
        fullQuery = false;
        _defWidgets = [new Text("Query had no results.")];
      });
    } else {

      setState(() {
        _defWidgets = defWidgets;
      });
    }
  }

  Widget getCommonWidget(Answer a) {
    Paint isCommonPaint =
        new Paint(); //TODO refactor out of both search pages and put as static somewhere else.
    isCommonPaint.color = new Color(0x8abc83);
    if (a.common) {
      return new Container(
        child: new Text('common',
            style:
                new TextStyle(color: Colors.white, background: isCommonPaint)),
        decoration: new BoxDecoration(
          borderRadius: new BorderRadius.all(new Radius.circular(10.0)),
          color: new Color(0xff8abc83),
        ),
        padding: new EdgeInsets.all(3.0),
      );
    }
    return null;
  }

  Column getEnglishSubWidget(Answer a) {
    List<Widget> structuredDefs = List();
    int def_ct = 1;
    a.defs.forEach((Map m) {
      if (m.containsKey('pos') && m['pos'] != null && m['pos'].length > 0) {
        List<Widget> PoSRow = List();
        if (m['pos'].length != 0) {
          //TODO get the long form
          m['pos'].forEach((s) {
            PoSRow.add(Text(
              OfflineSearchPage.pos[s],
              style: new TextStyle(color: Colors.black87),
            )); //TODO double check scale factor
          });
        }
        structuredDefs.add(new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          textDirection: TextDirection.ltr,
          children: PoSRow,
        ));
      }
      //field,misc,rInfo,dialInfo
      List<TextSpan> defChildren = List();

      if (m.containsKey('definition') && m['definition'] != null) {
        defChildren.add(new TextSpan(
            text: def_ct.toString() + ". " + m['definition'],
            style: new TextStyle(color: Colors.black)));
      }
      if (m.containsKey('rInfo') &&m['rInfo'] != null && m['rInfo'].length > 0) {
        m['rInfo'].forEach((t) {
          defChildren.add(new TextSpan(
              text: ' ' + OfflineSearchPage.rInf[t] + ".",
              style: new TextStyle(color: Colors.black54)));
        });
      }
      if (m.containsKey('misc') && m['misc'] != null) {
        defChildren.add(new TextSpan(
            text: " " + OfflineSearchPage.misc[m['misc']] + ".",
            style: new TextStyle(color: Colors.black54)));
      }
      if (m.containsKey('field') &&m['field'] != null) {
        defChildren.add(new TextSpan(
            text: ' ' + OfflineSearchPage.fields[m['field']] + ".",
            style: new TextStyle(color: Colors.black54)));
      }
      if (m.containsKey('dialInfo') &&m['dialInfo'] != null) {
        defChildren.add(new TextSpan(
            text: ' ' + OfflineSearchPage.dialects[m['dialInfo']] + ".",
            style: new TextStyle(color: Colors.black54)));
      }
      structuredDefs
          .add(new RichText(text: new TextSpan(children: defChildren)));
      def_ct++;
    });
    return new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        textDirection: TextDirection.ltr,
        children: structuredDefs);
  }

  Column getJapaneseSubWidget(Answer a) {
    Widget mainFormReadingText = new Text(
      a.kanaStr,
      textScaleFactor: 1.2,
    );
    Widget mainFormReading = new InkWell(
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: a.kanaStr));
          _OfflineSearchPageState.copyDialogue(a.kanaStr);
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
          Clipboard.setData(ClipboardData(text: a.kanjiStr));
          _OfflineSearchPageState.copyDialogue(a.kanjiStr);
        },
        child: mainFormWordText); //TODO make this look pretty
    if ("".compareTo(a.kanaStr) != 0) {
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

    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      textDirection: TextDirection.ltr,
      children: <Widget>[
        mainFormWord,
      ],
    );
  }
}
