#!/usr/bin/env bash

WORKDIR="$1"
INPUT_FOLDER="$2"
OUTPUT_FOLDER="$3"

curl -s https://oss.sonatype.org/service/local/repositories/releases/content/be/idoneus/felix/felix-bundle-extractor/1.0.1/felix-bundle-extractor-1.0.1.jar > "$WORKDIR"/felix-bundle-extractor.jar

java -jar "$WORKDIR"/felix-bundle-extractor.jar -i "${INPUT_FOLDER}" -o "${OUTPUT_FOLDER}" >/dev/null 2>&1