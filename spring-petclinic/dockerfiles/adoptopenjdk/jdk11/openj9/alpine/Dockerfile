# Stage 1: build a custom runtime image
FROM adoptopenjdk/openjdk11-openj9:alpine as image-runtime-build

COPY jlinko.sh ./
RUN ./jlinko.sh \
		--add-modules java.sql,java.naming,java.management,java.instrument,java.security.jgss,java.desktop,jdk.unsupported \
		--output /app/jre
RUN rm -f ./app/jre/lib/java_*.properties

# Stage 2: create distroless docker image

FROM mbarbero/alpine-jbase:alpine-3.8-glibc2.28-r0

COPY --from=image-runtime-build /app/jre /app/jre
COPY target/modules /opt/app/modules

ENV JAVA_TOOL_OPTIONS="-XX:+IgnoreUnrecognizedVMOptions -XX:+UseContainerSupport -XX:+IdleTuningCompactOnIdle -XX:+IdleTuningGcOnIdle -XX:MaxRAMPercentage=96"
ENTRYPOINT [ "/app/jre/bin/java", "--add-opens", "java.base/java.lang=spring.core,javassist", "--module-path", "/opt/app/modules", "--module", "spring.petclinic"] 