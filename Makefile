PROJECT_NAME ?=
STAGE ?=
HOST_USER ?=
DOCKER_NETWORK ?=
SAMPLE_APP_CONTAINER := ${PROJECT_NAME}/sample-app/$(HOST_USER)


# ==============================================
# オプションパーサー
# ==============================================
.PHONY: option-parser
option-parser:
	@if [ -z "$(PROJECT_NAME)" ]; then \
	  echo "[Err] PROJECT_NAME is required"; \
	  exit 1; \
	fi
	@if [ -z "$(STAGE)" ]; then \
	  echo "[Err] STAGE is required"; \
	  exit 1; \
	fi


# ==============================================
# Docker操作
# ==============================================
.PHONY: build
build: ## (build docker images)
	docker build --rm \
	  -f $(PROJECT_DIR)/docker/sample-app/Dockerfile \
	  -t $(SAMPLE_APP_CONTAINER):latest \
	  .

.PHONY: run
run: build ## (run docker container)
	docker run --rm -ti \
	  --name sample-app-$(HOST_USER) \
	  --network $(DOCKER_NETWORK) \
	  $(SAMPLE_APP_CONTAINER):latest

.PHONY: push
push: option-parser build ## STAGE=prod (push docker images to ECR)
	(cd $(PROJECT_DIR)/terraform && make tf-init STAGE=$(STAGE)) && \
	REGISTRY_ID=$$(terraform -chdir=$(PROJECT_DIR)/terraform output -raw sample_app_ecr_registry_id) && \
	REPOSITORY_URL=$$(terraform -chdir=$(PROJECT_DIR)/terraform output -raw sample_app_ecr_repository_url) && \
	aws ecr get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin $$REGISTRY_ID.dkr.ecr.$(AWS_REGION).amazonaws.com && \
	echo docker tag $(SAMPLE_APP_CONTAINER):latest $$REPOSITORY_URL:latest && \
	docker tag $(SAMPLE_APP_CONTAINER):latest $$REPOSITORY_URL:latest && \
	echo docker push $$REPOSITORY_URL:latest && \
	docker push $$REPOSITORY_URL:latest

.PHONY: help
.DEFAULT_GOAL := help
help: ## HELP表示
	@grep --no-filename -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'