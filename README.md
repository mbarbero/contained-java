# Contained Java
Experiment with distroless docker images + Java 9 custom image runtime

## docker image list

```
REPOSITORY                             TAG                         SIZE
mbarbero/example-app                   official-openjdk9-hotspot   48.3MB
mbarbero/example-app                   openjdk9-hotspot            47.1MB
mbarbero/example-app                   openjdk9-openj9             49.1MB
mbarbero/example-app                   openjdk9-hotspot-alpine     45.6MB
mbarbero/example-app                   openjdk9-openj9-alpine      47.6MB
mbarbero/distroless-base               latest                      16.5MB
mbarbero/distroless-java               latest                      16.9MB
mbarbero/distroless-openj9             latest                      17MB
mbarbero/distroless-openjdk-official   latest                      18.6MB
```

## Example app
```
$ docker run -it --rm mbarbero/example-app:openjdk9-hotspot World!
Hello World!
$ docker run -it --rm mbarbero/example-app:openjdk9-hotspot-alpine World!
Hello World!
$ docker run -it --rm mbarbero/example-app:openjdk9-openj9 World!
Hello World!
$ docker run -it --rm mbarbero/example-app:openjdk9-openj9-alpine World!
Hello World!
$ docker run -it --rm mbarbero/example-app:official-openjdk9-hotspot World!
Hello World!
```

## Java versions
```
$ docker run -it --rm --entrypoint /app/bin/java mbarbero/example-app:openjdk9-hotspot -version
openjdk version "9-internal"
OpenJDK Runtime Environment (build 9-internal+0-adhoc.jenkins.openjdk)
OpenJDK 64-Bit Server VM (build 9-internal+0-adhoc.jenkins.openjdk, mixed mode)

$ docker run -it --rm --entrypoint /app/bin/java mbarbero/example-app:openjdk9-hotspot-alpine -version
openjdk version "9-internal"
OpenJDK Runtime Environment (build 9-internal+0-adhoc.jenkins.openjdk)
OpenJDK 64-Bit Server VM (build 9-internal+0-adhoc.jenkins.openjdk, mixed mode)

$ docker run -it --rm --entrypoint /app/bin/java mbarbero/example-app:openjdk9-openj9 -version
openjdk version "9-internal"
OpenJDK Runtime Environment (build 9-internal+0-adhoc.jenkins.openjdk)
Eclipse OpenJ9 VM (build 2.9, JRE 9 Linux amd64-64 Compressed References 20171027_36 (JIT enabled, AOT enabled)
OpenJ9   - 292f272
OMR      - 9ea665d
OpenJDK  - 640ef65 based on )

$ docker run -it --rm --entrypoint /app/bin/java mbarbero/example-app:openjdk9-openj9-alpine -version
openjdk version "9-internal"
OpenJDK Runtime Environment (build 9-internal+0-adhoc.jenkins.openjdk)
Eclipse OpenJ9 VM (build 2.9, JRE 9 Linux amd64-64 Compressed References 20171027_36 (JIT enabled, AOT enabled)
OpenJ9   - 292f272
OMR      - 9ea665d
OpenJDK  - 640ef65 based on )

$ docker run -it --rm --entrypoint /app/bin/java mbarbero/example-app:official-openjdk9-hotspot -version
openjdk version "9.0.1"
OpenJDK Runtime Environment (build 9.0.1+11-Debian-1)
OpenJDK 64-Bit Server VM (build 9.0.1+11-Debian-1, mixed mode)
```

## TODO

 * Do benchmarks
 * Experiments with OpenJ9 specific features
 * Test larger apps
