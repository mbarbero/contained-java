# Contained Java
Experiment with distroless docker images + Java 11 custom image runtime

## docker image list

```
REPOSITORY                  TAG                                     SIZE
mbarbero/spring-petclinic   adoptopenjdk-jdk11-openj9-alpine        110MB
mbarbero/spring-petclinic   adoptopenjdk-jdk11-openj9-distroless    110MB
mbarbero/spring-petclinic   adoptopenjdk-jdk11-hotspot-distroless   108MB
mbarbero/spring-petclinic   adoptopenjdk-jdk11-hotspot-alpine       108MB
mbarbero/example-app        jdk-java-net-jdk11-distroless           49.7MB
mbarbero/example-app        openjdk-jdk11-debian-unstable-slim      98.5MB
mbarbero/example-app        openjdk-jdk11-distroless                51.3MB
mbarbero/example-app        adoptopenjdk-jdk11-openj9-alpine        50.9MB
mbarbero/example-app        adoptopenjdk-jdk11-openj9-distroless    51MB
mbarbero/example-app        adoptopenjdk-jdk11-hotspot-alpine       49.3MB
mbarbero/example-app        adoptopenjdk-jdk11-hotspot-distroless   49.3MB
mbarbero/alpine-jbase       alpine-3.8-glibc2.28-r0                 15.8MB
mbarbero/distroless         base                                    15.5MB
mbarbero/distroless         jbase                                   15.8MB
mbarbero/distroless         jbase-libgcc1                           15.9MB
mbarbero/distroless         jbase-libgcc1-libstdcpp6                17.5MB
mbarbero/distroless         base-unstable                           17.4MB
mbarbero/distroless         jbase-unstable                          17.7MB
mbarbero/distroless         jbase-libgcc1-unstable                  17.8MB
mbarbero/distroless         jbase-libgcc1-libstdcpp6-unstable       19.4MB
```

## Java versions
```
$ example-app/test-versions.sh
***>>> adoptopenjdk-jdk11-openj9-distroless <<<***
Hello World
openjdk version "11.0.1" 2018-10-16
OpenJDK Runtime Environment AdoptOpenJDK (build 11.0.1+13)
Eclipse OpenJ9 VM AdoptOpenJDK (build openj9-0.11.0, JRE 11 Linux amd64-64-Bit Compressed References 20181020_70 (JIT enabled, AOT enabled)
OpenJ9   - 090ff9dc
OMR      - ea548a66
JCL      - f62696f378 based on jdk-11.0.1+13)
VM settings:
    Max. Heap Size (Estimated): 983.00M
    Using VM: Eclipse OpenJ9 VM

java.base@11.0.1
tech.barbero.contained.java.example@0.0.1-SNAPSHOT

***>>> adoptopenjdk-jdk11-hotspot-distroless <<<***
Picked up JAVA_TOOL_OPTIONS: -XX:+UseContainerSupport -XX:MaxRAMPercentage=96
Hello World
Picked up JAVA_TOOL_OPTIONS: -XX:+UseContainerSupport -XX:MaxRAMPercentage=96
openjdk version "11" 2018-09-25
OpenJDK Runtime Environment AdoptOpenJDK (build 11+28)
OpenJDK 64-Bit Server VM AdoptOpenJDK (build 11+28, mixed mode)
Picked up JAVA_TOOL_OPTIONS: -XX:+UseContainerSupport -XX:MaxRAMPercentage=96
VM settings:
    Max. Heap Size (Estimated): 951.25M
    Using VM: OpenJDK 64-Bit Server VM

java.base@11
tech.barbero.contained.java.example@0.0.1-SNAPSHOT

***>>> adoptopenjdk-jdk11-openj9-alpine <<<***
Hello World
openjdk version "11.0.1" 2018-10-16
OpenJDK Runtime Environment AdoptOpenJDK (build 11.0.1+13)
Eclipse OpenJ9 VM AdoptOpenJDK (build openj9-0.11.0, JRE 11 Linux amd64-64-Bit Compressed References 20181020_70 (JIT enabled, AOT enabled)
OpenJ9   - 090ff9dc
OMR      - ea548a66
JCL      - f62696f378 based on jdk-11.0.1+13)
VM settings:
    Max. Heap Size (Estimated): 983.00M
    Using VM: Eclipse OpenJ9 VM

java.base@11.0.1
tech.barbero.contained.java.example@0.0.1-SNAPSHOT

***>>> adoptopenjdk-jdk11-hotspot-alpine <<<***
Picked up JAVA_TOOL_OPTIONS: -XX:+UseContainerSupport -XX:MaxRAMPercentage=96
Hello World
Picked up JAVA_TOOL_OPTIONS: -XX:+UseContainerSupport -XX:MaxRAMPercentage=96
openjdk version "11" 2018-09-25
OpenJDK Runtime Environment AdoptOpenJDK (build 11+28)
OpenJDK 64-Bit Server VM AdoptOpenJDK (build 11+28, mixed mode)
Picked up JAVA_TOOL_OPTIONS: -XX:+UseContainerSupport -XX:MaxRAMPercentage=96
VM settings:
    Max. Heap Size (Estimated): 951.25M
    Using VM: OpenJDK 64-Bit Server VM

java.base@11
tech.barbero.contained.java.example@0.0.1-SNAPSHOT

***>>> openjdk-jdk11-distroless <<<***
Picked up JAVA_TOOL_OPTIONS: -XX:+UseContainerSupport -XX:MaxRAMPercentage=96
Hello World
Picked up JAVA_TOOL_OPTIONS: -XX:+UseContainerSupport -XX:MaxRAMPercentage=96
openjdk version "11.0.1" 2018-10-16
OpenJDK Runtime Environment (build 11.0.1+13-Debian-2)
OpenJDK 64-Bit Server VM (build 11.0.1+13-Debian-2, mixed mode)
Picked up JAVA_TOOL_OPTIONS: -XX:+UseContainerSupport -XX:MaxRAMPercentage=96
VM settings:
    Max. Heap Size (Estimated): 951.25M
    Using VM: OpenJDK 64-Bit Server VM

java.base@11.0.1
tech.barbero.contained.java.example@0.0.1-SNAPSHOT

***>>> openjdk-jdk11-debian-unstable-slim <<<***
Picked up JAVA_TOOL_OPTIONS: -XX:+UseContainerSupport -XX:MaxRAMPercentage=96
Hello World
Picked up JAVA_TOOL_OPTIONS: -XX:+UseContainerSupport -XX:MaxRAMPercentage=96
openjdk version "11.0.1" 2018-10-16
OpenJDK Runtime Environment (build 11.0.1+13-Debian-2)
OpenJDK 64-Bit Server VM (build 11.0.1+13-Debian-2, mixed mode)
Picked up JAVA_TOOL_OPTIONS: -XX:+UseContainerSupport -XX:MaxRAMPercentage=96
VM settings:
    Max. Heap Size (Estimated): 951.25M
    Using VM: OpenJDK 64-Bit Server VM

java.base@11.0.1
tech.barbero.contained.java.example@0.0.1-SNAPSHOT
```

## TODO

 * Do benchmarks
 * Experiments with OpenJ9 specific features
 * Test larger apps

## Note
 * PetClinc code modifications come from https://github.com/panga/spring-petclinic/tree/jdk11
