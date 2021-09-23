#!/bin/bash

set -e


abort()
{
    echo >&2 '
***************
*** ABORTED ***
***************
'
    echo "An error occurred. Exiting..." >&2
    exit 1
}

trap 'abort' 0

cd ruby
echo "--- Ruby tests ---"

echo -n "example01"
ruby example01.rb | grep Services > /dev/null
echo " ok !"

echo -n "example02"
ruby example02.rb | grep Vms > /dev/null
echo " ok !"

echo -n "example03"
ruby example03.rb | grep Net > /dev/null
echo " ok !"
cd ..

cd c
echo "--- C tests ---"
echo "compile"
make clean
make
echo -n "example01"
./example01 | grep Images > /dev/null
echo " ok !"

echo -n "example02"
./example02 > out
echo [ $( sed s/}{/},{/g out ) ]  > out
json-search  "SecurityGroup" out > /dev/null # check create
json-search "SecurityGroups" out > /dev/null # check read
# test 3 request have been executed
[ $(cat out | json-search   "RequestId"  | wc -l) == "5" ]
rm out
echo " ok !"

echo -n "example03"
./example03 | grep Images > /dev/null
echo " ok !"
cd ..

cd rust
echo "--- Rust Test ---"
echo "example01"
cargo run --example example01 | json-search "City" > /dev/null
echo " ok !"

echo "example02"
cargo run --example example02 | json-search "City" > /dev/null
echo " ok !"

echo "example03"
cargo run --example example03 | json-search "Vms" > /dev/null
echo " ok !"
cd ..

trap - 0