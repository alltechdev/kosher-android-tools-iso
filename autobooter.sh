#!/bin/bash

# Auto elevate
if [[ "$EUID" -ne 0 ]]; then
  exec sudo -H "$0" "$@"
fi

# Ensure correct PATH for the virtual environment
export PATH=/home/demo/.venv/bin:$PATH

# Activate venv
. /home/demo/.venv/bin/activate

# Change to the script directory
cd /opt/autobooter

# Launch the Python script
./autobooter.py
