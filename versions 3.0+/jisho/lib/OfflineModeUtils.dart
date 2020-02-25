import 'dart:convert';

import 'Answer.dart';
import 'Trie.dart';
import 'package:tuple/tuple.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;


class OfflineModeUtils {
  /// Gives the Answer corresponding the ID from the answerMap
  /// This is public for no reason I can currently think of. Might make it
  /// private later who knows ;)))
  static Answer getAnswerFromID(int id, Map answerMap) {
    if (answerMap.containsKey(id.toString())) {
      return answerMap[id.toString()];
    }
    return null;
  }
  ///Performs the search for a given query on a Trie node. Ideally, this is only
  ///called on the root.
  static List<int> _getIdsForQuery(String query, Trie cur){
    while(query.length != 0) {
      String next = query.substring(0,1);
      query = query.substring(1);
      if (cur.children.containsKey(next)) {
        cur = cur.children[next];
      } else {
        return List();
      }
    }
    return cur.terminalDefinitions;
  }
  ///Searches the Trie for a query given its respective mode:
  ///if the mode is JP, the query is directly matched and its
  ///corresponding Answers are returned.
  ///if the mode is EN (or anything other than JP but this shouldn't happen),
  ///the query is split into its constituent words and each of those words
  ///is searched for. Each word is given a score based on its proportional
  ///length to its full query. The query is also searched for in its entirety.
  ///All search results are then sorted based on score (in reverse order) and
  ///are output.
  static List<Answer> searchTrie(String query, Trie root, String mode, Map answerMap) {
    if (mode == "JP") {
      Trie cur = root;
      List<int> idList = _getIdsForQuery(query, cur);
      List<Answer> ret = List();
      idList.forEach((int id) {
        ret.add(getAnswerFromID(id, answerMap));
      });
      return ret;
    }else {
      Trie cur = root;
      List<String> individualWords = query.split(' ');
      List<Tuple2<int,double>> idsToScores = List();
      individualWords.forEach((String word) {
        double score = word.length/query.length;
        List<int> queries = _getIdsForQuery(word, cur);
        queries.forEach((id) {
          idsToScores.add(Tuple2(id,score));
        });
      });
      List<int> idList = _getIdsForQuery(query, cur);
      idList.forEach((id) {
        idsToScores.add(Tuple2(id,1.0));
      });
      idsToScores.sort((tupA, tupB) {
        return tupB.item2.compareTo(tupA.item2);
      });
      List<Answer> ret = List();
      idsToScores.forEach((tup) {
        ret.add(getAnswerFromID(tup.item1, answerMap));
      });
      return ret;
    }
  }


  static Future<String> loadAsset() async {
    return await rootBundle.loadString('assets/config.json');
  }


  static Trie loadJPTrie() {
    String jsonString;
    rootBundle.loadString('assets/json_files/JPTrie.json').then( (val) {
      jsonString = val;
    });
    var jsonMap = jsonDecode(jsonString);
    Trie root = Trie()..fromMap(jsonMap);
    return root;
  }

  static Trie loadENTrie() {
    String jsonString;
    rootBundle.loadString('assets/json_files/ENTrie.json').then( (val) {
      jsonString = val;
    });
    var jsonMap = jsonDecode(jsonString);
    Trie root = Trie()..fromMap(jsonMap);
    return root;
  }

  static Map getAnswerMap() {
    String jsonString;
    rootBundle.loadString('assets/json_files/answerMap.json').then( (val) {
      jsonString = val;
    });
    return jsonDecode(jsonString);
  }
}