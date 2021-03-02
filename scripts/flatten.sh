#!/bin/sh

rm -rf flats/*

files=(
    ./contracts/FOSC.sol
)

for filename in "${files[@]}"; do
    name=${filename##*/}
    ./node_modules/.bin/truffle-flattener $filename > ./flats/${name%.*}Flattened.sol

    sed -i '/SPDX-License-Identifier: Unlicense/d' ./flats/${name%.*}Flattened.sol

    echo "|> $filename ** Flattened"
done
