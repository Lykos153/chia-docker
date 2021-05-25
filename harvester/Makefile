IMAGE_NAME="lykos153/chia-harvester"

.PHONY: image
image:
	docker build --build-arg CHIA_VERSION=${CHIA_VERSION} -t ${IMAGE_NAME} .

.PHONY: push
push: image
	docker push ${IMAGE_NAME}

.PHONY: multiarch
multiarch:
	docker buildx build --platform ${PLATFORMS} --tag ${IMAGE_NAME} --build-arg CHIA_VERSION=${CHIA_VERSION} --push .
