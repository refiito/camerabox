#!/usr/bin/env bash
set -o errexit # abort on first unsucessfull line

BASEDIR=$(date +"%Y%m%d")
SUBHOUR=$(date +"%H" --date="2 hour ago")

mkdir -p ${BASEDIR}/working/${SUBHOUR}00
# set captions for images
for img in ${BASEDIR}/${SUBHOUR}00/*.jpg; do
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

  mv ${img} ${BASEDIR}/working/${SUBHOUR}00
done

echo "ffmpeg -pattern_type glob -i '${BASEDIR}/working/${SUBHOUR}00/*.jpg'  -c:v libx264 -vf scale=800:-1 ${BASEDIR}_${SUBHOUR}00.mp4" > ffmpeg_script.sh
# quick view movie
echo "ffmpeg -i ${BASEDIR}_${SUBHOUR}00.mp4 -filter:v 'setpts=0.25*PTS' ${BASEDIR}_${SUBHOUR}00_short.mp4" >> ffmpeg_script.sh
chmod +x ffmpeg_script.sh
./ffmpeg_script.sh

# cycle image files, keeping last 2 days
REMOVABLE_DIR=$(date +"%Y%m%d" --date="3 days ago")
rm -fr ${REMOVABLE_DIR}
