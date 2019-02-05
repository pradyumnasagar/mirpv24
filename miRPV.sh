#!/bin/bash
echo -n "welcome to miRPV\n"

if [ "$1" == "-h" ]; then
  echo -e "Usage:\nbash `basename $0` /path/to/fasta.fa"
  exit 0
fi

##prints help when miRPV path is not given
if [ "$1" == "" ]; then
  echo -e "Usage:\nbash `basename $0` /path/to/fasta.fa"
  exit 0
fi


miRPV_PATH=$1
