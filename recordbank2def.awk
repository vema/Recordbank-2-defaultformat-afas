#
# Awk script to convert KBC to ING format (Yunoo)
#
# Reads in RECORDBANK file
# Make sure the ',' are replaced by ';'
# Writes to CSV ING style file

BEGIN {
	FS=";"
	Header = "\"Datum\",\"Begunstigde\",\"Rekening\",\"Tegenrekening\",\"Mutatiecode\",\"Af/Bij\",\"Bedrag\",\"Mutatiesoort\",\"Mededelingen\n"
	printf ("%s", Header)
	rekening = "\"" rekening "\""
}

function datum_omrekenen (instr) {
	split(instr,dat,"-")
	date=sprintf("\"%d%02d%02d\"", strtonum(dat[3]), strtonum(dat[2]), strtonum(dat[1]))
	return date
}

# Zet het bedrag om naar absolute cijfers met een komma
function bedrag_berekenen(bedrag_in) {
	# print "-" bedrag_in "-"
	# converteer het getal naar een genormalizeerde vorm.
	# Dit hangt samen met de locale van de computer.
	# Mogelijk moet dit per gebruiker aangepast worden
	# bv "-2,000,000.10" -> "-2000000.10"
	# stap 1: haal alle ',' (duizend) eruit
	sub (",","",bedrag_in)
	# Splits de 'EUR' van het bedrag
	if (bedrag_in ~ /^"-/) {
	#	print "begint met een quote en is negatief" 
		split(substr(bedrag_in,3,length(bedrag_in)-3),res," ")
	} else if (bedrag_in ~/^"/) {
	#	print "begint met een quote en is positief" 
		split(substr(bedrag_in,2,length(bedrag_in)-2),res," ")
	} else if (bedrag_in "^-") { 
	#	print "begint zonder quote en is negatief" 
		split(substr(bedrag_in,2,length(bedrag_in)-2),res," ")
	#	print res[1] "-" res[2] - length(bedrag_in)
	} else {
	#	print "begint zonder quote en is positief" 
		split(bedrag_in,res," ")
	}
	# print res[1] "::" res[2]
	# stap 2: vervang de '.' door een ','
	sub("[[:punct:]]",",",res[1])
	#print res[1]
	return res[1]
}

/[[:digit:]{2}]-[[:digit:]{2}]/ {
	# print $0
	datum=datum_omrekenen($1)
	mutatiecode="\"\""
	if (length($4) == 0) {
		mededelingen="\"" "\""
	} else {
		mededelingen=$4
	}
	#print $3 "--" length($3)
	if (length($3) == 0) {
		tegenrekening="\"" "\"" 
	} else {
		tegenrekening=$3
	}
	mutatiesoort=$2
	bedr=bedrag_berekenen($5)
	# print "|" $5 "|"
	if ( $5 ~ /"?-/ ) {
		afbij="\"Af\""
	} else {
		afbij="\"Bij\""
	}

	printf("%s,%s,%s,%s,%s,%s,\"%s\",%s,%s\n",datum,mededelingen,
		rekening,tegenrekening,mutatiecode,afbij,
		bedr,mutatiesoort,mededelingen)
}
