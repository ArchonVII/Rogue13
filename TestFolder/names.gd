extends Node2D

var last = "res://Docs/lastnames.txt"
var country = "res://Docs/countrynames.txt"
var fname = "res://Docs/femalefirstnames.txt"
var mname = "res://Docs/malefirstnames.txt"
var job = "res://Assets/Character/Lists/occupations.txt"
var flag_file = ["afghanistan.png", "alabama.png", "alaska.png", "albania.png", "algeria.png", "andorra.png", "angola.png", "arizona.png",
	"arkansas.png", "armenia.png", "australia.png", "austria.png", "azerbaijan.png", "bahrain.png", "bangladesh.png", "belarus.png", "belgium.png", "benin.png", "bhutan.png", "bosniaherzegovina.png", "botswana.png", "brunei.png", "bulgaria.png", "burkinafaso.png", "burundi.png", "california.png", "cambodia.png", "cameroon.png", "capeverde.png", "centralafricanrepublic.png", "chad.png", "china.png", "colorado.png", "columbia.png", "comoros.png", "connecticut.png", "croatia.png", "cyprus.png", "czechrepublic.png", "delaware.png", "democraticrepublicofthecongo.png", "denmark.png", "djibouti.png", "easttimor.png", "egypt.png", "equatorialguinea.png", "eritrea.png", "estonia.png", "eswatini.png", "ethiopia.png", "fiji.png", "finland.png", "florida.png", "france.png", "gabon.png", "gambia.png", "georgia.png", "georgiaUS.png", "germany.png", "ghana.png", "greece.png", "guam.png", "guinea.png", "guineabissau.png", "hawaii.png", "hungary.png", "iceland.png", "idaho.png", "illinois.png", "india.png", "indiana.png", "indonesia.png", "iowa.png", "iran.png", "iraq.png", "ireland.png", "israel.png", "italy.png", "ivorycoast.png", "japan.png", "jordan.png", "kansas.png", "kazakhstan.png", "kenia.png", "kentucky.png", "kiribati.png", "kuwait.png", "kyrgyzstan.png", "laos.png", "latvia.png", "lebanon.png", "lesotho.png", "liberia.png", "libya.png", "liechtenstein.png", "lithuania.png", "louisiana.png", "luxembourg.png", "madagascar.png", "maine.png", "malawi.png", "malaysia.png", "maldives.png", "mali.png", "malta.png", "marshall.png", "maryland.png", "massachusetts.png", "mauritania.png", "mauritius.png", "michigan.png", "micronesia.png", "minnesota.png", "mississippi.png", "missouri.png", "moldova.png", "monaco.png", "mongolia.png", "montana.png", "montenegro.png", "morocco.png", "mozambique.png", "myanmar.png", "namibia.png", "nauru.png", "nebraska.png", "nepal.png", "netherlands.png", "nevada.png", "newhampshire.png", "newjersey.png", "newmexico.png", "newyork.png", "newzealand.png", "niger.png", "nigeria.png", "northcarolina.png", "northcorea.png", "northdakota.png", "northenmarianaislands.png", "northmacedonia.png", "norway.png", "ohio.png", "oklahoma.png", "oman.png", "oregon.png", "pakistan.png", "palau.png", "palestine.png", "papuanewguinea.png", "pennsylvania.png", "philippines.png", "poland.png", "portugal.png", "puertorico.png", "qatar.png", "republicofthecongo.png", "rhodeisland.png", "romania.png", "russia.png", "rwanda.png", "samoa.png", "sanmarino.png", "saotomeandprincipe.png", "saudiarabia.png", "senegal.png", "serbia.png", "seychelles.png", "sierraleone.png", "singapore.png", "slovakia.png", "slovenia.png", "solomon.png", "somalia.png", "southafrica.png", "southcarolina.png", "southcorea.png", "southdakota.png", "southsudan.png", "spain.png", "srilanka.png", "sudan.png", "sweden.png", "switzerland.png", "syria.png", "tajikistan.png", "tanzania.png", "tennessee.png", "texas.png", "thailand.png", "togo.png", "tonga.png", "tunisia.png", "turkey.png", "turkmenistan.png", "tuvalu.png", "uganda.png", "ukraine.png", "unitedarabemirates.png", "unitedkingdom.png", "utah.png", "uzbekistan.png", "vanuatu.png", "vaticancity.png", "vermont.png", "vietnam.png", "virginia.png", "virginislands.png", "washington.png", "westvirginia.png", "wisconsin.png", "wyoming.png", "yemen.png", "zambia.png", "zimbabwe.png"]


func _ready():
	var rng = RandomNumberGenerator.new()
	#var getnames = get_random_name_from_file(fname)
	#print("name: ", getnames)
	#get_flag_files()

	var test = get_random_name_from_file("male")


func get_random_name_from_file(type):
	var file_path
	match type:
		"male" : file_path = mname
		"female" : file_path = fname
		"last" : file_path = last
		"country" : file_path = country
		"job" : file_path = job

	var file = FileAccess.open(file_path, FileAccess.READ)

	if file:
		var content = file.get_as_text()
		file.close()
		var lines = content.split("\n")
		if lines.size() > 0:
			var rng = RandomNumberGenerator.new()
			var random_index = rng.randi() % lines.size()
			return lines[random_index]
		else:
			return "No names found"
	else:
		return "File not found"

func get_flag_image(country):

	var closest_png = ""
	var min_distance = INF

	for png_file in flag_file:
		var png_name = png_file.replace(".png", "")
		var distance = levenshtein_distance(country.to_lower(), png_name.to_lower())

		if distance < min_distance:
			min_distance = distance
			closest_png = png_file

	return closest_png


func find_closest_match(country_name: String, png_list: Array) -> String:
	var closest_png = ""
	var min_distance = INF  # Set initial distance to a very large number

	for png_file in png_list:
		var png_name = png_file.replace(".png", "")  # Remove the ".png" extension
		var distance = levenshtein_distance(country_name.to_lower(), png_name.to_lower())

		if distance < min_distance:
			min_distance = distance
			closest_png = png_file

	return closest_png



func levenshtein_distance(str1: String, str2: String) -> int:
	var len1 = str1.length()
	var len2 = str2.length()

	var dp = []
	for i in range(len1 + 1):
		dp.append([])
		for j in range(len2 + 1):
			dp[i].append(0)

	for i in range(len1 + 1):
		dp[i][0] = i
	for j in range(len2 + 1):
		dp[0][j] = j

	for i in range(1, len1 + 1):
		for j in range(1, len2 + 1):
			var cost = 0 if str1[i - 1] == str2[j - 1] else 1
			dp[i][j] = min(
				dp[i - 1][j] + 1,      # Deletion
				dp[i][j - 1] + 1,      # Insertion
				dp[i - 1][j - 1] + cost  # Substitution
			)
	return dp[len1][len2]

func get_flag_files():

	var dir = DirAccess.open("res://Assets/Character/Countries/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				print("Found file: " + file_name)
				if file_name.right(3) == "png":
					flag_file.append(file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

	print(flag_file)
