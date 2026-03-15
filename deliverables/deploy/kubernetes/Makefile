THIS_MAKEFILE := $(lastword $(MAKEFILE_LIST))
K8S_DIR       := $(dir $(realpath $(THIS_MAKEFILE)))

# Kubernetes Tasks
.PHONY: helm-destroy helm-apply helm-restart helm-monitoring-apply helm-monitoring-destroy
helm-destroy:
	helm uninstall devopstht

helm-apply:
	helm upgrade --force-replace --install devopstht $(K8S_DIR)/charts/microservices/   

helm-restart: helm-destroy helm-apply

helm-monitoring-apply:
	helm upgrade --install monitoring $(K8S_DIR)/charts/monitoring/ --create-namespace --namespace monitoring

helm-monitoring-destroy:
	helm uninstall monitoring --namespace monitoring
