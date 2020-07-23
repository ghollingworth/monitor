#!/bin/bash

function capture_url {
  node capture.js $1 $2
}

function notify {
  curl --silent --output /dev/null -X POST -H "Content-Type: application/json" -d "{\"value1\":\"$1\"}" https://maker.ifttt.com/trigger/notify/with/key/$IFTTT_KEY
}

sites=("https://raspberrypi.org" "https://www.raspberrypi.org/forums/viewforum.php?f=117")
failed=(0 0)

notify "Starting monitor with ${#sites[@]} sites"

for i in ${!sites[@]}; do
  capture_url ${sites[$i]} site$i.png 
done

stars=0


while true; do
  for i in ${!sites[@]}; do
    capture_url ${sites[$i]} out$i.png
  done

  for i in ${!sites[@]}; do
    convert site$i.png out$i.png -crop 1024x1024+0+0 +repage miff:- | compare -metric AE - diff.png 2> diff.txt
    result=`cat diff.txt`
    if [ $result -gt 500 ]; then
      echo $i failed
      failed[$i]=$((failed[i]+1))
      if [ ${failed[$i]} -gt 4 ]; then
        echo CHANGE DETECTED: ${sites[$i]}
        notify ${sites[$i]}
        xloadimage diff.png
        while true; do
            aplay ding.wav 2>/dev/null
        done
      fi
    else
      failed[$i]=0
      stars=$((stars+1))
      echo -ne '*'
      if [ $stars -eq 40 ]; then
        stars=0
        echo -ne '\r                            \r'
      fi
    fi
  done
  for i in `seq 9`; do
    echo -ne "\b$i"
    sleep 1
  done
  echo -ne '\b \b'
done

