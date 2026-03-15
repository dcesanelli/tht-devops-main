# Terraform and ECS-EC2 cluster

## How to deploy

- Ensure AWS credentials (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` or `AWS_PROFILE` and `AWS_REGION`) are set in your environment.

# We will create the ECS cluster (including ECR repositories) and build/upload images

- Create the AWS infrastructure required for the ECS cluster
  ```bash
  make tf-cluster-init
  make tf-cluster-apply
  ```
- Build and upload Docker images to ECR
  ```bash
  make ecr-upload
  ```

## How to Test

- Get the ALB DNS name from the output of `make tf-cluster-apply`.
- Run `SERVER_ENDPOINT=http://<ALB_DNS_NAME> ./starter/apps/scripts/test_docker_compose.sh`

## How to destroy

- Run `make tf-cluster-destroy`.

# Kubernetes and Helm

## How to deploy to MiniKube

- Start Minikube and build images:
  ```bash
  minikube start
  eval "$(minikube docker-env)"
  make docker-build
  ```
- Install the Helm chart:
  ```bash
  make helm-apply
  make helm-monitoring-apply
  ```
- The `dynamodb-init` Job runs once after deploy, creating `orders` and `inventory` tables and seeding inventory. Verify with:
  ```bash
  kubectl get jobs -n microservices
  kubectl logs job/dynamodb-init -n microservices
  ```

## How to Test

- Port-forward and call the API:
  ```bash
  kubectl port-forward -n microservices svc/order-api 8000:8000
  SERVER_ENDPOINT=http://localhost:8000 ./starter/apps/scripts/test_docker_compose.sh
  ```

### Accessing Grafana

- Get Grafana admin password

  ```bash
  kubectl get secret --namespace monitoring monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
  ```

- Port forward Grafana
  ```bash
  kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80
  ```
- Access at http://localhost:3000

### Accessing Prometheus

- Port forward Prometheus
  ```bash
  kubectl port-forward -n monitoring svc/monitoring-prometheus-server 9090:80
  ```
- Access at http://localhost:9090

### Accessing Alertmanager

- Port forward Alertmanager
  ```bash
  kubectl port-forward -n monitoring svc/monitoring-alertmanager 9093:9093
  ```
- Access at http://localhost:9093

## Clean up Minikube

- Clean up the Helm chart:
  ```bash
  make helm-destroy
  make helm-monitoring-destroy
  ```
- Stop Minikube:
  ```bash
  minikube stop
  ```
