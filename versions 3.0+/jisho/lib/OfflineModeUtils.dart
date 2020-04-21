import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:flutter_app/OfflineSearchPage.dart';

import 'Answer.dart';
import 'AnswerMapChunker.dart';
import 'Trie.dart';
import 'package:tuple/tuple.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;


class OfflineModeUtils {
  /// Gives the Answer corresponding the ID from the answerMap
  /// This is public for no reason I can currently think of. Might make it
  /// private later who knows ;)))
  static Future<Answer> getAnswerFromID(int id)async {
    int answerChunk = id ~/ LISTSIZE;
    String chunkPath = "assets/json_files/answerMap/" + answerChunk.toString();

    String chunkJSON = await rootBundle.loadString(chunkPath);
    if (chunkJSON.length == 0 ) {
      return null;
    }
    List chunkList =  jsonDecode(chunkJSON);
    int answerIndex = id % LISTSIZE;
    return Answer()..fromMap(chunkList[answerIndex]);
  }

  ///Performs the search for a given query on a Trie node. Ideally, this is only
  ///called on the root.
  static Future<List<int>> _getIdsForQuery(String assetPath,String query, Trie cur, Map idMap, Map loadedChunks) async{
    while (query.length != 0) {
      String next = query.substring(0, 1);
      query = query.substring(1);
      if (cur.c.containsKey(next)) {
        cur = await getTrieFromID(assetPath,cur.c[next],idMap,loadedChunks);
      } else {
        return List();
      }
    }
    return cur.t;
  }


  ///:param id: ID of the Trie to be loaded
  ///:param idMap: Map of id's to chunks
  ///:param loadedChunks: Map if chunks already loaded
  static Future<Trie> getTrieFromID(String assetPath, int id, Map idMap, Map loadedChunks) async {
    int Chunk = idMap[id.toString()];
    if (!loadedChunks.containsKey(Chunk)) {
      String val = await rootBundle.loadString(assetPath + Chunk.toString());
      Map newChunk = jsonDecode(val);
      loadedChunks[Chunk] = newChunk;
      return Trie()..fromMap(loadedChunks[Chunk][id.toString()]);
    } else {
      return Trie()
        ..fromMap(loadedChunks[Chunk][id.toString()]);
    }
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
  static Future<List<Answer>> searchTrie(String query, Trie root, String mode) async{
    List<Answer> ret = List();
    if (mode == "JP") {
      Trie cur = root;
      String assetPath = 'assets/json_files/JPTrie/';
      Map idMap= jsonDecode(await rootBundle.loadString(assetPath + 'idMap'));

      List<int> idList = await _getIdsForQuery(assetPath,query, cur,idMap,Map());

      await Future.forEach(idList, (int id) async {
        ret.add(await getAnswerFromID(id));
      });

    } else {
      Trie cur = root;
      String assetPath = 'assets/json_files/ENTrie/';
      Map idMap= jsonDecode(await rootBundle.loadString(assetPath + 'idMap'));
      print(idMap['0']);
      Map loadedChunks = Map();
      List<String> individualWords = query.split(' ');
      List<Tuple2<int, double>> idsToScores = List();
      await Future.forEach(individualWords,(String word)async {
        double score = word.length / query.length;
        List<int> queries =await _getIdsForQuery(assetPath,word, cur,idMap,loadedChunks);
        queries.forEach((id) {
          idsToScores.add(Tuple2(id, score));
        });
      });
      List<int> idList =await _getIdsForQuery(assetPath,query, cur,idMap,loadedChunks);
      await Future.forEach(idList,(id) {
        idsToScores.add(Tuple2(id, 1.0));
      });
      idsToScores.sort((tupA, tupB) {
        return tupB.item2.compareTo(tupA.item2);
      });
      Set seenID = Set();
      await Future.forEach(idsToScores,(tup)async {
        if (!seenID.contains(tup.item1)){
          ret.add(await getAnswerFromID(tup.item1));
          seenID.add(tup.item1);
        }
      });

    }

    ret.sort((a,b) {
      int x = a.common ? -1:0;
      int y = b.common ? 1:0;
      return x + y;
    });
    return ret;
  }
}