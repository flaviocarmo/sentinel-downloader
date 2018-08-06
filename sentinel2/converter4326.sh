#!/bin/bash

for scenename in `find *.tif`
do
	gdalwarp -t_srs EPSG:4326 "$scenename" "$scenename-4326.tif"
	rm -f "$scenename"
	echo "$scenename-4326.tif OK!"
done

exit 0