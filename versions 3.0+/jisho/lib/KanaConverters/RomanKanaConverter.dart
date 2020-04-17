///The map of all romaji tokens present within the Hepburn and
///Kunrei (cabinet) systems.
///This will also contain tokens that were introduced later to accommodate
///foreign pronunciations.
Map<String, String> unifiedRomaji = {
  'a':'あ','i':'い','u':'う','e':'え','o':'お',
  'ka':'か','ki':'き','ku':'く','ke':'け','ko':'こ',
  'ga':'が','gi':'ぎ','gu':'ぐ','ge':'げ','go':'ご',
  'sa':'さ','shi':'し','su':'す','se':'せ','so':'そ',
       'si':'し',
  'za':'ざ','ji':'じ','zu':'ず', 'ze':'ぜ','zo':'ぞ',
       'zi':'じ',
  'ta':'た','chi':'ち','tsu':'つ', 'te':'て','to':'と',
       'ti':'ち', 'tu':'つ',
  'da':'だ',                       'de':'で','do':'ど',
       'di':'ぢ','du':'づ',
  'na':'な','ni':'に','nu':'ぬ','ne':'ね','no':'の',
  'ha':'は','hi':'ひ','fu':'ふ','he':'へ','ho':'ほ',
            'hu':'ふ',
  'ba':'ば','bi':'び','bu':'ぶ','be':'べ','bo':'べ',
  'pa':'ぱ','pi':'ぴ','pu':'ぷ','pe':'ぺ','po':'ぽ',
  'ma':'ま','mi':'み','mu':'む','me':'め','mo':'も',
  'ya':'や',     'yu':'ゆ',     'yo':'よ',
  'ra':'ら','ri':'り','ru':'る','re':'れ','ro':'ろ',
  'wa':'わ',               'wo':'を',
  "m'":'ん',"n'":'ん',

  'kya':'きゃ','kyu':'きゅ','kyo':'きょ',
  'gya':'ぎゃ','gyu':'ぎゅ','gyo':'ぎょ',
  'sha':'しゃ','shu':'しゅ','sho':'しょ',
  'sya':'しゃ','syu':'しゅ','syo':'しょ',
  'ja':'じゃ,', 'ju':'じゅ','jo':'じょ',
  'zya':'じゃ','zyu':'じゅ','zyo':'じょ',
  'cha':'ちゃ','chu':'ちゅ','cho':'ちょ',
  'tya':'ちゃ','tyu':'ちゅ','tyo':'ちょ',
  'nya':'にゃ','nyu':'にゅ','nyo':'にょ',
  'hya':'ひゃ','hyu':'ひゅ','hyo':'ひょ',
  'bya':'びゃ','byu':'びゅ','byo':'びょ',
  'pya':'ぴゃ','pyu':'ぴゅ','pyo':'ぴょ',
  'mya':'みゃ','myu':'みゅ','myo':'みょ',
  'rya':'りゃ','ryu':'りゅ','ryo':'りょ'



  };

/// non-destructively removes any tokens present within the input string.
/// param: romaji - the inputstring of romanized characters
/// return: String- the transliterated version of romaji.
String transliterate(String romaji) {
  romaji = romaji.toLowerCase();
  String ret  = "";
  String cur = "";
  List<int> codes=romaji.codeUnits;
  String c;
  for (int i=0; i<codes.length; i++) {
    c = String.fromCharCode(codes[i]);

    if (cur.length == 3) {
      ret += String.fromCharCode(cur.codeUnitAt(0));
      cur = cur.substring(1);
    }
    cur += c;
    if (unifiedRomaji.containsKey(cur)) {
      ret += unifiedRomaji[cur];
      cur = "";
    }
    //in the case cur begins with n or m but isn't nya or mya line
    if (cur.length == 3 && cur.substring(0, 1) == 'n' || cur.substring(0,1) == 'm') {
      cur = cur.substring(1);
      if(unifiedRomaji.containsKey(cur)) {
        ret += unifiedRomaji[cur];
        cur = "";
      }
    }
  }
  ret += cur;
  return ret;
}