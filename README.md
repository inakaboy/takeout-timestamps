# takeout-timestamps
Copy datestamp metadata from Google Photos Takeout JSON to the images so they can be uploaded elsewhere without losing date order

Google Photos' Takeout spits out a JSON file for each exported image (photo/video), but if the images themselves lack metadata, you will lose the date ordering unless you write the info that's in the JSON file to the metadata.

This script does the following:
- Grabs the metadata from the JSON file.
- Writes it to the "Create Date" metadata for both photos and videos, working around timezone issues.
- Updates the file's modified date to the modified date from the photo metadata, or if it lacks that, to the creation date from the Google Photos JSON.
- Fixes the filename back to the original if it was truncated by Google Takeout's weird 51 character filename truncation, working around filename conflicts created by the truncation. Commment this part out if your OS doesn't support long filenames.

The script works well in an Apple Automator workflow (sample included).


