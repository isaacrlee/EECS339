#!/bin/bash

if [ $# -ne 1 ]
then
  echo "usage: fetch.sh year-range"
fi

yr=$1
if [ $yr -eq 0 ]
then
  yr2=99
else
  yr2=$(( $yr - 1 ))
fi

pre=20

if [ $yr -gt 50 ]
then
  pre=19
fi

mkdir `printf "%02d%02d\n" $yr2 $yr`

cd `printf "%02d%02d\n" $yr2 $yr`
for i in 'cm' 'cn' 'ccl' 'indiv' 'pas2' 'oth'
do
  wget `printf "ftp://ftp.fec.gov/FEC/$pre%02d/$i%02d.zip" $yr $yr`
done
