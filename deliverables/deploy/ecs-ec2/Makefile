THIS_MAKEFILE := $(lastword $(MAKEFILE_LIST))
ECS_DIR      := $(dir $(realpath $(THIS_MAKEFILE)))

.PHONY: tf-cluster-init
tf-cluster-init:
	@cd $(ECS_DIR)/terraform && terraform init 

.PHONY: tf-cluster-destroy
tf-cluster-destroy:
	@cd $(ECS_DIR)/terraform && terraform destroy

.PHONY: tf-cluster-apply
tf-cluster-apply: tf-cluster-plan
	@cd $(ECS_DIR)/terraform && terraform apply tfplan.json

.PHONY: tf-cluster-plan
tf-cluster-plan:
	@cd $(ECS_DIR)/terraform && terraform plan -var-file=default.tfvars -out tfplan.json

.PHONY: tf-cluster-graph
tf-cluster-graph:
	@cd $(ECS_DIR)/terraform && terraform graph -type=plan

.PHONY: ecr-upload
ecr-upload:
	@cd $(ECS_DIR)/scripts && ./upload.sh

.PHONY: ecr-cleanup
ecr-cleanup:
	@cd $(ECS_DIR)/scripts && ./cleanup.sh

	