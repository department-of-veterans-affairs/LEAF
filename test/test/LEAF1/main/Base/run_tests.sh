#!/bin/bash

set -exuo pipefail

export TEST_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "Using TEST_DIR = $TEST_DIR"

echo "Removing old coverage files"
mkdir -p /var/www/html/test/cov
find /var/www/html/test/cov -mindepth 1 ! \( -name .gitignore \) -delete

echo "Truncating XDebug coverage file"
truncate -s 0 /var/www/html/test/profile_output/cachegrind.out || true

echo "Running Nexus tests"
cd /var/www/html/test/LEAF_Nexus_Tests

phpunit --colors --bootstrap ../bootstrap.php --no-configuration tests || true

echo "Running Portal tests"
cd /var/www/html/test/LEAF_Request_Portal_Tests

phpunit --colors --bootstrap ../bootstrap.php --no-configuration  tests || true

echo "Generating Coverage Report"
cd /var/www/html/test/prepend/
./vendor/bin/phpcov merge --html="../cov/report/" ../cov -vvv

(
  # Rename coverage report api folder due to apache ReWrite Rule.
  cd ../cov/report/
  mv LEAF_Nexus/api LEAF_Nexus/api-test
  mv LEAF_Request_Portal/api LEAF_Request_Portal/api-test
  sed -e 's|api/index|api-test/index|g' -i'' LEAF_Nexus/index.html
  sed -e 's|api/index|api-test/index|g' -i'' LEAF_Request_Portal/index.html
)

echo "Coverage Report: http://localhost/test/cov/report/"

