#!/bin/sh
STATE=$(eww state | grep volume-visible | awk '{print $2}' | tr -d '"')
if [ "$STATE" = "true" ]; then
  eww update volume-visible=false
  eww close volume-popup
else
  eww update volume-visible=true
  eww open volume-popup
fi
