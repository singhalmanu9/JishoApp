import 'Trie.dart';
import 'dart:io';
import 'dart:convert';
import 'Answer.dart';
void main(){
  Trie JapaneseTrie = Trie.root();
  Trie EnglishTrie = Trie.root();
  print(Directory.current);
  Map JSONAnswers = jsonDecode( File('assets/json_files/answerMap.json').readAsStringSync());

  buildJapaneseTrie(JapaneseTrie,JSONAnswers);
  print("done with JP");

  buildEnglishTrie(EnglishTrie,JSONAnswers);
  print("done with EN");

  Map jpTrieMap = JapaneseTrie.toMap();
  var jpString = jsonEncode(jpTrieMap);
  File jpFile = new File('assets/json_files/JPTrie.json');
  jpFile.writeAsStringSync(jpString);
  print("done with JP json serialization. File saved.");

  Map enTrieMap = EnglishTrie.toMap();
  var enString = jsonEncode(enTrieMap);
  File enFile = new File('assets/json_files/ENTrie.json');
  enFile.writeAsStringSync(enString);
  print("done with EN json serialization. File saved.");

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
