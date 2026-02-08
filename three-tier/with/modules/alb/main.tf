locals {
  name_prefix = lower(var.name_prefix)

  common_tags = merge(
    {
      ManagedBy = "terraform"
      Project   = local.name_prefix
    },
    var.tags
  )
}

resource "aws_security_group" "this" {
  description = "Internet-facing ALB security group"
  name_prefix = "${local.name_prefix}-alb-"
  vpc_id      = var.vpc_id

  ingress {
    cidr_blocks = var.ingress_cidr_blocks
    description = "Allow inbound HTTP"
    from_port   = var.listener_port
    protocol    = "tcp"
    to_port     = var.listener_port
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb-sg"
  })
}

resource "aws_lb" "this" {
  internal           = false
  load_balancer_type = "application"
  name               = substr("${local.name_prefix}-alb", 0, 32)
  security_groups    = [aws_security_group.this.id]
  subnets            = var.subnet_ids

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb"
  })
}

resource "aws_lb_target_group" "this" {
  name        = substr("${local.name_prefix}-tg", 0, 32)
  port        = var.target_group_port
  protocol    = var.target_group_protocol
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200-399"
    path                = var.health_check_path
    protocol            = var.target_group_protocol
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-tg"
  })
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.listener_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.this.arn
    type             = "forward"
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-http-listener"
  })
}
