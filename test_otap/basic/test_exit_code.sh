#!/bin/bash
echo "Exit code 0"
./test.sh 0
echo "Return $?"
echo "Exit code 1"
./test.sh 1
echo "Return $?"
echo "Exit code 2"
./test.sh 2
echo "Return $?"
echo "Exit code -1"
./test.sh -1
echo "Return $?"