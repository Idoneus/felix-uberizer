#!/usr/bin/env bash

trap break INT

set -euo pipefail

groupId=com.amplexor.aem
artifactId=amplexor-uber-jar
version=6.5.4
repository="$PWD/.repository"

function minstall() {
  classifier=$(basename "$1" .jar | tr -cd '[[:alnum:]]')
  mvn -q install:install-file -DartifactId=$artifactId -Dclassifier=$classifier -Dfile="$1" -DgroupId=$groupId -Dversion=$version -Dpackaging=jar -DlocalRepositoryPath=$repository
  echo "installed $classifier to local repo"
  deps+="<dependency><groupId>$groupId</groupId><classifier>$classifier</classifier><artifactId>$artifactId</artifactId><version>$version</version><scope>runtime</scope><exclusions><exclusion><artifactId>*</artifactId><groupId>*</groupId></exclusion></exclusions></dependency>"
}

function cleanUp() {
  if [ -d "$repository" ]; then
    rm -rf "$repository"
  fi
  rm -rf target
  rm pom.xml
  rm dependency-reduced-pom.xml
  rm settings.xml
}

deps=""
for i in $(ls $1); do
  minstall "$1/$i"
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
	<groupId>$groupId</groupId>
	<artifactId>$artifactId</artifactId>
	<version>$version</version>
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
									<include>$groupId:$artifactId:jar:*</include>
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
			<url>file://$repository</url>
		</repository>
	</repositories>
</project>
EOF

mvn install -s settings.xml
cp "target/$artifactId-$version.jar" .

cleanUp
