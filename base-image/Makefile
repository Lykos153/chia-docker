IMAGE_NAME="lykos153/chia-base"

.PHONY: image
image:
	docker build --build-arg CHIA_VERSION=${CHIA_VERSION} -t ${IMAGE_NAME}:${CHIA_VERSION} .

.PHONY: push
push: image
	docker push ${IMAGE_NAME}:${CHIA_VERSION}
