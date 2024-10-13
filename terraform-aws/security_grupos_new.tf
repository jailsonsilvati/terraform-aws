resource "aws_security_group" "web" {
  name        = "Web"
  description = "Allow public inbound traffic"
  vpc_id      = aws_vpc.this.id

  # Regras de ingresso para o grupo Web
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP from anywhere"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS from anywhere"
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow ICMP from all"
  }


  # Regras de saída para o grupo Web
  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.this["pvt_a"].cidr_block]
    description = "Allow outbound traffic from subnet "
  }

  tags = merge(local.common_tags, { Name = "Web Server" })
}

resource "aws_security_group" "db" {
  name        = "DB"
  description = "Allow inbound traffic for database"
  vpc_id      = aws_vpc.this.id

  # Regras de ingresso para o grupo DB
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
    description     = "Allow MySQL from Web SG"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.this.cidr_block]
    description = "Allow SSH from VPC"
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [aws_vpc.this.cidr_block]
    description = "Allow ICMP from VPC"
  }

  # Regras de saída para o grupo DB
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outbound HTTP"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outbound HTTPS"
  }

  tags = merge(local.common_tags, { Name = "Database Server" })
}

resource "aws_security_group" "alb" {

  name = "ALB-SG"

  description = "Load Balancer SG"

  vpc_id = aws_vpc.this.id

  ingress {

    from_port = 80

    to_port = 80

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }


  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = merge(local.common_tags, { Name = "Load Balancer" })

}




resource "aws_security_group" "autoscaling" {

  name = "autoscaling"

  description = "Security group that allows ssh/http and all egress traffic"

  vpc_id = aws_vpc.this.id

  ingress {

    from_port = 22

    to_port = 22

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }


  ingress {

    from_port = 80

    to_port = 80

    protocol = "tcp"

    security_groups = [aws_security_group.alb.id]

  }


  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = merge(local.common_tags, { Name = "Auto Scaling" })

}



resource "aws_security_group" "jenkins" {
  name        = "Jenkins"
  description = "Allow incoming connections to Jenkins Machine"
  vpc_id      = aws_vpc.this.id


  #Para conectar na maquina Jenkins, eu conecto numa outra maquina (bastion Host) , que estará na subrede Pub
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.this.cidr_block]

  }


  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [aws_vpc.this.cidr_block]
    description = "Allow ICMP from VPC"
  }


  egress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  tags = merge(local.common_tags, { Name = "Jenkins Machine" })



}