#! /usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'

docker run -it --rm \
	-v $(pwd)/example-app:/build \
	-v ~/.m2/repository:/maven_repo \
	-w /build \
	maven:3.5.4-jdk-11-slim \
	mvn -Dmaven.repo.local=/maven_repo clean verify

docker build -t mbarbero/example-app:adoptopenjdk-jdk11-hotspot-distroless		-f dockerfiles/adoptopenjdk/jdk11/hotspot/distroless/Dockerfile .
docker build -t mbarbero/example-app:adoptopenjdk-jdk11-hotspot-alpine		-f dockerfiles/adoptopenjdk/jdk11/hotspot/alpine/Dockerfile .

docker build -t mbarbero/example-app:adoptopenjdk-jdk11-openj9-distroless 		-f dockerfiles/adoptopenjdk/jdk11/openj9/distroless/Dockerfile .
docker build -t mbarbero/example-app:adoptopenjdk-jdk11-openj9-alpine 		-f dockerfiles/adoptopenjdk/jdk11/openj9/alpine/Dockerfile .

docker build -t mbarbero/example-app:openjdk-jdk11-distroless 						-f dockerfiles/openjdk/jdk11/distroless/Dockerfile .
docker build -t mbarbero/example-app:openjdk-jdk11-debian-unstable-slim 	-f dockerfiles/openjdk/jdk11/debian-unstable-slim/Dockerfile .

docker build -t mbarbero/example-app:jdk-java-net-jdk11-distroless				-f dockerfiles/jdk.java.net/jdk11/distroless/Dockerfile .

docker image prune -f

