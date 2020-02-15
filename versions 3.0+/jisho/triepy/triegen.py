import json
import re
class answer:
	def __init__(self,num,kanjistr,kanastr,en_defs):
		self.num_id = num
		self.kanjistr = kanjistr
		self.kanastr = kanastr
		self.en_defs = en_defs
	def __repr__(self):
		return str(self.num_id) + ":\n"  + "\t" + self.kanjistr + "\n" +"\t" +self.kanastr + "\n" + "\t"+str(self.en_defs)
answerdict = {}
num_id = 0
with open("edict",'rb') as f:
	x = f.readlines()
lines = []
for g in x[1:]:
	lines.append(g.decode("euc_jp"))


defnums = ["(" + str(i) + ")" for i in range(1,30)]
readingInfo = {"gikun": "gikun (meaning) reading",
	"go":"on-yomi, go",
	"ik":"word contains irregular kana usage",
	"jouyou":"jouyou",
	"kan":"on-yomi, kan",
	"kanyou":"on-yomi, kan\\'you",
	"kun":"kun-yomi",
	"name":"reading used online in names(nanori)",
	"oik":"old or irregular kana form",
	"ok":"out-dated or obselete kana usage",
	"on":"on-yomi",
	"rad":"reading used as name of a radical",
	"tou":"on-yomi, tou",
	"uK":"word usually written using kanji alone",
	"uk":"word usually written using kana alone"
}
kanjiInfo = {"ateji":"ateji(phonetic) reading",
	"iK":"word containing irregular kanji usage",
	"ik":"word containing irregular kana usage",
	"io":"irregular okurigana usage",
	"oK":"word containing out-dated kanji"
}
partOfSpeech ={
	"adj-f":"noun or verb acting prenominally",
	"adj-i":"i-adjective (keiyoushi)",
	"adj-ix":"yoi/ii i-adjective",
	"adj-kari":"kari adjective (archaic)",
	"adj-ku" :"ku adjective (archaic)",
	"adj-na":"na-adjective (keyodoshi)",
	"adj-nari":"archaic form of na-adjective",
	"adj-no":"no-adjective",
	"adj-pn":"pre-noun adjectival (rentaishi)",
	"adj-shiku":"shiku adjective (archaic)",
	"adj-t":"'taru' adjective",
	"adv":"adverb (fukushi)",
	"adv-to":"adverb aking the 'to' particle",
	"aux":"auxilliary",
	"aux-adj":"auxilliary adjective",
	"aux-v": "auxilliary verb",
	"conj": "conjunction",
	"cop":"copula",
	"ctr":"counter",
	"exp":"Expressions (phrases,clauses,etc.)",
	"int":"interjection (kandoushi)",
	"n":"noun (common) (futsuumeishi)",
	"n-adv":"adverbial noun (fukushitekimeishi)",
	"n-pr":"proper noun",
	"n-pref":"noun, used as a prefix",
	"n-suf":"noun, used as a suffix",
	"n-t":"noun (temporal) (jisoumeishi)",
	"num":"pn",
	"pn":"pronoun",
	"pref":"prefix",
	"prt":"particle",
	"suf":"suffix",
	"unc":"unclassified",
	"v-unspec":"verb unspecified",
	"v1":"Ichidan verb",
	"v1-s":"Ichidan verb - kureru special class",
	"v5aru": "Godan verb- -aru special class",
	"v5b": "Godan verb with 'bu' ending",
	"v5g": "Godan verb with 'gu' ending",
	"v5k":"Godan verb with 'ku' ending",
	"v5k-s":"Godan verb - Iku/Yuku special class",
	"v5m":"Godan verb with 'mu' ending",
	"v5n":"Godan verb with 'nu' ending",
	"v5r":"Godan verb with 'ru' ending",
	"v5r-i":"Godan verb with 'ru' ending (irregular verb)",
	"v5s":"Godan verb with 'su' ending",
	"v5t":"Godan verb with 'tsu' ending",
	"v5u":"Godan verb with 'u' ending",
	"v5u-s":"godan verb with 'u' ending (special class)",
	"v5uru":"Godan verb -Uru old class verb (old form of Eru)",
	"vi" :"intransitive verb",
	"vk" :"Kuru verb - special class",
	"vn": "irregular nu verb",
	"vr": "irregular ru verb, plain form ends with -ri",
	"vs":"noun or participle which takes the aux. verb suru",
	"vs-c":"su verb - precursor to the modern suru",
	"vs-i":"suru verb - irregular",
	"vs-s":"suru verb - special class",
	"vt":"transitive verb",
	"vz":"Ichidan verb - zuru verb (alternative for of -jiru verbs)"
}
archaics = {"v2a-s":"Nidan verb with 'u' ending (archaic)",
	"v2b-k":"Nidan verb (upper class) with bu ending (archaic)",
	"v2b-s":"Nidan verb lower class) with bu ending (archaic)",
	"v2d-k":"Nidan verb (upper class) with gu ending (archaic)",
	"v2d-s":"Nidan verb (lower class) with dzu ending (archaic)",
	"v2g-k": "Nidan verb (upper class) with gu ending (archaic)",
	"v2g-s": "Nidan verb (lower class) with gu ending (archaic)",
	"v2h-k": "Nidan verb (upper class) with hu/fu ending (archaic)",
	"v2h-s":"Nidan verb (lower class) with hu/fu ending (archaic)",
	"v2k-k": "Nidan verb (upper class) with ku ending (archaic)",
	"v2k-s":"Nidan verb (lower class) with ku ending (archaic)",
	"v2m-k":"Nidan verb (upper class) with mu ending (archaic)",
	"v2m-s":"Nidan verb (lower class) with mu ending (archaic)",
	"v2n-s":"Nidan verb (lower class) with nu ending (archaic)",
	"v2r-k": "Nidan verb (upper class) with ru ending (archaic)",
	"v2r-s":"Nidan verb (upper class) with ru ending (archaic)",
	"v2s-s":"Nidan verb (lower class) with su ending (archaic)",
	"v2t-k":"Nidan verb (upper class) with tsu ending (archaic)",
	"v2t-s":"Nidan verb (lower class) with tsu ending (archaic)",
	"v2w-s":"Nidan verb (lower class) with u ending and we conjugation (archaic)",
	"v2y-k":"Nidan verb (upper class) with yu ending (archaic)",
	"v2y-s":"Nidan verb (lower class) with yu ending (archaic)",
	"v2z-s":"Nidan verb (lower class) with zu ending (archaic)",
	"v4b":"Yodan verb with bu ending (archaic)",
	"v4g":"Yodan verb with gu ending (archaic)",
	"v4h":"Yodan verb with 'hu/fu' ending (archaic)",
	"v4k":"Yodan verb with ku ending (archaic)",
	"v4m":"Yodan verb with mu ending (archaic)",
	"v4n": "yodan verb with 'nu' ending (archaic)",
	"v4r":"Yodan verb with'ru' ending (archaic)",
	"v4s": "Yodan verb with su ending (archaic)",
	"v4t":"Yodan verb with tsu ending (archaic)"}
def remove_artifacts(cur_def):
	while True: #remove formatting artifacts caused from removing archaics
		rem = None
		rem2 = None
		for j in range(1,len(cur_def)):
			lastaa = cur_def[j-1]
			curaa = cur_def[j]
			if lastaa == '(' and curaa == ',':
				rem = j
				break;
			if lastaa == ',' and curaa == ')':
				rem = j - 1
				break;
			if lastaa == '(' and curaa == ')':
				rem = j- 1
				rem2 = j
				break;
		if rem and rem2:
			cur_def = cur_def[:rem] + cur_def[rem2 + 1:]
		elif rem:
			cur_def= cur_def[:rem] + cur_def[rem + 1:]
		else:
			break
	return cur_def

def create_from_line(line):
	"""
		:line: string of information to be parsed into returned data
		:ret: num_id, kanjistr, kanastr, en_defs
		:num_id: integer, unique identifier for a word
		:kanjistr:string, the kanji/special character representation of the word/symbol
		:kanastr: string, the kana representation of the word/symbol
		:en_defs: list[dictionary], a list of {"pos":[--,--],"definition":----} dictionaries. "pos" may be present as an empty list.
			"definition" should always be present
	"""
	global num_id
	num_id += 1
	i = 0
	kanji = True
	kana = False
	en = False
	kanjistr = ""
	kanastr = ""
	cur_pos = ""
	en_defs = []
	cur_def = ""
	for i in range(len(line)):
		if kanji and line[i]== ' ': #end of kanji in line
			kanji = False
			kana = True
			continue
		elif kanji: #parsing kanji from line
			kanjistr += line[i]
		elif kana: #parsing kana from line
			if line[i] == '[':#beginning of kana
				continue
			if line[i] == ']':#end of kana
				continue
			if line[i] == ' ':#transition from kana to english definitions
				kana = False
				en = True
				continue
			kanastr += line[i]
		elif en:#parsing english from line
			if line[i] == '/' and cur_def:
				for defnum in defnums: #remove the definition numbers from lines in the current defintion
					if defnum in cur_def:
						cur_def = cur_def[:cur_def.index(defnum)]+ cur_def[cur_def.index(defnum) + 3:]
				for arch in archaics: #remove archaic part of speech tags
					if arch in cur_def:
						cur_def = cur_def[:cur_def.index(arch)] + cur_def[cur_def.index(arch) + len(arch):]

				cur_def = remove_artifacts(cur_def)
				if cur_def:
					en_defs.append(cur_def)
				cur_def = ""
				continue
			if line[i] == "\n":#end of line, last step
				continue
			cur_def += line[i]
	en_defs_revised = [{"pos":[]} for _ in en_defs]
	for i in range(len(en_defs)):
		d = en_defs[i]
		for pos in partOfSpeech.keys():
			regexstr = '\((.*,)?' + pos + '(,.*)?\)' #starts with (, possibly has stuff before it, then has the part of speech. Possibly has stuff after it, definitely ends with a )
			if re.search(regexstr,d):
				en_defs[i] = en_defs[i][:en_defs[i].index(pos)] + en_defs[i][en_defs[i].index(pos) + len(pos):]
				en_defs_revised[i]['pos'].append(partOfSpeech[pos])
				d = en_defs[i]
		removed = remove_artifacts(en_defs[i])
		if removed[0] == '/':
			removed = removed[1:]
		if removed[0] == ' ':
			removed = removed[1:]
		en_defs_revised[i]['definition'] = removed
	en_defs = en_defs_revised
	#todo for each def in line, change def into pos and def
	return num_id,kanjistr,kanastr,en_defs
res = {}

for m in lines:
	if "(oK)" in m:
		continue
	if "(arch)" in m:
		continue
	num,kstr,kanastr,endf = create_from_line(m)
	endf = [json.dumps(m) for m in endf]
	res[num]=json.dumps({"num_id":num,"kanjistr":kstr,"kanastr":kanastr,"en_defs":endf})
x = json.dumps(res)
with open("definitions.json",'w') as f:
	f.write(x)
print(len(x))