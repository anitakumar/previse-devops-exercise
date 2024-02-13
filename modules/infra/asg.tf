data "aws_caller_identity" "current" {}

data "aws_availability_zones" "this" {
  state = "available"
}

resource "aws_launch_template" "this" {
  name_prefix            = "${data.aws_region.this.name}-launch-template"
  image_id               = var.ami-name
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.ec2-sg.id]
  user_data              = filebase64("${path.module}/app.sh")
  monitoring {
    enabled = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "this" {

  desired_capacity    = 1
  max_size            = 1
  min_size            = 1
  vpc_zone_identifier = [aws_subnet.subnet-a.id, aws_subnet.subnet-b.id, aws_subnet.subnet-c.id]
  #   health_check_type     = "ELB"

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }
}

resource "aws_security_group" "ec2-sg" {
  vpc_id = aws_vpc.vpc.id
  name   = "${data.aws_region.this.name}-ec2-sg"

  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = "22"
    to_port     = "22"
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


###### Target Tracking Scaling Policies ######
# TTS - Scaling Policy-1: Based on CPU Utilization
# Define Autoscaling Policies and Associate them to Autoscaling Group
resource "aws_autoscaling_policy" "avg_cpu_policy_greater_than_50" {
  name                      = "avg-cpu-policy-greater-than-50"
  policy_type               = "TargetTrackingScaling" # Important Note: The policy type, either "SimpleScaling", "StepScaling" or "TargetTrackingScaling". If this value isn't provided, AWS will default to "SimpleScaling."    
  autoscaling_group_name    = aws_autoscaling_group.this.id
  estimated_instance_warmup = 180 # defaults to ASG default cooldown 300 seconds if not set
  # CPU Utilization is above 50
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }

}

resource "aws_autoscaling_attachment" "this" {
  autoscaling_group_name = aws_autoscaling_group.this.id
  lb_target_group_arn    = aws_lb_target_group.this.arn
}

