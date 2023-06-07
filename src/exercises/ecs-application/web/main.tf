locals {
  http_port              = 3000
  primary_container_name = "gitea"
}



module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = "sec-challenge"

  fargate_capacity_providers = {
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 100
      }
    }
  }

  services = {
    primary_service = {
      cpu                    = 256
      memory                 = 512
      subnet_ids             = var.public_subnets
      assign_public_ip       = true
      enable_execute_command = true

      container_definitions = {
        primary_container = {
          name                     = local.primary_container_name
          image                    = "gitea/gitea:1.19.3"
          essential                = true
          readonly_root_filesystem = false

          port_mappings = [
            {
              hostPort      = local.http_port
              containerPort = local.http_port
          }]

          health_check = {
            command      = ["CMD-SHELL", "curl -fSs 127.0.0.1:3000/api/healthz || exit 1"]
            interval     = 30
            timeout      = 5
            start_period = 60
            retries      = 3
          }

          mount_points = [
            {
              sourceVolume  = "data"
              containerPath = "/data"
              readOnly      = false
            }
          ]

          environment = [
            {
              name  = "GITEA__database__DB_TYPE"
              value = "mysql"
            },
            {
              name  = "GITEA__database__HOST"
              value = "${var.db_host}:${var.db_port}"
            },
            {
              name  = "GITEA__database__NAME"
              value = var.db_name
            },
            {
              name  = "GITEA__database__USER"
              value = var.db_username
            },
            {
              name  = "GITEA__database__PASSWD"
              value = var.db_password
            },
            {
              name  = "GITEA__server__ROOT_URL"
              value = "https://${var.default_subdomain}.${var.default_domain_name}/"
            },
            {
              name  = "GITEA__server__HTTP_PORT"
              value = local.http_port
            },
            {
              name  = "GITEA__server__PROTOCOL"
              value = "http"
            },
            {
              name  = "GITEA__server__DOMAIN"
              value = "${var.default_subdomain}.${var.default_domain_name}"
            }
          ]
        }
      }

      security_group_rules = {
        ingress_all = {
          type        = "ingress"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }

        egress_all = {
          type        = "egress"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }

      volume = {
        data = {
          efs_volume_configuration = {
            file_system_id     = aws_efs_file_system.data.id
            transit_encryption = "DISABLED"
          }
        }
      }

      load_balancer = {
        primary_container = {
          container_name   = local.primary_container_name
          container_port   = "${local.http_port}"
          target_group_arn = aws_lb_target_group.targetgroup.arn
        }
      }

      tasks_iam_role_policies = {
        allow_exec_command = aws_iam_policy.allow_exec_command.arn
      }

    }
  }
}

data "aws_iam_policy_document" "allow_exec_command" {
  statement {
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "allow_exec_command" {
  name   = "allow_exec_command"
  path   = "/exercises/securing-app-exercise/web/"
  policy = data.aws_iam_policy_document.allow_exec_command.json
}
