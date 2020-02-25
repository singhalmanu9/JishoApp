import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/OfflineModeUtils.dart';
import 'dart:async';
import 'dart:convert';
import 'romanizer.dart' as romanizer;
import 'package:flutter_app/OfflineModeUtils.dart';
import 'Trie.dart';
import 'Answer.dart';

class OfflineSearchPage extends StatefulWidget {
  String searchTextField;
  bool romajiOn = false;
  static Set<String> _searchKanji;
  OfflineSearchPage(String searchTextField, bool romajiOn) {
    this.searchTextField = searchTextField;
    this.romajiOn = romajiOn;
  }

  static void setKanji(Set<String> kanjiList) {
    _searchKanji = kanjiList;
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


  _OfflineSearchPageState(String searchTextField, bool romajiOn) {
    this.searchTextField = searchTextField;
    this.romajiOn = romajiOn;
    this.romajiOn = romajiOn;
  }

  @override
  void initState() {
    super.initState();
    Trie root;
    String mode;
    Map answerMap = OfflineModeUtils.getAnswerMap();
    if(romajiOn) {
      mode = "JP";
      root = OfflineModeUtils.loadJPTrie();
    } else {
      mode = "EN";
      root = OfflineModeUtils.loadENTrie();
    }
    List<Answer> answers = OfflineModeUtils.searchTrie(searchTextField, root, mode, answerMap);
    //TODO build widgets based off of answers...
    //Make text look nice
    //Link up Kanji when possible.
    answers.forEach((Answer a) {
      //kana above kanji
      //kanji given links when possible
      //pos above def for each map in list
      //add created widget fro one result to _defWidgets
      //set state
    });
  }
}