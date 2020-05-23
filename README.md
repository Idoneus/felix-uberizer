# felix-uberizer
Felix Uber-JAR Creator

## Minimum requirements

* Docker

OR

* Java 11
* Maven 3.x
* jq (brew install jq)

## Usage

Execute docker / bash with the following arguments:

### Mandatory 
* -i/--input-folder: Location of the felix directory (ex. crx-quickstart/launchpad/felix)
* -g/--group-id: Group ID of the uber jar
* -a/--artifact-id: Artifact ID of the uber-jar
* -v/--version: Version of the uber-jar

### Optional:
* -ig/--include-group-ids: Regex to only include a subset of group ids (ex. ```(com.adobe.*|org.apache.sling.*|org.apache.felix.*)```)
* -eg/--exclude-group-ids: Regex to exclude from the previously included group ids (ex. ```(com.adobe.forms.*)```)
* -d/--debug: Show debug logging

### Example startup command

#### Docker

```
docker build --pull --rm -f "Dockerfile" -t felixuberizer:latest "."

docker run --rm -it --mount type=bind,source=/my/aem/crx-quickstart/launchpad/felix,target=/tmp/felix-uberizer/input --mount type=bind,source="$(pwd)"/target,target=/tmp/felix-uberizer/target felixuberizer:latest -g be.idoneus.aem -a idoneus-uber-jar -v 1.0.0 -ig "(org.apache.sling.*|org.apache.felix.*|org.apache.jackrabbit.*|org.apache.oak.*|com.adobe.*|com.day.*)"
```

#### Bash

```
bash felix-uberizer.sh --input-folder /my/aem/crx-quickstart/launchpad/felix -g be.idoneus.aem -a idoneus-uber-jar -v 1.0.0 -ig "(org.apache.sling.*|org.apache.felix.*|org.apache.jackrabbit.*|org.apache.oak.*|com.adobe.*|com.day.*)"
```