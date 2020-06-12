#!/usr/bin/env bash

WORKDIR=".workdir"
OUTPUT_FOLDER=".workdir/output"

INPUT_FOLDER="$1"
EXCLUDE_GROUP_IDS="$2"
EXCLUDE_ARTIFACT_IDS="$3"
DEBUG="$4"

# Can be used when developing
# curl -s https://oss.sonatype.org/service/local/artifact/maven/redirect?r=snapshots&g=be.idoneus.felix&a=felix-bundle-extractor&v=LATEST > "$WORKDIR"/felix-bundle-extractor.jar

# Production URL for bundle extractor
curl -s https://oss.sonatype.org/service/local/repositories/releases/content/be/idoneus/felix/felix-bundle-extractor/1.1.1/felix-bundle-extractor-1.1.1.jar > "$WORKDIR"/felix-bundle-extractor.jar

# Executing the felix bundle extractor. Defaulting to not extracting non maven artifacts
if [ ! -z $DEBUG ]; then
	java -jar "$WORKDIR"/felix-bundle-extractor.jar -i "${INPUT_FOLDER}" -o "${OUTPUT_FOLDER}" -enma -eg "${EXCLUDE_GROUP_IDS}" -ea "${EXCLUDE_ARTIFACT_IDS}" 
else 
	java -jar "$WORKDIR"/felix-bundle-extractor.jar -i "${INPUT_FOLDER}" -o "${OUTPUT_FOLDER}" -enma -eg "${EXCLUDE_GROUP_IDS}" -ea "${EXCLUDE_ARTIFACT_IDS}" >/dev/null 2>&1
fi
