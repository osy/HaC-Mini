#!/bin/sh

set -e

PACKAGES_BUILD=/usr/local/bin/packagesbuild

$PACKAGES_BUILD -v Package.pkgproj

# patch up dst selection screen
rm -rf "build/HaCMini"
pkgutil --expand "build/HaCMini.pkg" "build/HaCMini"
sed 's/enable_currentUserHome="false"//g;s/enable_localSystem="false"//g' "build/HaCMini/Distribution" > "build/HaCMini/Distribution.new"
mv "build/HaCMini/Distribution.new" "build/HaCMini/Distribution"
pkgutil --flatten "build/HaCMini" "build/HaCMini.pkg"
rm -rf "build/HaCMini"
