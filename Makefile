export CHIA_VERSION=1.1.7
export PLATFORMS=linux/amd64,linux/arm64

.PHONY: all
all: plotter harvester farmer full-node

.PHONY: base
base:
	make -C base-image image

.PHONY: plotter
plotter: base
	make -C plotter image

.PHONY: plotter-madmax
plotter-madmax: base
	make -C plotter-madmax image

.PHONY: harvester
harvester: base
	make -C harvester image

.PHONY: farmer
farmer: base
	make -C farmer image

.PHONY: full-node
full-node: base
	make -C full-node image

push:
	make -C base-image push
	make -C plotter push
	make -C harvester push
	make -C farmer push
	make -C full-node push

multiarch:
	make -C base-image multiarch
	make -C plotter multiarch
	make -C plotter-madmax multiarch
	make -C harvester multiarch
	make -C farmer multiarch
	make -C full-node multiarch
