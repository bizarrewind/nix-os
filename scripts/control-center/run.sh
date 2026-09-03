#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Start the python backend server
python3 "$DIR/server.py" &
SERVER_PID=$!

# Wait for server to be ready
sleep 0.5

# Open Chromium in app mode (popup window without tabs/URL bar)
if command -v chromium >/dev/null 2>&1; then
    chromium --class="ControlCenter" --app="http://127.0.0.1:8123"
elif command -v google-chrome-stable >/dev/null 2>&1; then
    google-chrome-stable --class="ControlCenter" --app="http://127.0.0.1:8123"
else
    # Fallback to xdg-open
    xdg-open "http://127.0.0.1:8123"
fi

# When browser closes, kill the python server
kill $SERVER_PID 2>/dev/null
