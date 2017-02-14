#!/bin/bash

# cd to the directory files should be fetched to
cd ../fec

# fetch the data for each cycle
for i in 12 10 8 6 4 2 0 98 96 94 92 90 88 86 84 82 80
do
  ./fetch.sh $i
done

# unzip the data and remove archives
./unzipper.sh
