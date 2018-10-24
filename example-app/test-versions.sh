#! /usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'


test() {
	local imagetag="${1}"
	echo "***>>> ${imagetag} <<<***"	
	docker run -m 1GB --rm mbarbero/example-app:${imagetag} World
	docker run -m 1GB --rm  --entrypoint /app/bin/java mbarbero/example-app:${imagetag} -version
	docker run -m 1GB --rm  --entrypoint /app/bin/java mbarbero/example-app:${imagetag} --list-modules -XshowSettings:vm
}

test adoptopenjdk-jdk11-openj9-distroless
test adoptopenjdk-jdk11-hotspot-distroless
test adoptopenjdk-jdk11-openj9-alpine
test adoptopenjdk-jdk11-hotspot-alpine
test openjdk-jdk11-distroless
test openjdk-jdk11-debian-unstable-slim