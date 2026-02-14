#!/bin/bash

# persistent tmux environment
tmux new-session -d -s main

# start JupyterLab (MineX13)
jupyter lab \
  --ip=127.0.0.1 \
  --port=8888 \
  --no-browser \
  --allow-root \
  --NotebookApp.token='' \
  --LabApp.app_name="MineX13 Workspace" &

# web SSH terminal
ttyd -p 7681 bash &

# dashboards
python3 /specs.py &
python3 /gpu.py &
python3 /help.py &
python3 /about.py &

# start nginx
nginx -g "daemon off;"
