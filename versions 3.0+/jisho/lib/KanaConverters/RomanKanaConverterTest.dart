import 'package:flutter_app/KanaConverters/RomanKanaConverter.dart' as convert;
void main() {
  test("romaji");
  test("goemon");
  test("konna");
  test("chikatetsu");
  test("seppuku");
  test("aoi");
  test("eiga");
  test("densha");
  test("jinzya");
  test("ginza");
  test("fukuoka");
  test("humei");
  test("kakugou");
}
void test(String input) {
  String output = convert.transliterate(input);
  print("transliterating " + input + " as :" + output);
  print("clean transliteration:" + convert.cleanTransliteration(output).toString());
  print("");
}