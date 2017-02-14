#!/bin/bash

for folder in 1112 0910 0708 0506 0304 0102 9900 9798 9596 9394 9192 8990 8788 \
  8586 8384 8182 7980; do
  if [ -d $folder ]; then
    cd $folder
    for file in *; do
      cat $file >> ../$file
    done
    cd ..
  fi
done
