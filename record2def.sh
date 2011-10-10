#/usr/bin/sh
#
# Converts recordbank format to ing format
# param1: input file in recordbank format

if [ -z $1 ] || [ -z $2 ]
then
	echo "Usage: $0 recordbank_CSV_file accountnumber"
	echo "Gebruik: $0 recordbank_CSV_file rekeningnummer"
	exit 1
fi
infile=$1
accnr=$2

# Convert ',' separators to ';' to avoid problems in amounts with separators
# In order to only select comma separators I've included the preceeding
# or following double quote or converted 2 consecutive quotes
sed -e's/,"/;"/g' -e 's/",/";/g' -e's/,,/;;/g' $infile | awk -v rekening=$accnr -f recordbank2def.awk 
