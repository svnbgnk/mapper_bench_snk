#!/bin/bash
FILES=data/A_B_refseq_20170926_taxo_1024/*
for f in $FILES
do
  echo "Processing $f file..."
  # take action on each file. $f store current file name
  echo "Filename: ${f}"  >> $1
  cat $f | grep '>' >> $1
  echo "Filename: ${f}"  >> $1
done
