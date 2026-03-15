# Explain decisions made during the implmentation of the test

## Fixed issues in the starter code to make it work:

- Fixed port in order-processor to 8000 to match Dockerfile
- Fixed docker-compose.yaml healthchecks to use port 8001 for order-api and 8002 for order-processor
- Fixed order-api to use int to cast order.quantity
- Fixed some issues in the MINIKUBE.md file to make it work:
  - `--create-namespace` was missing in some helm commands
  - the port-forward command was missing the namespace.
  - storageClass "gp2" is not available in minikube, so I changed it to "standard" in the prometheus helm chart.

## Fixed issues in the terraform code to make it work:

- ecs-ec2/terraform/\_outputs.tf: removed index in alb_dns_name because ecs is a fixed module
- ecs-ec2/terraform/Makefile: added var-file to terraform plan and apply commands
- ecs-ec2/terraform/modules/vpc/main.tf: added data sources for availability zones
- ecs-ec2/terraform/modules/dynamodb/main.tf: added code to create a DynamoDB Tables for Orders and Inventory
- ecs-ec2/terraform/main.tf: removed order_api_repo_arn and processor_repo_arn variables and added code to get the ECR repository ARNs from ECR terraform state
- ecs-ec2/terraform/default.tfvars: removed order_api_image and processor_image variables and added code to get the ECR repository urls from ECR terraform state

## Implementation decisions

### Terraform

- Moved ECR module into ecs-ec2 terraform (deliverables/deploy/ecs-ec2/terraform/modules/ecr) so ECR and ECS cluster are deployed together; removed separate ecr/terraform and ecr/scripts; upload and cleanup scripts now live under ecs-ec2/scripts.
- Makefile: Included starter apps and ecs-ec2 Makefiles so we can run all the commands from the root directory, changed some var names so they not overlap.
- There are some services that are not included in the AWS Free Tier but left them as they are because they are good practices and the cost won't be an issue for the test, since it will still be included in the AWS Free Tier for the first 12 months:
  - **NAT Gateways** ($0.045/hour each) and associated EIPs.
  - **Interface VPC Endpoints** ($0.01/hour each) for ECR, Logs, SSM, etc.
  - **Gateway Endpoints** only S3 and DynamoDB as they are free.
- I use ECS service discovery with Cloud Map to allow microservices to discover each other dynamically via DNS. Since ECS tasks are ephemeral and their IPs change frequently, service discovery automatically registers tasks and provides a stable service name like order-processor.internal.local. This removes the need for hard-coded endpoints and allows services to scale and restart without breaking internal communication.
- I added sample data to the DynamoDB table to make it easier to test the application, with lifecycle ignore_changes, to prevent terraform from trying to update the sample data every time we run terraform apply, but in a production environment, I would use a seeding docker image to populate the table with sample data, that we could run once when the application is deployed as it happens in the minikube deployment.

### Kubernetes

- Instrumented `order-api` and `order-processor` with `prometheus_fastapi_instrumentator` to expose `/metrics` endpoint.
- Created a `monitoring` wrapper Helm chart using `kube-prometheus-stack`.
- Defined a `ServiceMonitor` to automatically discover and scrape metrics from the microservices, and added 2 other standard ones for k8s and nodes metrics
- Implemented SLO violation alerts for availability (99.9%), latency (<500ms), and error rate (<1%)
- Created a dashboard with real-time SLO status, resource utilization, and trend analysis.

# What could be improved

## Application-Level Improvements

- There are some decisions made in the python code, like using int for price instead of using Decimal, that I would change, but I left them as they were defined because the test prices are integers.
- The order-api doesn't manage errors properly, it just returns a 500 error, I would add code to handle errors properly and return more specific error messages.

# What I would do if this was in a production environment and I had more time

## Github repository

- Restrict access to the repository to authorized personnel.
- Implement branch protection rules to prevent direct pushes to the main branch.
- Implement code review process for all pull requests.
- Implement blocking of pull requests that don't pass the linting and security scanning checks.

## Terraform

- Store state in an S3 bucket with DynamoDB/Object locking to enable collaboration and prevent state corruption.
- Add public Route53 DNS records for the ALB.
- Provision a managed SSL certificate from a public Certificate Authority (CA) via ACM and implement a permanent (301) HTTP-to-HTTPS redirect at the ALB listener level to enforce HTTPS.
- Utilize AWS Secrets Manager for sensitive data (i.e. Grafana admin password).
- Implement centralized logging (CloudWatch or Datadog).
- Implement container image scanning in ECR.
- Deploy across multiple Availability Zones (Multi-AZ).
- Add NACL rules to the VPC to restrict access to the resourcess (in the actual solution, security groups are used to restrict access to the resources, which is enough for this test)

## Testing

- Add linting tasks to the code. I would use pre-commit to run the linting tasks automatically.
- Add security scanning tasks to the code. I would use trivy, tfsec, checkov to scan for vulnerabilities.
- Add tests for the application, terraform and helm code, including unit tests and integration tests.
- Add a CI/CD pipeline using GitHub Actions to automate the linting, security scanning, build, test, and deployment process.

## Kubernetes

- If we just have these two microservices, I would continue using ECS cluster, but if we have more microservices, I would consider using EKS cluster to take advantage of the Kubernetes ecosystem.

## Monitoring Enhancements

- Adjust alert thresholds based on actual traffic patterns and business requirements
- Add more service-specific panels and business metric visualizations
- Configure longer-term metrics storage for trend analysis and capacity planning
- Set up different alert channels (Slack, PagerDuty, email) based on severity and team ownership
