include starter/apps/Makefile
include deliverables/deploy/ecs-ec2/Makefile
include deliverables/deploy/kubernetes/Makefile

# Docker Tasks

# Docker compose tasks are included from starter/apps/Makefile
.PHONY: compose-all compose-build compose-stop compose-start ddb-seed

# Docker build tasks
.PHONY: docker-build docker-build-api docker-build-processor

docker-build-api:
	@docker build --progress plain -t order-api starter/apps/order-api/. 

docker-build-processor:
	@docker build --progress plain -t order-processor starter/apps/order-processor/. 

docker-build: docker-build-api docker-build-processor

# Infrastructure Deployment Tasks (ECS-EC2)

# ECR and ECS cluster targets are included from deliverables/deploy/ecs-ec2/terraform/Makefile
.PHONY: tf-cluster-init tf-cluster-plan tf-cluster-apply tf-cluster-destroy tf-cluster-graph ecr-upload ecr-cleanup

# Kubernetes Tasks
.PHONY: helm-destroy helm-apply helm-restart helm-monitoring-apply helm-monitoring-destroy
