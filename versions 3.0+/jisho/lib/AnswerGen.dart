import 'dart:convert';
import 'dart:io';
import 'Answer.dart';

void main(){

  String defs = new File('triepy/definitions.json').readAsStringSync();
  Map JSONAnswers =jsonDecode(defs);
  print(JSONAnswers['1']);
  Map AnswerMap = Map();
  for (int i = 1; i <= JSONAnswers.length; i++){
    Answer answer = Answer.fromJSON(jsonDecode(JSONAnswers[i.toString()]));
    AnswerMap[i.toString()] = answer.toMap();
  }
  var v = jsonEncode(AnswerMap);
  File dest = new File('assets/json_files/answerMap.json');
  dest.writeAsStringSync(v);
}