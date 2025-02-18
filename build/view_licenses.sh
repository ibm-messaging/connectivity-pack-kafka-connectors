#!/bin/bash

set -eu

echo "Viewing Licenses"

licenses=( ./licenses/*/LI_en )
for l in ${licenses[@]}; do
  echo "**************************************************************"
  echo "printing license $l"
  echo "**************************************************************"
  cat $l
  echo ""
  echo ""
done