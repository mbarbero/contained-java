# Stage 1: build a custom runtime image
FROM debian:stretch-slim as image-runtime-build


RUN mkdir -p /opt/local 
COPY dockerfiles/jdk.java.net/jdk11/distroless/openjdk-11.0.1_linux-x64_bin.tar.gz /opt/local
RUN tar -C /opt/local -zxvf /opt/local/openjdk-11.0.1_linux-x64_bin.tar.gz
ENV JAVA_HOME=/opt/local/jdk-11.0.1
ENV PATH=${PATH}:${JAVA_HOME}/bin

COPY jlinko.sh target/jmods/*.jmod ./
RUN ./jlinko.sh \
  --module-path /opt/local/jdk-11.0.1/jmods:. \
	--add-modules tech.barbero.contained.java.example \
	--output /runtime

RUN rm -f ./runtime/lib/java_*.properties

# Stage 2: create distroless docker image

FROM mbarbero/distroless:jbase

COPY --from=image-runtime-build runtime/ /app

ENV JAVA_TOOL_OPTIONS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=96"
ENTRYPOINT [ "/app/bin/java", "-m", "tech.barbero.contained.java.example/tech.barbero.contained.java.example.Main" ] 