# Stage 1: build a custom runtime image
FROM adoptopenjdk/openjdk11-openj9:latest as image-runtime-build

COPY jlinko.sh target/jmods/*.jmod ./
RUN ./jlinko.sh \
  --module-path /opt/java/openjdk/jmods:. \
	--add-modules tech.barbero.contained.java.example \
	--output /runtime

RUN rm -f ./runtime/lib/java_*.properties

# Stage 2: create distroless docker image

FROM mbarbero/distroless:jbase-libgcc1

COPY --from=image-runtime-build runtime/ /app

ENV JAVA_TOOL_OPTIONS="-XX:+IgnoreUnrecognizedVMOptions -XX:+UseContainerSupport -XX:+IdleTuningCompactOnIdle -XX:+IdleTuningGcOnIdle -XX:MaxRAMPercentage=96"
ENTRYPOINT [ "/app/bin/java", "-m", "tech.barbero.contained.java.example/tech.barbero.contained.java.example.Main" ] 