resource "aws_ecs_cluster" "main" {
  name = "${var.environment}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "order_api" {
  family                   = "${var.environment}-order-api"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = var.ecs_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "order-api"
      image     = var.order_api_image
      essential = true
      cpu       = 128
      memory    = 256

      portMappings = [
        {
          containerPort = 8000
        }
      ]

      environment = [
        { name = "SRV_ENDPOINT", value = "order-processor.${var.environment}.internal" },
        { name = "ORDER_PROCESSOR_URL", value = "http://order-processor.${var.environment}.internal:8000" },
        { name = "DYNAMODB_TABLE", value = var.orders_table_name },
        { name = "AWS_DEFAULT_REGION", value = var.aws_region }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.environment}-order-api"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "order-api"
          "awslogs-create-group"  = "true"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "order_api" {
  name            = "${var.environment}-order-api"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.order_api.arn
  desired_count   = 1
  launch_type     = "EC2"

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  load_balancer {
    target_group_arn = aws_lb_target_group.order_api.arn
    container_name   = "order-api"
    container_port   = 8000
  }

  service_registries {
    registry_arn   = aws_service_discovery_service.order_api.arn
    container_name = "order-api"
    container_port = 8000
  }

  depends_on = [aws_lb_listener.http]
}

resource "aws_ecs_task_definition" "order_processor" {
  family                   = "${var.environment}-order-processor"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = var.ecs_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "order-processor"
      image     = var.processor_image
      essential = true
      cpu       = 128
      memory    = 256

      portMappings = [
        {
          containerPort = 8000
        }
      ]

      environment = [
        { name = "DYNAMODB_TABLE", value = var.inventory_table_name },
        { name = "AWS_DEFAULT_REGION", value = var.aws_region }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.environment}-order-processor"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "order-processor"
          "awslogs-create-group"  = "true"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "order_processor" {
  name            = "${var.environment}-order-processor"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.order_processor.arn
  desired_count   = 1
  launch_type     = "EC2"

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  service_registries {
    registry_arn   = aws_service_discovery_service.order_processor.arn
    container_name = "order-processor"
    container_port = 8000
  }
}
