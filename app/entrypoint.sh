#!/usr/bin/env bash
set -euo pipefail

_term() {
  echo "bye"
  exit 0
}

trap _term TERM INT

mkdir -p /root/.kube

(
  >/dev/null 2>&1 rm /tmp/.X0-lock || true
  exec Xvfb :0 -screen 0 1366x768x24 -ac -listen tcp
) >/tmp/xvfb.log 2>&1 &
echo $! >/tmp/xvfb.pid


(
  wait-for localhost:6000
  exec x11vnc -display :0 -shared -nopw -forever
) >/tmp/x11vnc.log 2>&1 &
echo $! >/tmp/x11vnc.pid

(
  wait-for localhost:5900
  exec node /opt/websockify-js/websockify/websockify.js  --web /app/public ":$PORT" 127.0.0.1:5900
) >/tmp/websockify.js 2>&1 &
websockify_pid=$!

(
  cd /opt/lens
  while true; do
    ./kontena-lens --no-sandbox
  done
) >/tmp/lens.log 2>&1 &
echo $! >/tmp/lens.pid

echo "listening at port :$PORT"
tail -f /dev/null &
wait $!
