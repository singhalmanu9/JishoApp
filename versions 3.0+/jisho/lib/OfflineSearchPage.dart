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
import 'package:flutter_app/KanaConverters/RomanKanaConverter.dart' as convert;

class OfflineSearchPage extends StatefulWidget {
  String searchTextField;
  bool romajiOn = false;
  static Trie JPRoot;
  static Trie ENRoot;

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
    var context = _context;

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
        return new Scaffold(
            appBar: new AppBar(title: new Text("Search Results")),
            body: new Builder(builder: (BuildContext context) {
              _context = context;
              return new Padding(
                  padding: new EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
                  child: new ListView(children: _defWidgets));
            }));
      } else {
        return new Scaffold(
            appBar: new AppBar(title: new Text("Search Results")),
            body: new Padding(
              padding:
                  new EdgeInsets.symmetric(vertical: 30.0, horizontal: 10.0),
              child: new Text("Loading Query"),
            ));
      }
    } else {
      return new Scaffold(
          appBar: new AppBar(title: new Text("Search Results")),
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
    String mode;
    Trie root;
    loadInAuxMaps();
    String transliteration = convert.transliterate(searchTextField);

    if (convert.cleanTransliteration(transliteration)) {
      mode = "JP";
      if (OfflineSearchPage.JPRoot == null) {
        await loadJPRoot();
      }
      searchTextField = transliteration;
      root = OfflineSearchPage.JPRoot;
    } else {
      mode = "EN";
      if (OfflineSearchPage.ENRoot == null) {
        await loadENRoot();
      }
      root = OfflineSearchPage.ENRoot;
    }
    List<Answer> answers =
        await OfflineModeUtils.searchTrie(searchTextField, root, mode);
    //TODO build widgets based off of answers...
    //Make text look nice
    //Link up Kanji when possible.
    answers.forEach((Answer a) {
      Column JPSubWidget = getJapaneseSubWidget(a);
      Column ENSubWidget = getEnglishSubWidget(a);
      Widget CommonWidget = getCommonWidget(a);
      setState(() {
        if (CommonWidget != null) {
          _defWidgets.add(new Row(
              children: [CommonWidget], mainAxisSize: MainAxisSize.min));
        }
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
        print(m['misc']);
        print(OfflineSearchPage.misc);
        print(OfflineSearchPage.misc[m['misc']]);
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
