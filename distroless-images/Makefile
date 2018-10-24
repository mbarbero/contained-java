TARGET_FOLDER=target
DOCKER_ORG=mbarbero
DISTROLESS_REPO=$(DOCKER_ORG)/distroless
TARGET_DISTROLESS=$(TARGET_FOLDER)/$(DISTROLESS_REPO)

.PHONY: all
all: alpine-glibc-docker distroless

.PHONY: clean
clean: 
	rm -rf $(TARGET_FOLDER)

ALPINE_VERSION=3.8
ALPINE_GLIBC_VERSION=2.28-r0
.PHONY: alpine-glibc-docker
alpine-glibc-docker: alpine-glibc/Dockerfile
	docker build \
		--build-arg "GLIBC_VER=$(ALPINE_GLIBC_VERSION)" \
		--build-arg "ALPINE_VERSION=$(ALPINE_VERSION)" \
		-t $(DOCKER_ORG)/alpine-jbase:alpine-$(ALPINE_VERSION)-glibc$(ALPINE_GLIBC_VERSION) \
		-f alpine-glibc/Dockerfile \
		alpine-glibc

.PHONY: distroless
distroless: base base-unstable jbase jbase-unstable jbase-libgcc1 jbase-libgcc1-unstable jbase-libgcc1-libstdcpp6 jbase-libgcc1-libstdcpp6-unstable

.PHONY: base
base: $(TARGET_DISTROLESS)/base/image.tar

$(TARGET_DISTROLESS)/base/image.tar: 
	./distroless.sh create_base $(DISTROLESS_REPO) base $@
	docker load -i $@

.PHONY: base-unstable
base-unstable: $(TARGET_DISTROLESS)/base-unstable/image.tar

$(TARGET_DISTROLESS)/base-unstable/image.tar: 
	./distroless.sh create_base_unstable $(DISTROLESS_REPO) base-unstable $@
	docker load -i $@

.PHONY: jbase
jbase: $(TARGET_DISTROLESS)/jbase/image.tar

$(TARGET_DISTROLESS)/jbase/image.tar: $(TARGET_DISTROLESS)/base/image.tar
	./distroless.sh add_jbase $(DISTROLESS_REPO) jbase $@ $<
	docker load -i $@

.PHONY: jbase-unstable
jbase-unstable: $(TARGET_DISTROLESS)/jbase-unstable/image.tar

$(TARGET_DISTROLESS)/jbase-unstable/image.tar: $(TARGET_DISTROLESS)/base-unstable/image.tar
	./distroless.sh add_jbase_unstable $(DISTROLESS_REPO) jbase-unstable $@ $<
	docker load -i $@

.PHONY: jbase-libgcc1
jbase-libgcc1: $(TARGET_DISTROLESS)/jbase-libgcc1/image.tar

$(TARGET_DISTROLESS)/jbase-libgcc1/image.tar: $(TARGET_DISTROLESS)/jbase/image.tar
	./distroless.sh add_libgcc1 $(DISTROLESS_REPO) jbase-libgcc1 $@ $<
	docker load -i $@

.PHONY: jbase-libgcc1-unstable
jbase-libgcc1-unstable: $(TARGET_DISTROLESS)/jbase-libgcc1-unstable/image.tar

$(TARGET_DISTROLESS)/jbase-libgcc1-unstable/image.tar: $(TARGET_DISTROLESS)/jbase-unstable/image.tar
	./distroless.sh add_libgcc1_unstable $(DISTROLESS_REPO) jbase-libgcc1-unstable $@ $<
	docker load -i $@

.PHONY: jbase-libgcc1-libstdcpp6
jbase-libgcc1-libstdcpp6: $(TARGET_DISTROLESS)/jbase-libgcc1-libstdcpp6/image.tar

$(TARGET_DISTROLESS)/jbase-libgcc1-libstdcpp6/image.tar: $(TARGET_DISTROLESS)/jbase-libgcc1/image.tar
	./distroless.sh add_libstdcpp6 $(DISTROLESS_REPO) jbase-libgcc1-libstdcpp6 $@ $<
	docker load -i $@

.PHONY: jbase-libgcc1-libstdcpp6-unstable
jbase-libgcc1-libstdcpp6-unstable: $(TARGET_DISTROLESS)/jbase-libgcc1-libstdcpp6-unstable/image.tar

$(TARGET_DISTROLESS)/jbase-libgcc1-libstdcpp6-unstable/image.tar: $(TARGET_DISTROLESS)/jbase-libgcc1-unstable/image.tar
	./distroless.sh add_libstdcpp6_unstable $(DISTROLESS_REPO) jbase-libgcc1-libstdcpp6-unstable $@ $<
	docker load -i $@