#!/bin/bash

for folder in *; 
do
  if [ -d $folder ];
  then
    cd $folder;
    for arch in *;
    do
      unzip $arch;
    done;
    rm *.zip;
    cd ..
  fi;
done
