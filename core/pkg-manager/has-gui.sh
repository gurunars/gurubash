# Prints `yes` when this machine has a desktop, `no` when it does not. A Mac always has one. On
# Linux it is what the machine boots into, not whether this shell has a display: an ssh session
# into a desktop still has a GUI, and a server has none. GUI_TARGET overrides the boot target, so
# a check can test both on any host.
if [ "$(uname -s)" = "Darwin" ]; then
  echo "yes"
  exit 0
fi

target=${GUI_TARGET:-$(systemctl get-default 2>/dev/null)}
if [ "$target" = "graphical.target" ]; then
  echo "yes"
else
  echo "no"
fi
