IMAGE_NAME="lykos153/chia-plotter-madmax"
PLATFORMS=linux/amd64,linux/arm64

.PHONY: image
image:
	docker build -t ${IMAGE_NAME} .

.PHONY: push
push: image
	docker push ${IMAGE_NAME}

.PHONY: multiarch
multiarch:
	docker buildx build --platform ${PLATFORMS} --tag ${IMAGE_NAME} --push .
