#!/bin/bash

function notify {
  curl --silent --output /dev/null -X POST -H "Content-Type: application/json" -d "{\"value1\":\"$1\"}" https://maker.ifttt.com/trigger/notify/with/key/$IFTTT_KEY
}

function get_text {
  working=true
  while $working; do 
    working=false
    for i in ${!sites[@]}; do
      wget -O $1$i ${sites[$i]} -o /dev/null
      if ! [ $? -eq 0 ]; then
        echo Site down: ${sites[$i]}
        working=true
      else 
        sed -i -e 's/<[^>]*>//g' $1$i
      fi
    done
    if $working; then
      sleep 10
    fi
  done
}

sites=("https://raspberrypi.org" "https://www.raspberrypi.org/forums/viewforum.php?f=117")

get_text site

stars=0

while true; do
  get_text out

  for i in ${!sites[@]}; do
    diff -w -B site$i out$i --ignore-matching-lines="<script" --ignore-matching-lines="div id=" --ignore-matching-lines="data-cfemail" --ignore-matching="app.php" --ignore-matching="transactionName"
    if [ $? -eq 1 ]; then
      echo CHANGE DETECTED: ${sites[$i]}
      notify "Change detected in ${sites[$i]}"
      while true; do
          aplay ding.wav 2>/dev/null
      done
    else
      stars=$((stars+1))
      echo -ne '*'
      if [ $stars -eq 16 ]; then
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

