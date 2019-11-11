#!/bin/sh

set -e

BASEDIR=`dirname "$0"`
ACPI="$BASEDIR/../ACPI"
THUNDERBOLT="$BASEDIR/../Thunderbolt"
PACKAGES_BUILD=/usr/local/bin/packagesbuild
DATA="$BASEDIR/data"
IASL="$DATA/ACPI/iasl"

if [ ! -f "$PACKAGES_BUILD" ]; then
    echo "Please install http://s.sudre.free.fr/Software/Packages/about.html"
    exit 1
fi

echo "Downloading and extracting required files..."

find "$DATA" -name 'source.txt' -type f | \
while read line
do
    output=`dirname "$line"`
    url=`head -1 "$line" | xargs echo -n`
    file=`basename "$url"`
    hash=`tail -1 "$line" | xargs echo -n`
    if [ ! -f "$file" ]; then
        echo "Downloading $url"
        curl -L "$url" -o "$file"
    fi
    check=`shasum -a 256 "$file" | cut -d ' ' -f 1`
    echo "Hash: $check"
    if [ "$check" != "$hash" ]; then
        echo "Hash check failed, expected $hash"
        echo "Please delete $file to redownload"
        exit 1
    fi
    echo "Extracting $file to $output"
    unzip -o "$file" -d "$output"
done

echo "Compiling ASL..."
if [ ! -f "$IASL" ]; then
    echo "iasl not found"
    exit 1
fi
find "$ACPI" -name '*.asl' -depth 1 -exec "$IASL" \{\} \;
find "$ACPI" -name '*.aml' -depth 1 -exec mv \{\} "$DATA/ACPI" \;

echo "Compiling Thunderbolt patcher..."
TBPATCHAPP="$DATA/ThunderboltNative/Thunderbolt Patcher.app"
rm -rf "$TBPATCHAPP"
osacompile -o "$TBPATCHAPP" -x "$THUNDERBOLT/TBPatchLauncher.applescript"
mkdir "$TBPATCHAPP/Applications"
mv "$DATA/ThunderboltNative/TBPatch.app" "$TBPATCHAPP/Applications/"
mkdir "$TBPATCHAPP/Resources"
cp "$THUNDERBOLT/NUC_Hades_Canyon_Apple_Mode.plist" "$TBPATCHAPP/Resources/"

echo "Building package..."

$PACKAGES_BUILD -v "$BASEDIR/Package.pkgproj"

echo "Fixing up package..."

# patch up dst selection screen
rm -rf "$BASEDIR/build/HaCMini"
pkgutil --expand "$BASEDIR/build/HaCMini.pkg" "$BASEDIR/build/HaCMini"
sed 's/enable_currentUserHome="false"//g;s/enable_localSystem="false"//g' "$BASEDIR/build/HaCMini/Distribution" > "$BASEDIR/build/HaCMini/Distribution.new"
mv "$BASEDIR/build/HaCMini/Distribution.new" "$BASEDIR/build/HaCMini/Distribution"
pkgutil --flatten "$BASEDIR/build/HaCMini" "$BASEDIR/build/HaCMini.pkg"
rm -rf "$BASEDIR/build/HaCMini"
