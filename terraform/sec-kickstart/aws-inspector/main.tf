locals {
  create_sns_topic = var.enable && var.create_sns_topic

  sns_topic_arn = local.create_sns_topic ? join("", aws_sns_topic.sns_topic_inspector_alerts.*.arn) : var.sns_topic_arn
}

resource "aws_cloudwatch_event_target" "cloudwatch_event_inspector_target" {
  count = var.enable ? 1 : 0

  target_id = "inspector_assessment"
  rule      = aws_cloudwatch_event_rule.cloudwatch_event_inspector_assessment_kickstart[0].name
  arn       = var.ecs_cluster_id
  role_arn  = aws_iam_role.ecs_inspector_events[0].arn

  ecs_target {
    launch_type         = var.ecs_launch_type
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.ecs_inspector_assessment_kickstarter[0].arn

    network_configuration {
      security_groups = [aws_security_group.inspector_assessment_group_allow_egress[0].id]
      subnets         = var.assessment_instance_subnet_ids
    }
  }
}

resource "aws_sns_topic" "sns_topic_inspector_alerts" {
  count = local.create_sns_topic ? 1 : 0

  name = "${var.name}-alerts-topic"

  #tfsec:ignore:aws-sns-topic-encryption-use-cmk
  kms_master_key_id = "alias/aws/sns"
}

resource "aws_cloudwatch_event_rule" "cloudwatch_event_inspector_assessment_kickstart" {
  count = var.enable ? 1 : 0

  name        = "${var.name}-assessment-kickstart"
  description = "Kickstarts an Amazon Inspector assessment"

  schedule_expression = var.cloudwatch_cron_schedule != null ? var.cloudwatch_cron_schedule : "cron(0 3 * * ? 2000)"
}

resource "aws_ecs_task_definition" "ecs_inspector_assessment_kickstarter" {
  count = var.enable ? 1 : 0

  family                   = "${var.name}-inspector"
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.inspector_kickstarter_role[0].arn
  execution_role_arn       = aws_iam_role.inspector_kickstarter_role[0].arn

  tags = var.tags

  container_definitions = <<DEFINITION
[
  {
    "cpu": ${var.inspector_kickstarter_container_task_cpu},
    "environment": [
        {
            "name": "SNS_ALERT_TOPIC_ARN",
            "value": "${local.sns_topic_arn}"
        },
        {
            "name": "INSTANCE_SUBNET_ID",
            "value": "${join(",", var.assessment_instance_subnet_ids)}"
        },
        {
            "name": "INSTANCE_SECURITY_GROUP",
            "value": "${aws_security_group.inspector_assessment_group_allow_egress[0].id}"
        },
        {
            "name": "INSPECTOR_ASSESSMENT_TEMPLATE",
            "value": "${aws_inspector_assessment_template.vulnerability_assessment_template[0].arn}"
        },
        {
            "name": "TAG_KEYS",
            "value": "${join(",", keys(var.tags))}"
        },
        {
            "name": "TAG_VALUES",
            "value": "${join(",", values(var.tags))}"
        },
        {
            "name": "AWS_DEFAULT_REGION",
            "value": "${var.aws_region}"
        }
    ],
    "essential": true,
    "image": "${var.inspector_kickstarter_container_image}",
    "memory": ${var.inspector_kickstarter_container_task_memory},
    "memoryReservation": ${var.inspector_kickstarter_container_memory_reservation},
    "name": "${var.name}-kickstarter",
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-create-group": "true",
            "awslogs-group": "${var.cloudwatch_log_group}",
            "awslogs-region": "${var.aws_region}",
            "awslogs-stream-prefix": "ecs"
        }
    }
  }
]
DEFINITION
}

data "aws_inspector_rules_packages" "rules" {
  count = var.enable ? 1 : 0
}

resource "aws_inspector_assessment_template" "vulnerability_assessment_template" {
  count = var.enable ? 1 : 0

  name       = "${var.name} Full scan"
  target_arn = aws_inspector_assessment_target.vulnerability_assessment_targets[0].arn
  duration   = 3600

  rules_package_arns = data.aws_inspector_rules_packages.rules[0].arns
}

resource "aws_inspector_resource_group" "vulnerability_assessment_instance_attributes" {
  count = var.enable ? 1 : 0

  tags = var.tags
}

resource "aws_inspector_assessment_target" "vulnerability_assessment_targets" {
  count = var.enable ? 1 : 0

  name               = "${var.name} assessment target"
  resource_group_arn = aws_inspector_resource_group.vulnerability_assessment_instance_attributes[0].arn
}

# Add security group that does not allow inbound traffic
resource "aws_security_group" "inspector_assessment_group_allow_egress" {
  count = var.enable ? 1 : 0

  name        = "${var.name}_assessment_group_allow_egress"
  description = "Allow outbound traffic for inspector assessment"
  vpc_id      = var.vpc_id

  egress {
    description = "Allow outbound traffic for inspector assessment"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    #tfsec:ignore:aws-ec2-no-public-egress-sgr
    cidr_blocks = ["0.0.0.0/0"]
    #tfsec:ignore:aws-ec2-no-public-egress-sgr
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = var.tags
}

data "aws_iam_policy_document" "inspector_policy" {
  statement {
    sid    = "AllowLogging"
    effect = "Allow"
    #tfsec:ignore:aws-iam-no-policy-wildcards
    resources = ["arn:aws:logs:*:*:*"]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
    ]
  }

  statement {
    sid    = "AllowCreateTagsInstances"
    effect = "Allow"
    #tfsec:ignore:aws-iam-no-policy-wildcards
    resources = ["arn:aws:ec2:*:*:instance/*"]
    actions   = ["ec2:CreateTags"]
  }

  statement {
    sid    = "AllowToDescribeAll"
    effect = "Allow"
    #tfsec:ignore:aws-iam-no-policy-wildcards
    resources = ["*"]

    #tfsec:ignore:aws-iam-no-policy-wildcards
    actions = ["ec2:Describe*"]
  }

  statement {
    sid    = "AllowRunInstances"
    effect = "Allow"
    #tfsec:ignore:aws-iam-no-policy-wildcards
    resources = ["*"]

    actions = [
      "ec2:RunInstances",
      "ec2:TerminateInstances",
    ]
  }

  statement {
    sid       = "AllowInspectorScanning"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "inspector:DescribeAssessmentRuns",
      "inspector:DescribeAssessmentTemplates",
      "inspector:DescribeFindings",
      "inspector:ListAssessmentRuns",
      "inspector:ListAssessmentTemplates",
      "inspector:ListFindings",
      "inspector:StartAssessmentRun",
    ]
  }

  dynamic "statement" {
    for_each = local.sns_topic_arn != "" ? [local.sns_topic_arn] : []
    content {
      sid       = "AllowSNSTopicPublishing"
      effect    = "Allow"
      actions   = ["sns:Publish"]
      resources = [statement.value]
    }
  }

  statement {
    sid       = "DenyTerminatingNonTagged"
    effect    = "Deny"
    resources = ["*"]
    actions   = ["ec2:TerminateInstances"]

    condition {
      test     = "StringNotEquals"
      variable = "ec2:ResourceTag/vulnerability-assessment"
      values   = ["true"]
    }
  }

  statement {
    sid       = "DenyRunningBigInstances"
    effect    = "Deny"
    resources = ["*"]
    actions   = ["ec2:RunInstances"]

    condition {
      test     = "ForAnyValue:StringNotLike"
      variable = "ec2:InstanceType"

      values = [
        "t2.*",
        "t3.*",
      ]
    }
  }
}

resource "aws_iam_policy" "inspector_kickstarter_policy" {
  count = var.enable ? 1 : 0

  name        = "${var.name}_kickstarter_policy"
  path        = "/"
  description = "Policy for handling automatic AWS inspector assessments"

  policy = data.aws_iam_policy_document.inspector_policy.json
}

resource "aws_iam_role" "inspector_kickstarter_role" {
  count = var.enable ? 1 : 0

  name = "${var.name}_kickstarter_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com",
          "ecs-tasks.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "inspector_role_policy_attachment" {
  count = var.enable ? 1 : 0

  role       = aws_iam_role.inspector_kickstarter_role[0].name
  policy_arn = aws_iam_policy.inspector_kickstarter_policy[0].arn
}

resource "aws_iam_role" "ecs_inspector_events" {
  count = var.enable ? 1 : 0

  name = "${var.name}_ecs_inspector_events"

  assume_role_policy = <<DOC
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
DOC
}

resource "aws_iam_role_policy" "ecs_events_inspector_run_task" {
  count = var.enable ? 1 : 0

  name = "${var.name}_ecs_events_inspector_run_task"
  role = aws_iam_role.ecs_inspector_events[0].id

  policy = <<DOC
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "ecs:RunTask",
              "ecs:StartTask"
            ],
            "Resource": "${aws_ecs_task_definition.ecs_inspector_assessment_kickstarter[0].arn}"
        },
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": [
                "${aws_iam_role.inspector_kickstarter_role[0].arn}"
            ],
            "Condition": {
                "StringLike": {
                    "iam:PassedToService": "ecs-tasks.amazonaws.com"
                }
            }
        }
    ]
}
DOC
}
