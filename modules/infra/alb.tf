# alb sg
resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.vpc.id
  name   = "${data.aws_region.this.name}-ec2-alb"


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Create ELB
resource "aws_lb" "this" {
  name = "${data.aws_region.this.name}-elb"
  #   availability_zones = slice(data.aws_availability_zones.this.names, 0, 3)
  security_groups = [aws_security_group.alb_sg.id]
  internal        = false
  subnets         = [aws_subnet.subnet-d.id]

  #   listener {
  #     instance_port     = 80
  #     instance_protocol = "HTTP"
  #     lb_port           = 80
  #     lb_protocol       = "HTTP"
  #   }

  #   listener {
  #     instance_port     = 443
  #     instance_protocol = "HTTP"
  #     lb_port           = 443
  #     lb_protocol       = "HTTPS"

  #     # ssl_certificate_id = "rn:aws:iam::123456789012:server-certificate/certname"
  #   }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
resource "aws_lb_target_group" "this" {
  name        = "${data.aws_region.this.name}-alb"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
}





# output "nginx_domain" {
#   value = aws_instance.instance.public_dns
# }
