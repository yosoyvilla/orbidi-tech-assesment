resource "aws_kms_key" "ecs_aws_kms_key" {
  description             = "${var.name}-ecs-logs-key"
  deletion_window_in_days = 7
}

resource "aws_cloudwatch_log_group" "ecs_aws_cloudwatch_log_group" {
  name = "${var.name}-ecs-logs-group"
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.name}-cluster"

  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.ecs_aws_kms_key.arn
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.ecs_aws_cloudwatch_log_group.name
      }
    }
  }
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_service" "ecs_service" {
  name            = "${var.name}-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.service.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_alb_tg.arn
    container_name   = var.name
    container_port   = var.containerPort
  }

  network_configuration {
    subnets          = var.alb_subnets
    security_groups  = [aws_security_group.ecs_alb_sg.id]
    assign_public_ip = true
  }

  deployment_controller {
    type = "ECS"
  }

  scheduling_strategy = "REPLICA"

  depends_on = [
    aws_lb_listener.http,
    aws_lb_listener.https
  ]
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.name}-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role" "ecs_task_role" {
  name = "${var.name}-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  depends_on = [
    aws_iam_role.ecs_task_execution_role
  ]
}


resource "aws_ecs_task_definition" "service" {
  family                   = "${var.name}-definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = "2048"
  memory                   = "5120"

  container_definitions = jsonencode([
    {
      name        = var.name,
      image       = var.image
      cpu         = 0,
      mountPoints = [],
      portMappings = [
        {
          containerPort = var.containerPort,
          hostPort      = var.hostPort,
          protocol      = "tcp"
        }
      ],
      essential   = true,
      environment = var.environment_variables
      secrets     = var.environment_secrets
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = "/ecs/${var.name}-logs"
          "awslogs-region"        = "us-east-1",
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  depends_on = [
    aws_iam_role.ecs_task_execution_role,
    aws_iam_role_policy_attachment.ecs_task_execution_role_policy_attachment,
    aws_cloudwatch_log_group.ecs_logs
  ]

}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name = "/ecs/${var.name}-logs"

  retention_in_days = 7

  tags = {
    Name = "ECS Logs for ${var.name}-cluster-service"
  }
}

resource "aws_lb" "ecs_alb" {
  name               = "${var.name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_alb_sg.id]
  subnets            = var.alb_subnets

  enable_deletion_protection = false
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_alb_tg.arn
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.listener_certificate

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_alb_tg.arn
  }
}

resource "aws_lb_target_group" "ecs_alb_tg" {
  name        = "${var.name}-alb-sg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    matcher             = "200"
  }

  stickiness {
    enabled         = false
    type            = "lb_cookie"
    cookie_duration = 86400
  }
}

resource "aws_security_group" "ecs_alb_sg" {
  name        = "${var.name}-ecs-sg"
  description = "Security group for Load Balancer ${var.name}"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow all inbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}