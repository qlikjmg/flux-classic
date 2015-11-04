PROJ:=ambergreen
BASEPKG:=github.com/squaremo/$(PROJ)

DEPS:=$(shell find pkg -name '*.go')

.PHONY: images
images: docker/.balancer.done docker/.agent.done \
	docker/.display.done docker/.command.done

.PHONY: clean
clean:
	rm -f docker/.*.done *.bin
	rm -rf ./build

.PHONY: test
test:

# Don't remove this if a subsequent step fails
.PRECIOUS: docker/.build.done

.%.done: Dockerfile.%
	rm -rf build-container
	mkdir build-container
	cp -pr $^ build-container/
	docker build -t $(PROJ)/$(*F) -f build-container/$(<F) build-container
	rm -rf build-container
	touch $@

docker/.agent.done: agent.bin
docker/.balancer.done: balancer.bin
docker/.command.done: command.bin
docker/.display.done: display.bin

# $1: build image
# $2: extra docker run args
# $3: directory to mount as /build
# $4: working directory under /build
# $5: command string to pass to build-wrapper.sh
run_build_container=docker run --rm $2 -v $$PWD$(and $3,/$3):/build \
    -v $$PWD/docker/build-wrapper.sh:/build-wrapper.sh \
    --workdir=/build$(and $4,/$4) $(PROJ)/$(or $1,build) sh /build-wrapper.sh "$5"

%.bin: docker/.build.done docker/build-wrapper.sh $(DEPS)
	rm -rf build/src/$(BASEPKG)
	mkdir -p build/src/$(BASEPKG)
	cp -pr pkg $(*F) build/src/$(BASEPKG)/
	$(call run_build_container,,-e GOPATH=/build,build,src/$(BASEPKG)/$(*F),go get ./... && go build ./...)
	cp build/bin/$(*F) $@

# Subdir-specific rules

include ./*/local.mk