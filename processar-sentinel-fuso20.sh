#!/bin/bash

IFS=$'\n'
scenes=()

in_array() {
    local haystack=${1}[@]
    local needle=${2}
    for i in ${!haystack}; do
        if [[ ${i} == ${needle} ]]; then
            return 0
        fi
    done
    return 1
}

for bandfile in `find *.jp2`
do
	OIFS="$IFS"
	IFS='-' read -a Parts <<< "${bandfile}"
	IFS="$OIFS"
	
	scenes+=("${Parts[0]}-${Parts[1]}-${Parts[2]}-${Parts[3]}-${Parts[4]}")
done

singleScenes=()

for scene in "${scenes[@]}"
do
	in_array singleScenes "${scene}" || singleScenes+=($scene)
done

echo "${#singleScenes[@]}"

for scenename in "${singleScenes[@]}"
do
	convert "$scenename-B04.jp2" "$scenename-B03.jp2" "$scenename-B02.jp2" -combine "$scenename-RGB.tif"
	convert -sigmoidal-contrast 50x0% "$scenename-RGB.tif" "$scenename-RGB-corrected.tif"
	convert -depth 8 "$scenename-RGB-corrected.tif" "$scenename-RGB-corrected-8bit.tif"
	gdalwarp -of gtiff "$scenename-B04.jp2" "$scenename-B04.tif"
	listgeo -tfw "$scenename-B04.tif"
	mv $scenename-B04.tfw "$scenename-RGB-corrected-8bit.tfw"
	gdal_edit.py -a_srs EPSG:32720 "$scenename-RGB-corrected-8bit.tif"
	rm -f "$scenename-B04.tif"
	rm -f "$scenename-RGB.tif"
	rm -f "$scenename-RGB-corrected.tif"
	rm -f "$scenename-RGB-corrected-8bit.tfw"
	rm -f "$scenename-B04.tif"
	rm -f "$scenename-B02.jp2"
	rm -f "$scenename-B03.jp2"
	rm -f "$scenename-B04.jp2"
	echo "$scenename-RGB-corrected-8bit.tif OK!"
done


exit 0