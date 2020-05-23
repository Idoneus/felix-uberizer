#!/usr/bin/env bash

WORKDIR=".workdir"
OUTPUT_FOLDER=".workdir/output"

INPUT_FOLDER="$1"
DEBUG="$2"

curl -s https://oss.sonatype.org/service/local/repositories/releases/content/be/idoneus/felix/felix-bundle-extractor/1.0.1/felix-bundle-extractor-1.0.1.jar > "$WORKDIR"/felix-bundle-extractor.jar

if [ ! -z $DEBUG ]; then
	java -jar "$WORKDIR"/felix-bundle-extractor.jar -i "${INPUT_FOLDER}" -o "${OUTPUT_FOLDER}"
else 
	java -jar "$WORKDIR"/felix-bundle-extractor.jar -i "${INPUT_FOLDER}" -o "${OUTPUT_FOLDER}" >/dev/null 2>&1
fi
