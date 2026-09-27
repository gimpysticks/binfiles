#/bin/sh

# $1 = user
# $2 = destinaionfiles
if [ $# -eq 0 ]
    then
        echo "USAGE: '$0' filename.pdf url"
        exit 1
fi
pandoc --pdf-engine=xelatex -f html -o "$1" "$2"
