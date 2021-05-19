IMAGE_NAME="lykos153/chia-plotter"

.PHONY: image
image:
	docker build --build-arg CHIA_VERSION=${CHIA_VERSION} -t ${IMAGE_NAME} .

.PHONY: push
push: image
	docker push ${IMAGE_NAME}
