#!/usr/bin/env bash

echo "$1"
echo "$2"
curl -H "Accept: application/zip" http://somerepo.example.org/myjar-1.0.jarhttps://oss.sonatype.org/service/local/repositories/releases/content/be/idoneus/felix/felix-bundle-extractor/1.0.0/felix-bundle-extractor-1.0.0.jar > felix-bundle-extractor.jar

