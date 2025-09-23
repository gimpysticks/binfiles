ffmpeg -i $file -deinterlace -ar 44100 -r 25 -qmin 3 -qmax 6 $new_filename
