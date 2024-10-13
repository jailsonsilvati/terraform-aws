#Fixando a versão do terraform utilizada e do provedor
terraform {
  required_version = "1.9.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.68.0"
    }


    random = {

      source = "hashicorp/random"

      version = "3.6.3"

    }

  }
}

#Especificando o provedor , a regiao e o profile que configurei no aws cli da maquina
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}




