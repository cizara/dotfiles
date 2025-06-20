#!/bin/sh

class=$(playerctl metadata --player='spotify,YoutubeMusic,chromium.instance2' --format '{{lc(status)}}')
icon=""

if [[ $class == "playing" ]]; then
  info=$(playerctl metadata --player='spotify,YoutubeMusic,chromium.instance2' --format '{{artist}} - {{title}}' | sed 's/"//g')
  if [[ ${#info} > 50 ]]; then
    info=$(echo $info | cut -c1-50)"..."
  fi
  text=$info" "$icon
elif [[ $class == "paused" ]]; then
  text=$icon
elif [[ $class == "stopped" ]]; then
  text=""
fi

echo -e "{\"text\":\""$text"\", \"class\":\""$class"\"}"
