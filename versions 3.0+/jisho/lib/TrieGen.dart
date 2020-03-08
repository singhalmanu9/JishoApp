import 'dart:collection';

import 'Trie.dart';
import 'dart:io';
import 'dart:convert';
import 'Answer.dart';

void main(){
  Trie JapaneseTrie = Trie.root();

  print(Directory.current);
  Map JSONAnswers = jsonDecode( File('assets/json_files/answerMap.json').readAsStringSync());

  buildJapaneseTrie(JapaneseTrie,JSONAnswers);
  print("done with JP" + JapaneseTrie.id.toString());

  resetGlobalID();

  Trie EnglishTrie = Trie.root();

  buildEnglishTrie(EnglishTrie,JSONAnswers);
  print("done with EN" + EnglishTrie.id.toString());

  splitTrie(JapaneseTrie,'assets/json_files/JPTrie/');
  print("done with JP json serialization. File saved.");

  splitTrie(EnglishTrie,'assets/json_files/ENTrie/');
  print("done with EN json serialization. File saved.");

}

////TODO split the root into lists of nodes of length MAPSIZE or less.
// save ids of nodes in map that tells which file it's in.

void splitTrie(Trie root, String initpath) {
  Queue cur = Queue();
  cur.add(root);
  int cur_ct = 1;
  Map<String,Trie> cur_map = Map();
  Map<String,int> id_location = Map();

  final MAPSIZE = 850;
  while (cur.isNotEmpty) {
    if (cur_ct % MAPSIZE == 0 ) {
      String path = initpath + (cur_ct~/ MAPSIZE).toString();
      if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
        File destFile = new File(path);
        destFile.writeAsStringSync(jsonEncode(cur_map));
      }
      cur_map.forEach((str,trie) {
        id_location[trie.id.toString()] = cur_ct~/ MAPSIZE;
      });
      cur_map = Map();
    }

    Trie val = cur.removeFirst();

    Map updated_c = Map();
    val.c.forEach((key, child) {
      if (child is Trie)
      updated_c[key] = child.id;
      cur.add(child);
    });
    val.c = updated_c;
    cur_map[val.id.toString()] = val;

    cur_ct += 1;
  }
  if (cur_ct % MAPSIZE != 0 ) {
    String path = initpath + (cur_ct~/ MAPSIZE).toString();
    if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
      File destFile = new File(path);
      destFile.writeAsStringSync(jsonEncode(cur_map));
    }
    cur_map.forEach((str,trie) {
      id_location[trie.id.toString()] = cur_ct~/ MAPSIZE;
    });
    cur_map = Map();
  }
  File rootFile = new File(initpath + 'root');
  rootFile.writeAsStringSync(jsonEncode(root..toMap()));
  File idMap = new File(initpath + "idMap");
  idMap.writeAsStringSync(jsonEncode(id_location));
}


void buildJapaneseTrie(Trie root, Map answers) {
  answers.forEach((key, answerMap)  {

    Answer answer = Answer.getFromMap(answerMap);
    root.insertString(answer.kanaStr, answer.id);
    root.insertString(answer.kanjiStr, answer.id);
  });

}
void buildEnglishTrie(Trie root, Map answers) {
  answers.forEach((key, answerMap) {
    Answer answer = Answer.getFromMap(answerMap);
    answer.defs.forEach((defMap) {
      root.insertString(defMap["definition"],answer.id);
    });
  });
}
