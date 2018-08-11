import codecs
import json
with open(file = 'radkfile', encoding = 'euc_jp') as radkstream:
	radkstring = radkstream.read()
start_parsing = False
radical_map = {}
stroke_map = {}
stroke_list = []
current_stroke_ct = 1
previous_stroke_ct = 1
current_rad = ''
current_rad_list = []
radklines = radkstring.splitlines()
for line in radklines:
	if(not start_parsing and line[0] == '$'):
		start_parsing = True
	if (start_parsing):
		#adds all kanji with current radical present
		if (line[0] != '$'):
			for rad in line:
				current_rad_list.append(rad)
		#update radical if necessary
		else:
			current_stroke_ct= int(line[4:6])
			radical_map.update({current_rad : current_rad_list})
			current_rad_list = []
			current_rad = line[2]
			#adds a radical to a stroke_list iff it belongs in the stroke_list
			if (current_stroke_ct == previous_stroke_ct):
				stroke_list.append(current_rad)
			#adds a completed stroke_list to the stroke_map
			else:
				stroke_map.update({previous_stroke_ct : stroke_list})
				stroke_list = []
				stroke_list.append(current_rad)
				previous_stroke_ct = current_stroke_ct
#taking care of tail end of generation
stroke_map.update({previous_stroke_ct : stroke_list})		
radical_map.update({current_rad : current_rad_list})	

#writing taken care of with these two commands

#with open('radicalMap', 'w') as outfile:
#	json.dump(radical_map, outfile)
#with open('strokeMap', 'w') as outfile:
#	json.dump(stroke_map, outfile)