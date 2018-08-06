#! /bin/bash

# Convert Landsat 8 GeoTIFF images into RGB pan-sharpened JPEGs.
#
# Requirements:
#              * gdal http://www.mapbox.com/tilemill/docs/guides/gdal/
#              * convert (image-magick)
#
# Reference info:
#                 http://www.mapbox.com/blog/putting-landsat-8-bands-to-work/
#                 http://www.mapbox.com/tilemill/docs/guides/gdal/
#                 http://www.mapbox.com/blog/processing-landsat-8/
#                 http://earthexplorer.usgs.gov/


if [[ -z "$1" ]]; then
	echo "Landsat image processing"
	echo ""
	echo "Converts to 8-bit, merges RGB, pan-sharpens, colour corrects and converts to JPG"
	echo "Example: process_landsat LC82010242013198LGN00"
	echo ""
	exit 0
fi

if [ ! -f ./"$1"_B4.TIF ]; then
	echo "File not found!"
	exit 0
fi

if [ ! -d "$DIRECTORY" ]; then
	mkdir tmp
fi	

# Convert 16-bit images into 8-bit and tweak levels
for BAND in {8,6,5,4}; do
	gdalwarp -t_srs EPSG:4326 "$1"_B"$BAND".TIF ./tmp/b"$BAND"-projected.tif;
	gdal_contrast_stretch -ndv 0 -linear-stretch 70 30 ./tmp/b"$BAND"-projected.tif ./tmp/b"$BAND"-8bit.tif;
done

# Merge RGB bands into one image
gdal_merge_simple -in ./tmp/b6-8bit.tif -in ./tmp/b5-8bit.tif -in ./tmp/b4-8bit.tif -out ./tmp/rgb.tif

# Pan-sharpen RGB image
gdal_landsat_pansharp -rgb ./tmp/rgb.tif -lum ./tmp/rgb.tif 0.25 0.23 0.52 -pan ./tmp/b8-8bit.tif -ndv 0 -o ./tmp/pan.tif

# Colour correct and convert to JPG
convert -verbose -channel B -gamma 0.8 -quality 95 ./tmp/pan.tif ./tmp/final-pan-rgb-corrected.tif

#apply geoinfo
listgeo -tfw ./tmp/pan.tif
mv ./tmp/pan.tfw ./tmp/final-pan-rgb-corrected.tfw
gdal_edit.py -a_srs EPSG:4326 ./tmp/final-pan-rgb-corrected.tif
mv ./tmp/final-pan-rgb-corrected.tif "$1"-pan-rgb-corrected.tif
rm -rf ./tmp/

echo "$1 OK!"

echo "Finished."