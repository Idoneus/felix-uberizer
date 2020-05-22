#!/usr/bin/env bash

set -euo pipefail

trap break INT

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -s|--input-folder) INPUT_FOLDER="$2"; shift ;;
        -g|--group-id) GROUP_ID="$2"; shift ;;
        -a|--artifact-id) ARTIFACT_ID="$2"; shift ;;
        -v|--version) VERSION="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

WORKDIR=".workdir"
OUTPUT_FOLDER="${WORKDIR}/output"

mkdir -p "$WORKDIR"

echo "Creating artifacts and sources based on the input folder"
bash libs/create-artifacts-and-sources.sh "$WORKDIR" "$INPUT_FOLDER" "$OUTPUT_FOLDER"

echo "Creating uber jar based on the artifacts folder"
bash libs/create-uber-jar.sh  "$WORKDIR" "${OUTPUT_FOLDER}/artifacts" "$GROUP_ID" "$ARTIFACT_ID" "$VERSION"
cp "$WORKDIR/$ARTIFACT_ID-$VERSION.jar" .

echo "Creating sources uber jar based on the sources folder"
bash libs/create-uber-jar.sh  "$WORKDIR" "${OUTPUT_FOLDER}/sources" "$GROUP_ID" "$ARTIFACT_ID" "$VERSION-sources"
cp "$WORKDIR/$ARTIFACT_ID-$VERSION-sources.jar" .

rm -rf "$WORKDIR"