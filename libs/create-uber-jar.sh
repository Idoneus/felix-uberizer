#!/usr/bin/env bash

trap break INT

set -euo pipefail

WORKDIR="$1"

cd "$WORKDIR"

INPUT_FOLDER="$2"
GROUP_ID="$3"
ARTIFACT_ID="$4"
VERSION="$5"

REPOSITORY="$PWD/.repository"

function minstall() {
  classifier=$(basename "$1" .jar | tr -cd '[[:alnum:]]')
  mvn -q install:install-file -DartifactId=$ARTIFACT_ID -Dclassifier=$classifier -Dfile="$1" -DgroupId=$GROUP_ID -Dversion=$VERSION -Dpackaging=jar -DlocalRepositoryPath=$REPOSITORY
  deps+="<dependency><groupId>$GROUP_ID</groupId><classifier>$classifier</classifier><artifactId>$ARTIFACT_ID</artifactId><version>$VERSION</version><scope>runtime</scope><exclusions><exclusion><artifactId>*</artifactId><groupId>*</groupId></exclusion></exclusions></dependency>"
}

deps=""
for i in $(ls $INPUT_FOLDER); do
  minstall "$INPUT_FOLDER/$i"
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
		$deps
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

mvn install -s settings.xml >/dev/null 2>&1
cp "target/$ARTIFACT_ID-$VERSION.jar" .
