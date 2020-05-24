#!/usr/bin/env bash

set -euo pipefail

trap break INT

# Default include all group ids
INCLUDE_GROUP_IDS=".*"
EXCLUDE_GROUP_IDS=""

# Default include all artifacts
EXCLUDE_ARTIFACT_IDS=""

# Default input folder, used mainly in the Dockerfile
INPUT_FOLDER=/tmp/felix-uberizer/input

# Default disable debug
DEBUG=""

# Read all input parameters
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -s|--input-folder) INPUT_FOLDER="$2"; shift ;;
        -g|--group-id) GROUP_ID="$2"; shift ;;
        -a|--artifact-id) ARTIFACT_ID="$2"; shift ;;
        -v|--version) VERSION="$2"; shift ;;
        -ig|--include-group-ids) INCLUDE_GROUP_IDS="$2"; shift ;;
        -eg|--exclude-group-ids) EXCLUDE_GROUP_IDS="$2"; shift ;;
        -ea|--exclude-artifact-ids) EXCLUDE_ARTIFACT_IDS="$2"; shift ;;
        -d|--debug) DEBUG=1 ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Create target folder
mkdir -p "target"

# Create temporary work directory
WORKDIR=".workdir"
mkdir -p "$WORKDIR"

EXTRACTOR_OUTPUT_FOLDER="${WORKDIR}/output"

echo "Creating artifacts and sources based on the input folder"
bash libs/create-artifacts-and-sources.sh "$INPUT_FOLDER" "$EXCLUDE_GROUP_IDS" "$EXCLUDE_ARTIFACT_IDS" "$DEBUG" 

echo "Creating uber jar based on the artifacts folder"
bash libs/create-uber-jar.sh "artifacts" "" "$GROUP_ID" "$ARTIFACT_ID" "$VERSION" "$INCLUDE_GROUP_IDS" "$EXCLUDE_GROUP_IDS" "$DEBUG"
cp "$WORKDIR/$ARTIFACT_ID-$VERSION.jar" ./target

echo "Creating sources uber jar based on the sources folder"
bash libs/create-uber-jar.sh "sources" "-sources" "$GROUP_ID" "$ARTIFACT_ID" "$VERSION-sources" "$INCLUDE_GROUP_IDS" "$EXCLUDE_GROUP_IDS" "$DEBUG"
cp "$WORKDIR/$ARTIFACT_ID-$VERSION-sources.jar" ./target

rm -rf "$WORKDIR"