#!/bin/bash

for file in *.txt; do
  sed -i 's/[^[:print:]]//' $file
done
