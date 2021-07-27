IMAGE_TAG_BASE ?= practicode-client
VERSION ?= latest

IMG ?= $(IMAGE_TAG_BASE):$(VERSION)

docker-build:## Build docker image with client dist
	docker build --tag ${IMG} --file nginx/Dockerfile .

docker-push: ## Push docker image with the manager.
	docker push ${IMG}
