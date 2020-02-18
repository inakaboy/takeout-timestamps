#!/bin/bash

for imgpath in "$@"
do
	# construct json filename
		imgfile=`basename "$imgpath"`    		# remove path, get filename
		maxlen=46								# Default maximum length (not including extension)
		# Handle weird overlength filenames caused by unzip adding disambiguation when it encounters a duplicate filename. 
		len=`wc -c <<<"$imgfile"`
		if (($len > 52))
		then
			((maxlen = $maxlen + ($len - 52)))
		fi
		# trim filename to the maximuum length and add json extension
		jsonfile=${imgfile:0:$maxlen}.json
		# add back the path
		jsonpath=${imgpath%/*}/$jsonfile	
		
		
	echo "$imgpath		|		$jsonpath"   ## debug
	if [[ ! -f $jsonpath ]]; then
		 echo "***** ERROR couldnt find json for $imgfile *****"
	fi

	# exiftool has a bug in that it doesn't extract the timezone when using a specified tag, so we need to parse it from the full output (unamused)
		#	createdate=`/usr/local/bin/exiftool -s -s -s "$imgpath" -createdate -d "%Y:%m:%d %T %z"` # doesn't work because exiftool doesn't extract the timezone
	
  createdate=`exiftool -time:SubSecCreateDate -G1 -s "$imgpath" | grep Composite | sed -E -e 's/(:[0-9]+)\.[0-9]+/\1/g' -e 's/^[^0-9]*//'`
#	createdate=`/usr/local/bin/exiftool "$imgpath" | sed -n -e 's/^.*Create Date                     : //p' | tail -1`    		## added tail -1 exiftool can output multiple lines of Create Date; take the last one as a hacky solution
	echo "Create Date		     : $createdate"
	
	createstamp=`date -j -u -f "%Y:%m:%d %T%z" "$createdate" "+%s"`
	echo "Create Date		     : $createstamp"

	
	utime=`/usr/local/bin/jq -r <"$jsonpath" '.photoTakenTime.timestamp'`
	echo "JSON date		     : $utime"
	echo "JSON date		     :" `date -r $utime +"%Y:%m:%d %T %z"`
#	echo "JSON date		     :" `date -u -r $utime +"%Y:%m:%d %T %z"`
	
	# Check whether there is existing metadata
	
	# Double-check whether the metadata timestamp matches the JSON. If not, throw an error.
	
	# If no metadata, write from JSON
	
	

	
	# Touch the file to modify the file date to match the modifiedDate, or, if not available, the photoTakenTime
	
done
