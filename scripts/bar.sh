#!/bin/dash

# ^c$var^ = fg color
# ^b$var^ = bg color

interval=0

# load colors
. ~/code/chadwm/scripts/bar_themes/catppuccin

cpu() {
  cpu_val=$(grep -o "^[^ ]*" /proc/loadavg)

  printf "^c$black^ ^b$green^ CPU"
  printf "^c$white^ ^b$grey^ $cpu_val"
}

pkg_updates() {
  updates=$(doas xbps-install -un | wc -l) # void
  # updates=$(checkupdates | wc -l)   # arch
  # updates=$(aptitude search '~U' | wc -l)  # apt (ubuntu,debian etc)

  if [ -z "$updates" ]; then
    printf "  ^c$green^    Fully Updated"
  else
    printf "  ^c$green^    $updates"" updates"
  fi
}

battery() {
  get_capacity="$(sb-battery)"
  printf "^c$blue^ $get_capacity"
}

weather() {
  get_weather="$(sb-weather -s -c "Yekaterinburg")"
  printf "^c$green^ $get_weather"
}

volume() {
  vol="$(pamixer --get-volume)"

  if [ "$vol" -gt 70 ]; then
	  icon=""
  elif [ "$vol" -gt 50 ]; then
	  icon="墳"
  elif [ "$vol" -gt 30 ]; then
	  icon=""
  elif [ "$vol" -gt 0 ]; then
	  icon=""
  else
        icon="婢"
  fi
  printf "^c$red^ $icon "
  printf "^c$red^%.0f\n" $vol
}

mem() {
  printf "^c$blue^^b$black^  "
  printf "^c$blue^ $(free -h | awk '/^Mem/ { print $3 }' | sed s/i//g)"
}

wlan() {
	case "$(cat /sys/class/net/wl*/operstate 2>/dev/null)" in
	up) printf "^c$black^ ^b$blue^ 󰤨 ^d^%s" " ^c$blue^Connected" ;;
	down) printf "^c$black^ ^b$blue^ 󰤭 ^d^%s" " ^c$blue^Disconnected" ;;
	esac
}

clock() {
	printf "^c$black^ ^b$darkblue^ 󱑆 "
	printf "^c$black^^b$blue^ $(date '+%H:%M')  "
}

while true; do

  [ $interval = 0 ] || [ $(($interval % 3600)) = 0 ] && weather=$(weather)
  interval=$((interval + 1))

  sleep 1 && xsetroot -name "  $(cpu) $(mem) $(wlan) $(battery) $(volume) $weather $(clock)"
done
