#!/bin/bash

filename=$1
IFS=$'\n'
for link in `cat $filename`
do
	originallink=$link
	
	LINK2="$originallink/B02.jp2"
	LINK3="$originallink/B03.jp2"
	LINK4="$originallink/B04.jp2"
	LINK8="$originallink/B08.jp2"
	
	OIFS="$IFS"
	IFS='/' read -a Parts <<< "${link}"
	IFS="$OIFS"
	
	FILE="${Parts[4]}${Parts[5]}${Parts[6]}-${Parts[7]}-${Parts[8]}-${Parts[9]}-${Parts[10]}" 
	
	FILE2="$FILE-B02.jp2"
	FILE3="$FILE-B03.jp2"
	FILE4="$FILE-B04.jp2"
	FILE8="$FILE-B08.jp2"
	
	wget --continue $LINK2 -O $FILE2 --progress=bar
	wget --continue $LINK3 -O $FILE3 --progress=bar
	wget --continue $LINK4 -O $FILE4 --progress=bar
	wget --continue $LINK8 -O $FILE8 --progress=bar
done
exit 0