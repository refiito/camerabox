#!/usr/bin/env bash
set -o errexit # abort on first unsucessfull line

BASEDIR=$(date +"%Y%m%d" --date="1 days ago")

# set captions for images
for img in ${BASEDIR}/*.jpg; do
  width=$(identify -format %W ${img})
  width=$(( ${width} * 9 / 10 ))

  convert                  \
    -background '#0008'    \
    -gravity center        \
    -fill white            \
    -size ${width}x100     \
      caption:"${img}"     \
      "${img}"             \
    +swap                  \
    -gravity south         \
    -composite             \
     "${img}"
done

# lets make the movie
echo "ffmpeg -pattern_type glob -i '${BASEDIR}/*.jpg'  -c:v libx264 -vf scale=800:-1 ${BASEDIR}.mp4" > ffmpeg_script.sh
# quick view movie
echo "ffmpeg -i ${BASEDIR}.mp4 -filter:v 'setpts=0.25*PTS' ${BASEDIR}_short.mp4" >> ffmpeg_script.sh
chmox +x ffmpeg_script.sh
./ffmpeg_script.sh

# cycle image files, keeping last 2 days
REMOVABLE_DIR=$(date +"%Y%m%d" --date="3 days ago")
rm -fr ${REMOVABLE_DIR}
