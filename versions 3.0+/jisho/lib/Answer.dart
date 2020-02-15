import 'dart:convert';
import 'package:serializable/serializable.dart';

part 'Answer.g.dart';

@serializable
class Answer extends _$AnswerSerializable{
  int id;
  String kanjiStr;
  String kanaStr;
  List<Map> defs;
  Answer() ;
  Answer.fromJSON(Map jsonMap){
    this.id = (jsonMap['num_id']);
    this.kanjiStr = jsonMap['kanjistr'];
    this.kanaStr = jsonMap['kanastr'];
    List<Map> defPairs = List();
    jsonMap['en_defs'].forEach(( mapStr) =>{
      defPairs.add(json.decode(mapStr))
      }
    );
    this.defs = defPairs;
  }

  @override
  String toString() {
    // TODO: implement toString
    return "id: "+id.toString()+"\n"+
    "kanjiStr :"+this.kanjiStr+ "\n"+
    "kanaStr: "+this.kanaStr+"\n"+
    "defs: "+this.defs.toString();
  }
  static Answer getFromMap(Map map) {
    Answer ret = Answer();
    ret.fromMap(map);
    return ret;
  }

}
