data "aws_ami" "ubuntu" {

  owners = ["amazon"]

  most_recent = true

  name_regex = "ubuntu"


  filter {

    name = "architecture"

    values = ["x86_64"]

  }

}

#Criando o Launch Template

resource "aws_launch_template" "this" {

  name_prefix = "terraform-"

  image_id = data.aws_ami.ubuntu.id

  instance_type = var.aws_type

  key_name = var.instance_key_name

  user_data = filebase64("ec2_setup.sh")

  monitoring {

    enabled = true

  }

  network_interfaces {

    associate_public_ip_address = true

    delete_on_termination = true

    security_groups = [aws_security_group.autoscaling.id]

  }

}


#Criando o autoscaling Group 

resource "aws_autoscaling_group" "this" {

  name = "terraform-autoscaling"

  vpc_zone_identifier = [aws_subnet.this["pub_a"].id, aws_subnet.this["pub_b"].id]

  max_size = 5

  min_size = 2

  health_check_grace_period = 240 #4 minutos

  health_check_type = "ELB"

  force_delete = true

  target_group_arns = [aws_lb_target_group.this.id]


  #setando o launch template 

  launch_template {

    id = aws_launch_template.this.id

    version = aws_launch_template.this.latest_version

  }

}


#Policy para criar as novas instancias quando aumentar o processamento
resource "aws_autoscaling_policy" "scaleup" {

  name = "Scale Up"

  autoscaling_group_name = aws_autoscaling_group.this.name

  adjustment_type = "ChangeInCapacity"

  scaling_adjustment = "1"

  cooldown = "180" #3 Minutos para esperar e executar uma checagem de escalonamento 

  policy_type = "SimpleScaling"

}



#Policy para deletar as novas instancias quando diminuir o processamento
resource "aws_autoscaling_policy" "scaledown" {

  name = "Scale Down"

  autoscaling_group_name = aws_autoscaling_group.this.name

  adjustment_type = "ChangeInCapacity"

  scaling_adjustment = "-1"

  cooldown = "180" # 3 Minutos para esperar e executar uma checagem de reduzir o escalonamento

  policy_type = "SimpleScaling"

}


resource "aws_instance" "jenkins" {

  ami = data.aws_ami.ubuntu.id

  instance_type = var.aws_type

  vpc_security_group_ids = [aws_security_group.jenkins.id]

  subnet_id = aws_subnet.this["pvt_b"].id

  availability_zone = "${var.aws_region}b"

  tags = merge(local.common_tags, { Name = "Jenkins Machine" })



}