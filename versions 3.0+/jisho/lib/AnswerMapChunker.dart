import 'dart:convert';
import 'dart:io';

final int LISTSIZE = 100;

void main() {
  File oldMap = new File('assets/json_files/answerMap.json');
  Map bigMap = jsonDecode(oldMap.readAsStringSync());
  List cur = List();
  int i = 1;
  bigMap.forEach((ansID,ansJSON) {
    if (i %LISTSIZE == 0) {
      File newIDFile = new File('assets/json_files/answerMap/'+ ((i-1)~/LISTSIZE).toString());
      newIDFile.writeAsStringSync(jsonEncode(cur));
      cur = List();
    }
    cur.add(ansJSON);
    i ++;
  });
  if (i %LISTSIZE != 0) {
    File newIDFile = new File('assets/json_files/answerMap/'+ ((i-1)~/LISTSIZE).toString());
    newIDFile.writeAsStringSync(jsonEncode(cur));
  }
}