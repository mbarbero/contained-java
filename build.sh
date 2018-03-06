#! /usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'

docker run -it --rm \
	-v $(pwd):/build \
	-v ~/.m2/repository:/maven_repo \
	-w /build \
	maven:3.5.2-jdk-9-slim \
	mvn -Dmaven.repo.local=/maven_repo clean verify

docker build -t mbarbero/example-app:openjdk9-openj9 -f Dockerfile.openjdk9-openj9 .
docker build -t mbarbero/example-app:openjdk9-openj9-alpine -f Dockerfile.openjdk9-openj9-alpine .
docker build -t mbarbero/example-app:openjdk9-hotspot -f Dockerfile.openjdk9-hotspot .
docker build -t mbarbero/example-app:openjdk9-hotspot-alpine -f Dockerfile.openjdk9-hotspot-alpine .

docker build -t mbarbero/example-app:official-openjdk9-hotspot -f Dockerfile.official-openjdk9-hotspot .