youtube-dl --skip-download --print-json "$1" |jq -r 'to_entries[] | "\(.key):\(.value)"' > /tmp/tmp.ytdata && nvim /tmp/tmp.ytdata
