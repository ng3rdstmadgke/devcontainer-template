PROJECT_NAME ?=
STAGE ?=
TERRAFORM_DIR := $(PROJECT_DIR)/terraform
TFPLAN_DIR := $(TERRAFORM_DIR)/.tfplan/$(STAGE)
ENV_DIR := $(TERRAFORM_DIR)/envs/$(STAGE)
TF_BACKEND_CONFIG := $(ENV_DIR)/backend.hcl
TFSTATE_S3_KEY := $(PROJECT_NAME)/$(STAGE)/terraform.tfstate

TFSTATE_BUCKET := $(shell [ -f "$(TF_BACKEND_CONFIG)" ] && cat $(TF_BACKEND_CONFIG) | sed -ne 's|bucket *= *"\([^"]*\)"|\1|p')
TFSTATE_S3_PATH := s3://$(TFSTATE_BUCKET)/$(TFSTATE_S3_KEY)
TFSTATE_DUMP_DIR := $(TERRAFORM_DIR)/.tfstate/$(STAGE)
NOW := $(shell date +"%Y%m%d_%H%M%S")

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

.PHONY: check-tf-addr
check-tf-addr: # tfstateでのリソースアドレスを確認
	@if [ -z "$(TF_ADDR)" ]; then \
		echo "[error] TF_ADDR is required"; \
		exit 1; \
	fi

.PHONY: check-resource-id
check-resource-id: # awsリソースのIDのパラメータを確認
	@if [ -z "$(RESOURCE_ID)" ]; then \
		echo "[error] RESOURCE_ID is required"; \
		exit 1; \
	fi

.PHONY: check-tfstate-lock-id
check-tfstate-lock-id: # tfstateのロックIDを確認
	@if [ -z "$(TF_LOCK_ID)" ]; then \
		echo "[error] TF_LOCK_ID is required"; \
		exit 1; \
	fi


# ==============================================
# terraform基本操作
# ==============================================
.PHONY: tf-validate 
tf-validate: tf-init  ## STAGE=prod (terraform init)
	terraform -chdir=$(TERRAFORM_DIR) validate

.PHONY: tf-fmt
tf-fmt: tf-validate ## STAGE=prod (terraform fmt)
	terraform -chdir=$(TERRAFORM_DIR) fmt

.PHONY: tf-init
tf-init: option-parser ## STAGE=prod (terraform init)
	terraform -chdir=$(TERRAFORM_DIR) init \
	  -upgrade \
	  -reconfigure \
	  -backend-config $(TF_BACKEND_CONFIG) \
	  -backend-config "key=$(TFSTATE_S3_KEY)"

.PHONY: tf-plan
tf-plan: tf-validate ## STAGE=prod (terraform plan)
	mkdir -p $(TFPLAN_DIR)
	terraform -chdir=$(TERRAFORM_DIR) plan \
	  -var "project_name=$(PROJECT_NAME)" \
	  -var "stage=$(STAGE)" \
	  -var-file=$(ENV_DIR)/terraform.tfvars \
	  -out $(TFPLAN_DIR)/.plan
	terraform -chdir=$(TERRAFORM_DIR) show -json $(TFPLAN_DIR)/.plan > $(TFPLAN_DIR)/plan.tfgraph

.PHONY: tf-apply
tf-apply: tf-validate ## STAGE=prod (terraform apply)
	terraform -chdir=$(TERRAFORM_DIR) apply \
	  -var "project_name=$(PROJECT_NAME)" \
	  -var "stage=$(STAGE)" \
	  -var-file=$(ENV_DIR)/terraform.tfvars \
	  --auto-approve

.PHONY: tf-output
tf-output: tf-validate ## STAGE=prod (terraform apply)
	terraform -chdir=$(TERRAFORM_DIR) output

.PHONY: tf-destroy
tf-destroy: tf-validate ## STAGE=prod (terraform destroy)
	terraform -chdir=$(TERRAFORM_DIR) destroy \
	  -var "project_name=$(PROJECT_NAME)" \
	  -var "stage=$(STAGE)" \
	  -var-file=$(ENV_DIR)/terraform.tfvars \
	  --auto-approve

.PHONY: tf-import
tf-import: tf-validate check-tf-addr check-resource-id ## STAGE=prd COMPONENT= TF_ADDR= RESOURCE_ID= (terraform destroy)
	terraform -chdir=$(TERRAFORM_DIR) import \
	  -var "project_name=$(PROJECT_NAME)" \
	  -var "stage=$(STAGE)" \
	  -var-file=$(ENV_DIR)/terraform.tfvars \
		'$(TF_ADDR)' \
		'$(RESOURCE_ID)'

# ==============================================
# tfstate操作
# ==============================================
.PHONY: tf-state-list
tf-state-list: tf-init ## STAGE=prod (terraform state list)
	terraform -chdir=$(TERRAFORM_DIR) state list

.PHONY: tf-state-show
tf-state-show: tf-init check-tf-addr ## STAGE=prod TF_ADDR= (terraform state show)
	terraform -chdir=$(TERRAFORM_DIR) state show '$(TF_ADDR)'

.PHONY: tf-state-rm
tf-state-rm: tf-init check-tf-addr ## STAGE=prod TF_ADDR= (terraform state rm)
	terraform -chdir=$(TERRAFORM_DIR) state rm '$(TF_ADDR)'

.PHONY: tf-force-unlock
tf-force-unlock: check-tfstate-lock-id  ## STAGE=prod  TF_LOCK_ID= (terraform force-unlock)
	terraform -chdir=$(TERRAFORM_DIR) force-unlock $(TF_LOCK_ID)

# ==============================================
# tfstateバックアップ操作
# ==============================================
.PHONY: tfstate-dump
tfstate-dump: ## STAGE=prod (s3からtfstateファイルをダウンロード)
	@mkdir -p $(TFSTATE_DUMP_DIR)
	aws s3 cp $(TFSTATE_S3_PATH) $(TFSTATE_DUMP_DIR)/terraform_$(NOW).tfstate >/dev/null
	@cp $(TFSTATE_DUMP_DIR)/terraform_$(NOW).tfstate $(TFSTATE_DUMP_DIR)/terraform.tfstate
	@echo "[INFO] Current tfstate: $(TFSTATE_DUMP_DIR)/terraform.tfstate"

.PHONY: tfstate-validate
tfstate-validate: tf-init ## STAGE=prod (ダウンロードしたtfstateファイルのバリデーション)
	terraform -chdir=$(TERRAFORM_DIR) show $(TFSTATE_DUMP_DIR)/terraform.tfstate >/dev/null
	@echo "[INFO] Validation OK!"

.PHONY: tfstate-diff
tfstate-diff: ## STAGE=prod (ダウンロードしたtfstateファイルの差分確認)
	@TFSTATE_FILE=$$(ls $(TFSTATE_DUMP_DIR) | grep -v "terraform.tfstate" | sort -r | fzf --height 25% --header "Select a diff target"); \
	git diff --no-index $(TFSTATE_DUMP_DIR)/$${TFSTATE_FILE} $(TFSTATE_DUMP_DIR)/terraform.tfstate && \
	echo "[INFO] No differences found." || true

.PHONY: tfstate-restore
tfstate-restore: tfstate-validate tfstate-diff ## STAGE=prod (ダウンロードしたtfstateファイルをs3にアップロード)
	@read -p "[INFO] Are you sure? (y/n): " yn; [ "$$yn" = "y" -o "$$yn" = "yes" ] || false
	aws s3 cp $(TFSTATE_DUMP_DIR)/terraform.tfstate $(TFSTATE_S3_PATH) >/dev/null

.PHONY: help
.DEFAULT_GOAL := help
help: ## HELP表示
	@grep --no-filename -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'