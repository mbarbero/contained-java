# Stage 1: build a custom runtime image
FROM openjdk:11-jdk as image-runtime-build

COPY jlinko.sh target/jmods/*.jmod ./
RUN ./jlinko.sh \
  --module-path /opt/java/openjdk/jmods:. \
	--add-modules tech.barbero.contained.java.example \
	--output /runtime

RUN rm -f ./runtime/lib/java_*.properties; \
	apt-get update; apt-get install -y --no-install-recommends binutils; \
	strip -p --strip-unneeded /runtime/lib/server/libjvm.so

# Stage 2: create distroless docker image

FROM mbarbero/distroless:jbase-libgcc1-libstdcpp6-unstable

COPY --from=image-runtime-build runtime/ /app

ENV JAVA_TOOL_OPTIONS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=96"
ENTRYPOINT [ "/app/bin/java", "-m", "tech.barbero.contained.java.example/tech.barbero.contained.java.example.Main" ] 