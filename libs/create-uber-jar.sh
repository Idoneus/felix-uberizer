#!/usr/bin/env bash

trap break INT

set -euo pipefail

WORKDIR=".workdir"
EXTRACTOR_FOLDER="$(cd "$(dirname "$WORKDIR/output")"; pwd -P)/$(basename "$WORKDIR/output")"
INPUT_FOLDER="$EXTRACTOR_FOLDER/$1"
RESULTS_JSON="$EXTRACTOR_FOLDER/../result.json"

cd "$WORKDIR"
SUFFIX="$2"
GROUP_ID="$3"
ARTIFACT_ID="$4"
VERSION="$5"

INCLUDE_GROUP_IDS="$6"
EXCLUDE_GROUP_IDS="$7"

DEBUG="$8"

REPOSITORY="$PWD/.repository"

DEPENDENCIES=""
ARTIFACTS_LIST=()

function debug() { 
	if [ ! -z $DEBUG ]; then
 		echo "### $*";
 	fi
}

function createResultArtifactsList() {
	LIST=( $(cat $RESULTS_JSON | jq -c .bundleExtractionResults[]) )
	for ARTIFACT in ${LIST[@]}; do
		APPEND="true"
		ITEM_GROUP_ID=$(echo "$ARTIFACT" | jq -r .groupId)
		ITEM_ARTIFACT_ID=$(echo "$ARTIFACT" | jq -r .artifactId)
	    ITEM_VERSION=$(echo "$ARTIFACT" | jq -r .version)

		if [[ ! $ITEM_GROUP_ID =~ $INCLUDE_GROUP_IDS ]]; then
			debug "not including $ITEM_GROUP_ID because it does not match include group pattern: $INCLUDE_GROUP_IDS"
			APPEND="false"
		fi
		if [ ! -z $EXCLUDE_GROUP_IDS ]; then
			if [[ $ITEM_GROUP_ID =~ $EXCLUDE_GROUP_IDS ]]; then
				debug "not including $ITEM_GROUP_ID because it matches exclude group pattern: $EXCLUDE_GROUP_IDS"
				APPEND="false"
			fi
		fi

		if [ "$APPEND" = "true" ]; then
			ARTIFACTS_LIST+=("${ITEM_ARTIFACT_ID}-${ITEM_VERSION}${SUFFIX}.jar")
		fi
	done
}

function installToLocalRepo() {
	artifactName=$(basename $1)
	if [[ " ${ARTIFACTS_LIST[*]} " =~ " ${artifactName} " ]]; then
		echo "==> Including artifact in uber-jar: $artifactName"
  		classifier=$(basename "$1" .jar | tr -cd '[[:alnum:]]')
  		mvn -q install:install-file -DartifactId=$ARTIFACT_ID -Dclassifier=$classifier -Dfile="$1" -DgroupId=$GROUP_ID -Dversion=$VERSION -Dpackaging=jar -DlocalRepositoryPath=$REPOSITORY
  		DEPENDENCIES+="<dependency><groupId>$GROUP_ID</groupId><classifier>$classifier</classifier><artifactId>$ARTIFACT_ID</artifactId><version>$VERSION</version><scope>runtime</scope><exclusions><exclusion><artifactId>*</artifactId><groupId>*</groupId></exclusion></exclusions></dependency>"
	fi
}

# Create result artifact list that is allowed in the uber jar
createResultArtifactsList
debug "Result artifact list: ${ARTIFACTS_LIST[*]}"

# Go over the artifacts and add if allowed by the input parameters
for i in $(ls $INPUT_FOLDER); do
  installToLocalRepo "$INPUT_FOLDER/$i"
done

cat >settings.xml <<EOF
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                          https://maven.apache.org/xsd/settings-1.0.0.xsd">
      <localRepository/>
      <interactiveMode/>
      <offline/>
      <pluginGroups/>
      <servers/>
      <mirrors/>
      <proxies/>
      <profiles/>
      <activeProfiles/>
</settings>
EOF

cat >pom.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
	<modelVersion>4.0.0</modelVersion>
	<groupId>$GROUP_ID</groupId>
	<artifactId>$ARTIFACT_ID</artifactId>
	<version>$VERSION</version>
	<packaging>jar</packaging>
	<build>
		<plugins>
			<plugin>
				<groupId>org.apache.maven.plugins</groupId>
				<artifactId>maven-shade-plugin</artifactId>
				<version>3.0.0</version>
				<executions>
					<execution>
						<phase>package</phase>
						<goals>
							<goal>shade</goal>
						</goals>
						<configuration>
							<artifactSet>
								<includes>
									<include>$GROUP_ID:$ARTIFACT_ID:jar:*</include>
								</includes>
							</artifactSet>
						</configuration>
					</execution>
				</executions>
			</plugin>
		</plugins>
	</build>
	<dependencies>
		$DEPENDENCIES
	</dependencies>
	<repositories>
		<repository>
			<id>example-repo</id>
			<name>Example Repository</name>
			<url>file://$REPOSITORY</url>
		</repository>
	</repositories>
</project>
EOF

# Execute shade plugin that combines all the jar files to one
if [ ! -z $DEBUG ]; then
	mvn install -s settings.xml
else 
	mvn install -s settings.xml >/dev/null 2>&1
fi

cp "target/$ARTIFACT_ID-$VERSION.jar" .
