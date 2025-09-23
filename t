#!/bin/bash
set -e

# Updates YouTube and Twitch Titles, sets the GitHub profile status, and
# sends a tweet pointing to the YouTube video.

topic="$*"

while test -z "${topic}"; do
  read -p "Topic: " topic
done

# change these do solarized/gruvbox variations (not millions)
if [[ -t 1 ]]; then
  GOLD=$'\033[38;2;184;138;0m'
  RED=$'\033[38;2;255;0;0m'
  GREY=$'\033[38;2;100;100;100m'
  CYAN=$'\033[38;2;0;255;255m'
  GREEN=$'\033[38;2;0;255;0m'
  X=$'\033[0m'
fi

fatal() {
  echo "${RED}$*${X}"
  exit 1
}

short="${topic%%#*}"
if [[ ${#short} > 80 ]]; then
  fatal 'Topic must be under 80 characters'
fi
zetid="[$(isosec)]"

TWITCH_TOKEN=$(auth token twitch)
TWITCH_CLIENTID=$(auth get id twitch)

set_twitter_status() {
  if [[ "${YOUTUBE_VIDEO}" == null ]]; then
    return
  fi
  if [[ $topic =~ ^\[ ]]; then
    return
  fi
  twitter update "📺 ${topic} ${zetid} #livestream https://youtu.be/${YOUTUBE_VIDEO}?t=$(vidoffsetsec)"
}
#set_twitter_status
if test "$topic" = default; then
  topic="$(head -1 $HOME/.banner)"
  pomo stop
else
  echo "$topic" >>"$HOME/.topics"
  w
  pomo start
fi
echo "$topic" >"$HOME/.tmux-live-right" &
twitch title "$topic" &
yt title "$topic" &>/dev/null &
twitter update "📺 $topic #livestream #status #update $(yt live)" &
gh live "$topic" &
f "${topic}" &
