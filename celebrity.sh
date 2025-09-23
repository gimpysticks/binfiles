#/bin/bash
>~/multiurls
url="$1"
for((x=$2;x<=$3;x++));
do
 echo "$url""/"$x"/">>~/multiurls
done

