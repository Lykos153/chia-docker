export CHIA_VERSION=1.1.5

.PHONY: base
base:
	make -C base-image image

.PHONY: plotter
plotter: base
	make -C plotter image

push:
	make -C base-image push
	make -C plotter push
