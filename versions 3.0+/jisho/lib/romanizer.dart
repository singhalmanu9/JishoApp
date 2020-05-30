import 'package:string_validator/string_validator.dart' as str_val;

var kanaToRomaji = {
  'ア': 'a',
  'イ': 'i',
  'ウ': 'u',
  'エ': 'e',
  'オ': 'o',
  'あ': 'a',
  'い': 'i',
  'う': 'u',
  'え': 'e',
  'お': 'o',
  'カ': 'ka',
  'キ': 'ki',
  'ク': 'ku',
  'ケ': 'ke',
  'コ': 'ko',
  'か': 'ka',
  'き': 'ki',
  'く': 'ku',
  'け': 'ke',
  'こ': 'ko',
  'ガ': 'ga',
  'ギ': 'gi',
  'グ': 'gu',
  'ゲ': 'ge',
  'ゴ': 'go',
  'が': 'ga',
  'ぎ': 'gi',
  'ぐ': 'gu',
  'げ': 'ge',
  'ご': 'go',
  'サ': 'sa',
  'シ': 'si',
  'ス': 'su',
  'セ': 'se',
  'ソ': 'so',
  'さ': 'sa',
  'し': 'shi',
  'す': 'su',
  'せ': 'se',
  'そ': 'so',
  'ザ': 'za',
  'ジ': 'ji',
  'ズ': 'zu',
  'ゼ': 'ze',
  'ゾ': 'zo',
  'ざ': 'za',
  'じ': 'ji',
  'ず': 'zu',
  'ぜ': 'ze',
  'ぞ': 'zo',
  'タ': 'ta',
  'チ': 'chi',
  'ツ': 'tsu',
  'テ': 'te',
  'ト': 'to',
  'た': 'ta',
  'ち': 'chi',
  'つ': 'tsu',
  'て': 'te',
  'と': 'to',
  'ダ': 'da',
  'ヂ': 'ji',
  'ヅ': 'zu',
  'デ': 'de',
  'ド': 'do',
  'だ': 'da',
  'ぢ': 'ji',
  'づ': 'zu',
  'で': 'de',
  'ど': 'do',
  'ナ': 'na',
  'ニ': 'ni',
  'ヌ': 'nu',
  'ネ': 'ne',
  'ノ': 'no',
  'な': 'na',
  'に': 'ni',
  'ぬ': 'nu',
  'ね': 'ne',
  'の': 'no',
  'ハ': 'ha',
  'ヒ': 'hi',
  'フ': 'fu',
  'ヘ': 'he',
  'ホ': 'ho',
  'は': 'ha',
  'ひ': 'hi',
  'ふ': 'fu',
  'へ': 'he',
  'ほ': 'ho',
  'バ': 'ba',
  'ビ': 'bi',
  'ブ': 'bu',
  'ベ': 'be',
  'ボ': 'bo',
  'ば': 'ba',
  'び': 'bi',
  'ぶ': 'bu',
  'べ': 'be',
  'ぼ': 'bo',
  'パ': 'pa',
  'ピ': 'pi',
  'プ': 'pu',
  'ペ': 'pe',
  'ポ': 'po',
  'ぱ': 'pa',
  'ぴ': 'pi',
  'ぷ': 'pu',
  'ぺ': 'pe',
  'ぽ': 'po',
  'マ': 'ma',
  'ミ': 'mi',
  'ム': 'mu',
  'メ': 'me',
  'モ': 'mo',
  'ま': 'ma',
  'み': 'mi',
  'む': 'mu',
  'め': 'me',
  'も': 'mo',
  'ヤ': 'ya',
  'ユ': 'yu',
  'ヨ': 'yo',
  'や': 'ya',
  'ゆ': 'yu',
  'よ': 'yo',
  'ラ': 'ra',
  'リ': 'ri',
  'ル': 'ru',
  'レ': 're',
  'ロ': 'ro',
  'ら': 'ra',
  'り': 'ri',
  'る': 'ru',
  'れ': 're',
  'ろ': 'ro',
  'ワ': 'wa',
  'ヰ': 'wi',
  'ヱ': 'we',
  'ヲ': 'o',
  'ン': 'n\'',
  'わ': 'wa',
  'ゐ': 'wi',
  'ゑ': 'we',
  'を': 'o',
  'ん': 'n\'',
  'ァ': 'xa',
  'ィ': 'xi',
  'ゥ': 'xu',
  'ェ': 'xe',
  'ォ': 'xo',
  'ぁ': 'xa',
  'ぃ': 'xi',
  'ぅ': 'xu',
  'ぇ': 'xe',
  'ぉ': 'xo',
  'ッ': 'xtsu',
  'ャ': 'xya',
  'ュ': 'xyu',
  'ョ': 'xyo',
  'っ': 'xtsu',
  'ゃ': 'xya',
  'ゅ': 'xyu',
  'ょ': 'xyo'
};

///romanizes a romaji-hiragana-katakana string.
String romanize(String kanaIn) {
  String result = '';
  bool smallTsu = false;
  for (int i = 0; i < kanaIn.length; i++) {
    String s = kanaIn.substring(i, i + 1);
    String rom = kanaToRomaji[s];
    if (rom == null) {
      rom = s;
    }
    if (rom.startsWith('x')) {
      if (rom.length == 4) {
        smallTsu = true;
      } else {
        if (rom.length == 3) {
          if (result.length > 2 &&
              (result.substring(result.length - 3) == 'shi' ||
                  result.substring(result.length - 3) == 'chi' ||
                  result.substring(result.length - 3) == 'ji')) {
            result = result.substring(0, result.length - 1);
            result += rom.substring(2);
          } else {
            result = result.substring(0, result.length - 1);
            result += rom.substring(1);
          }
        } else {
          result = result.substring(0, result.length - 1);
          result += rom.substring(1);
        }
        smallTsu = false;
      }
    } else {
      if (smallTsu) {
        result += rom.substring(0, 1) + rom;
      } else {
        result += rom;
      }
      smallTsu = false;
    }
  }
  return result;
}

/// A method to test whether a string has kana present within.
/// param: inputStr - the string that is going to be tested for the
/// presence of kana.
/// ret: bool: True iff string is not alphanumeric.
bool kanaPresent(String inputStr) {
  return !str_val.isAlphanumeric(inputStr);
}
