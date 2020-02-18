#!/bin/bash


verbosity=6
	### verbosity levels
	crt_lvl=1
	err_lvl=2
	wrn_lvl=3
	dbg_lvl=6
	
 
## esilent prints output even in silent mode
function ewarn ()  { verb_lvl=$wrn_lvl elog "WARNING - $@" ;}
function edebug () { verb_lvl=$dbg_lvl elog "DEBUG --- $@" ;}
function eerror () { verb_lvl=$err_lvl elog "ERROR --- $@" ;}
function ecrit ()  { verb_lvl=$crt_lvl elog "FATAL --- $@" ;}
function edumpvar () { for var in $@ ; do edebug "$var=${!var}" ; done }
function elog() {
        if [ $verbosity -ge $verb_lvl ]; then 
				echo -e "$@"
#                datestring=`date +"%Y-%m-%d %H:%M:%S"`; echo -e "$datestring - $@"
        fi
}
  

#### START

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
		
		
	edebug "$imgpath		|		$jsonpath"   ## debug
	if [[ ! -f $jsonpath ]]; then
		 eerror "ERROR couldnt find json for $imgfile"
	fi

	# exiftool doesn't output the timezone by default when extracting -CreateDate tag, so
	# the sed line strips the line header, removes the milliseconds, and removes the colon from the timezone so that we can convert it back to an epoch string via the date command
	createdate=`/usr/local/bin/exiftool -time:SubSecCreateDate -G1 -s "$imgpath" | grep Composite | sed -E -e 's/(:[0-9]+)\.[0-9]+/\1/g' -e 's/^[^0-9]*//' -e 's/([\+\-][0-9][0-9])\:/ \1/'`
	edebug "Create Date		     : $createdate"
	
	createstamp=`date -j -u -f "%Y:%m:%d %T %z" "$createdate" "+%s"`
	edebug "Create Date		     : $createstamp"
	
	utime=`/usr/local/bin/jq -r <"$jsonpath" '.photoTakenTime.timestamp'`
	edebug "JSON date		     : $utime"
	edebug "JSON date		     :" `date -r $utime +"%Y:%m:%d %T %z"`
	
	# Check whether there is existing metadata
	
	# Double-check whether the metadata timestamp matches the JSON. If not, throw an error.
	
	# If no metadata, write from JSON
	
	

	
	# Touch the file to modify the file date to match the modifiedDate, or, if not available, the photoTakenTime
	
done
