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
  /// The string corresponding to a user's query.
  String searchTextField;

  /// The boolean corresponding to whether a user has selected to see romanized
  /// versions of the Japanese part of search results.
  bool romajiOn = false;

  /// The root of the Japanese Trie. This is used for searches in OfflineModeUtils.
  /// This Trie will not be loaded until a Japanese query is made.
  static Trie jpRoot;

  /// The root of the English Trie. This is used for searched in OfflineModeUtils.
  /// This Trie will not be loaded until an English query is made.
  static Trie enRoot;

  /// Mapping of short forms used in Answer blobs to their
  /// corresponding long forms.
  static Map pos, fields, dialects, misc, rInf;

  ///  The set of Kanji that will be used when viewing the RadicalPage.
  ///  This will only be populated upon a user tapping the Kanji field of an
  ///  Answer.
  static Set<String> _searchKanji;

  /// An initializer of the OfflineSearchPage with a user's query and their
  /// selection of whether to display romanization.
  OfflineSearchPage(String searchTextField, bool romajiOn) {
    this.searchTextField = searchTextField;
    this.romajiOn = romajiOn;
    _searchKanji = Set();
  }

  /// A helper function to population _searchKanji from a widget.
  static void setKanji(Set<String> kanjiList) {
    _searchKanji.addAll(kanjiList);
  }

  /// Public accessor for _searchKanji.
  static Set<String> getKanjiList() {
    return _searchKanji;
  }

  @override
  _OfflineSearchPageState createState() =>
      new _OfflineSearchPageState(searchTextField, romajiOn);
}

class _OfflineSearchPageState extends State<OfflineSearchPage> {
  /// The list of Widgets corresponding to a user's query.
  List<Widget> _defWidgets = <Widget>[];

  /// The user's query
  String searchTextField;

  /// The boolean corresponding to whether a user has selected to see romanized
  /// versions of the Japanese part of search results.
  bool romajiOn;

  /// The BuildContext, used specifically for copying text to the clipboard.
  static BuildContext _context;

  /// The Method that encapsulates UI feedback and copying text.
  static copyDialogue(String copiedWord) {
    Scaffold.of(_context).showSnackBar(new SnackBar(
        content: new Text("copied \"" + copiedWord + "\" to clipboard")));
  }

  /// The initializer for the page state.
  /// user's query and their
  /// selection of whether to display romanization.
  _OfflineSearchPageState(String searchTextField, bool romajiOn) {
    this.searchTextField = searchTextField;
    this.romajiOn = romajiOn;
    this.romajiOn = romajiOn;
  }

  ///Returns the Widget objects that correspond to the User's query, if any.
  ///If no results appear for the User's query, _defWidgets will report it as
  /// such.
  /// If results are still being fetched an animation notifying the user that
  /// the results are loading will appear.
  /// The search results will appear otherwise.
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(title: new Text("Search Results")),
        body: new Builder(builder: (BuildContext context) {
          _context = context;
          return new Padding(
              padding: new EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 0.0),
              child: new ListView(children: _defWidgets));
        }));
  }

  /// Initializing state (super) and then loading in definitions asynchronously
  @override
  void initState() {
    super.initState();

    loadInDefinitions();
  }

  /// loading in the map of short forms to long forms for miscellaneous info.
  void loadMisc() async {
    if (OfflineSearchPage.misc == null) {
      OfflineSearchPage.misc = jsonDecode(
          await rootBundle.loadString('assets/json_files/miscInfo.json'));
    }
  }

  /// loading in the map of short forms to long forms for reading info.
  void loadRInf() async {
    if (OfflineSearchPage.rInf == null) {
      OfflineSearchPage.rInf = jsonDecode(
          await rootBundle.loadString('assets/json_files/readingInfo.json'));
    }
  }

  /// loading in the map of short forms to long forms for dialect info.
  void loadDialects() async {
    if (OfflineSearchPage.dialects == null) {
      OfflineSearchPage.dialects = jsonDecode(
          await rootBundle.loadString('assets/json_files/dialectInfo.json'));
    }
  }

  /// loading in the map of short forms to long forms for professional fields
  /// info.
  void loadFields() async {
    if (OfflineSearchPage.fields == null) {
      OfflineSearchPage.fields = jsonDecode(
          await rootBundle.loadString('assets/json_files/fieldUsage.json'));
    }
  }

  /// loading in the map of short forms to long forms for part of speech info.
  void loadPos() async {
    if (OfflineSearchPage.pos == null) {
      OfflineSearchPage.pos = jsonDecode(
          await rootBundle.loadString('assets/json_files/partOfSpeech.json'));
    }
  }

  /// A helper function to consolidate loading in every map.
  void loadInAuxMaps() async {
    loadMisc();
    loadRInf();
    loadDialects();
    loadFields();
    loadPos();
  }

  /// Loading in definitions. This is the meat of the offline page,
  /// computationally.
  /// This will load in the JPRoot or ENRoot depending on the query if it is not
  /// previously loaded, then it will perform the search on the corresponding
  /// Trie. After the search has been performed, Widgets will be created and
  /// populate the _defWidgets list if applicable.
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
        await loadJPRoot();
      }
      searchTextField = transliteration;
      root = OfflineSearchPage.jpRoot;
    } else {
      mode = "EN";
      if (OfflineSearchPage.enRoot == null) {
        await loadENRoot();
      }
      if (searchTextField.substring(0, 1) == '"' &&
          searchTextField.substring(searchTextField.length - 1) == '"') {
        searchTextField =
            searchTextField.substring(1, searchTextField.length - 1);
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
        defWidgets.add(
            new Row(children: [commonWidget], mainAxisSize: MainAxisSize.min));
      }
      defWidgets.add(jpSubWidget);
      defWidgets.add(enSubWidget);
    });
    if (defWidgets.length == 0) {
      setState(() {
        _defWidgets = [new Text("Query had no results.")];
      });
    } else {
      setState(() {
        _defWidgets = defWidgets;
      });
    }
  }

  /// Returns a generic Widget for the Common bubble.
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

  /// Generates any information that pertains to an English definition for an
  /// answer.
  Column getEnglishSubWidget(Answer a) {
    List<Widget> structuredDefs = List();
    int def_ct = 1;
    a.defs.forEach((Map m) {
      if (m.containsKey('pos') && m['pos'] != null && m['pos'].length > 0) {
        List<Widget> PoSRow = List();
        if (m['pos'].length != 0) {
          m['pos'].forEach((s) {
            PoSRow.add(Text(
              OfflineSearchPage.pos[s],
              style: new TextStyle(color: Colors.black87),
            )); //TODO double check scale factor
          });
        }
        Widget posRowWidget = new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          textDirection: TextDirection.ltr,
          children: PoSRow,
        );
        structuredDefs.add(addPad(posRowWidget, 8.0, 2.0, 0.0, 4.0));
      }
      //field,misc,rInfo,dialInfo
      List<TextSpan> defChildren = List();

      if (m.containsKey('definition') && m['definition'] != null) {
        defChildren.add(new TextSpan(
            text: def_ct.toString() + ". " + m['definition'],
            style: new TextStyle(color: Colors.black)));
      }
      if (m.containsKey('rInfo') &&
          m['rInfo'] != null &&
          m['rInfo'].length > 0) {
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
      if (m.containsKey('field') && m['field'] != null) {
        defChildren.add(new TextSpan(
            text: ' ' + OfflineSearchPage.fields[m['field']] + ".",
            style: new TextStyle(color: Colors.black54)));
      }
      if (m.containsKey('dialInfo') && m['dialInfo'] != null) {
        defChildren.add(new TextSpan(
            text: ' ' + OfflineSearchPage.dialects[m['dialInfo']] + ".",
            style: new TextStyle(color: Colors.black54)));
      }
      Widget defChildrenWidget =
          new RichText(text: new TextSpan(children: defChildren));
      structuredDefs.add(addPad(defChildrenWidget, 8.0, 0.0, 0.0, 5.0));
      def_ct++;
    });
    return new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        textDirection: TextDirection.ltr,
        children: structuredDefs);
  }

  /// Wraps a String in Widget objects that add onTap, onLongPress, and padding.
  Widget prepJapaneseWidgets(String textString, double textScaleFactor,
      double left, double top, double right, double bottom, bool Kanji) {
    Widget textWidget = Text(textString, textScaleFactor: textScaleFactor);
    Widget inkwell = InkWell(
      onTap: Kanji
          ? () {
              _KanjiInfoOnTap(textString);
            }
          : () {},
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: textString));
        _OfflineSearchPageState.copyDialogue(textString);
      },
      child: textWidget,
    );
    return addPad(inkwell, left, top, right, bottom);
  }

  /// Handles transitioning to the kanjiInfo page.
  void _KanjiInfoOnTap(String kanjiStr) {
    Set<String> searchKanji = new Set();
    for (String c in kanjiStr.split('')) {
      if (!romanizer.kanaToRomaji.containsKey(c)) {
        searchKanji.add(c);
      }
    }
    OfflineSearchPage.setKanji(searchKanji);
    Navigator.pushNamed(context, '/offlineSearch/kanjiInfo');
  }

  /// Creates the Japanese widgets for an Answer. This will include the
  /// romanized version of the word if romajiOn is true.
  Column getJapaneseSubWidget(Answer a) {
    Widget mainFormReading =
        prepJapaneseWidgets(a.kanaStr, 1.2, 0.0, 2.0, 2.0, 2.0, false);
    Widget mainFormWord =
        prepJapaneseWidgets(a.kanjiStr, 3.0, 0.0, 0.0, 0.0, 2.0, true);

    List<Widget> children = List();
    String toRomanize;
    if ("".compareTo(a.kanaStr) != 0) {
      children.add(mainFormReading);
      toRomanize = a.kanaStr;
    } else {
      toRomanize = a.kanjiStr;
    }
    children.add(mainFormWord);
    if (romajiOn) {
      children.add(new InkWell(
          onLongPress: () {
            var text = romanizer.romanize(toRomanize);
            Clipboard.setData(ClipboardData(text: text));
            _OfflineSearchPageState.copyDialogue(text);
          },
          child: addPad(
              Text(romanizer.romanize(toRomanize), textScaleFactor: 1.2),
              2.0,
              0.0,
              0.0,
              4.0)));
    }

    return new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        textDirection: TextDirection.ltr,
        children: children);
  }
}

/// Simple wrapper method that adds LTRB padding to a given widget.
Widget addPad(Widget w, left, top, right, bottom) {
  return Padding(
      padding: new EdgeInsets.fromLTRB(left, top, right, bottom), child: w);
}
