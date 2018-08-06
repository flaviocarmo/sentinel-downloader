#!/bin/bash

for scenename in `find . -mindepth 1 -maxdepth 1 -type d | cut -c 3-`
do
	echo "!!! processar $scenename !!!" 
	
	cd $scenename
	
	landsatscene=""
	
	
	for images in `find *.TIF`
	do
		landsatscene=$images
	done
	
	IFS='_' read -a Parts <<< "${landsatscene}"
	
	landsatscene="${Parts[0]}_${Parts[1]}_${Parts[2]}_${Parts[3]}_${Parts[4]}_${Parts[5]}_${Parts[6]}"
	
	#echo $landsatscene
	
	if [ ! -d "$DIRECTORY" ]; then
		mkdir tmp
	fi
	
	# Convert 16-bit images into 8-bit and tweak levels
	for BAND in {8,6,5,4}; do
		gdalwarp -t_srs EPSG:4326 "$landsatscene"_B"$BAND".TIF ./tmp/b"$BAND"-projected.TIF;
		gdal_contrast_stretch -ndv 0 -linear-stretch 70 30 ./tmp/b"$BAND"-projected.TIF ./tmp/b"$BAND"-8bit.TIF;
	done
	
	# Merge RGB bands into one image
	gdal_merge_simple -in ./tmp/b6-8bit.TIF -in ./tmp/b5-8bit.TIF -in ./tmp/b4-8bit.TIF -out ./tmp/rgb.TIF

	# Pan-sharpen RGB image
	gdal_landsat_pansharp -rgb ./tmp/rgb.TIF -lum ./tmp/rgb.TIF 0.25 0.23 0.52 -pan ./tmp/b8-8bit.TIF -ndv 0 -o ./tmp/pan.TIF

	# Colour correct and convert to JPG
	convert -verbose -channel B -gamma 0.8 -quality 95 ./tmp/pan.TIF ./tmp/final-pan-rgb-corrected.TIF

	#Apply geoinfo
	listgeo -tfw ./tmp/pan.TIF;
	mv ./tmp/pan.tfw ./tmp/final-pan-rgb-corrected.tfw;
	gdal_edit.py -a_srs EPSG:4326 ./tmp/final-pan-rgb-corrected.TIF;
	mv ./tmp/final-pan-rgb-corrected.TIF "$landsatscene"-pan-rgb-corrected.TIF;
	
	# limpar temp e ir para o proximo
	rm -rf ./tmp/

	cd ..
	
done
