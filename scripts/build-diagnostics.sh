#!/bin/sh
set -u

echo "--- OS info ---"
cat /etc/os-release 2>&1 || echo "no /etc/os-release"

echo "--- whoami ---"
whoami 2>&1

echo "--- python3 ---"
python3 --version 2>&1 || echo "no python3"

echo "--- pip3 ---"
pip3 --version 2>&1 || echo "no pip3"

echo "--- root write test (/usr/local/bin) ---"
if touch /usr/local/bin/.write-test 2>&1; then
  echo "root write OK"
  rm -f /usr/local/bin/.write-test
else
  echo "no root write access"
fi

echo "--- writing build marker ---"
echo "built-by-launch-ci" > build-marker.txt
cat build-marker.txt
