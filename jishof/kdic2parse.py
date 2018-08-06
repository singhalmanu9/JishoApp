import xml.etree.ElementTree as ET;
import json;

tree = ET.parse('kanjidic2.xml');
root = tree.getroot();
kdic2 = {};
for character in root:
	literal = character.find('literal')
	grade = character.find('misc').find('grade')
	jlpt = character.find('misc').find('jlpt')

	readings = []
	meanings = []
	nanori = [];
	if character.find('reading_meaning'):
		for r in character.find('reading_meaning').find('rmgroup').findall('reading'):
			if (r.get('r_type') == 'ja_on' or r.get('r_type') == 'ja_kun'):
				readings.append(r.text)

		for m in character.find('reading_meaning').find('rmgroup').findall('meaning'):
			if (m.get('m_lang') == None):
				meanings.append(m.text);

		for n in character.find('reading_meaning').findall('nanori'):
			nanori.append(n.text)

	obj = [grade.text if grade != None else '', jlpt.text if jlpt != None else '', readings, meanings, nanori];
	kdic2[literal.text] =  obj;

with open('kdic2', 'w') as outfile:
	json.dump(kdic2, outfile)
