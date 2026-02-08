resource "aws_lb" "this" {
  name               = substr("${var.name}-alb", 0, 32)
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = values(aws_subnet.public)[*].id

  tags = merge(local.common_tags, {
    Name = "${var.name}-alb"
  })
}

resource "aws_lb_target_group" "this" {
  name                 = substr("${var.name}-ecs-tg", 0, 32)
  port                 = var.container_port
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = aws_vpc.this.id
  deregistration_delay = var.deregistration_delay

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = var.health_check_interval
    timeout             = 5
    path                = var.health_check_path
    matcher             = "200-399"
  }

  tags = merge(local.common_tags, {
    Name = "${var.name}-ecs-tg"
  })
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.alb_listener_port
  protocol          = var.alb_listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
