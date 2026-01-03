#!/bin/bash
# Serves newtab directory on localhost:8384

cd ~/.config/tridactyl/newtab
python3 -m http.server 8384 --bind 127.0.0.1 >/dev/null 2>&1
