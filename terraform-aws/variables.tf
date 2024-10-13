#Os valores default das variaveis estao sendo setadas no arquivo terraform-tfvars

#variavel de ambiente setada fixa como (dev)
variable "enviroment" {

  type = string

  description = ""

  default = "dev"

}

#Variavel da região aws que iremos utilizar 
variable "aws_region" {

  type = string

  description = ""


}


#Variavel do perfil da aws configurado no terminal local 
variable "aws_profile" {

  type = string

  description = ""

}

#variavel que recebe a imagem ami que quero utilizar para minhas instancias
variable "instance_ami" {

  type = string

  description = ""


}

#Variavel que recebe o tipo da instancia ec2 que quero utilizar
variable "aws_type" {

  type = string

  description = ""


}

#Variavel que recebe o valor das tags que vou inserir nas instancias ec2
variable "instance_tags" {

  type = map(string)

  description = ""

  default = {

    Name = "Ubuntu"

    Project = "AWS com Terraform"
  }
}

#variable "aws_account_id" {

# type = string

#description = ""

#}


variable "service_name" {

  type = string

  description = ""

  default = "autoscaling-app"

}


variable "instance_key_name" {

  type = string

  description = ""

  default = "terraform"

}