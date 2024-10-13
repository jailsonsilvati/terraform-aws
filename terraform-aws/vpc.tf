resource "aws_vpc" "this" {

  cidr_block = "172.16.0.0/16" #Faixa de Rede da VPN

  #Utilizando a funcao merge para utilizar os valores da common_tags criada 
  tags = merge(local.common_tags, { Name = "Terraform VPN" }) #Name especifica um nome para VPC

}

#Criando o internet Gateway para sainda de internet da VPC
resource "aws_internet_gateway" "this" {

  vpc_id = aws_vpc.this.id #Associando o internet gateway a VPC

  tags = merge(local.common_tags, { Name = "Terraform IG" })

}

#Criando subrede PUBLICAS e PRIVADAS,, vinculando ela a VPC , atribuido bloco de rede , e a zona de disponibilidade
resource "aws_subnet" "this" {

  # O uso do for_each aqui possibilita passar os valores em forma de lista
  for_each = {

    "pub_a" : ["172.16.1.0/24", "${var.aws_region}a", "Public A"]
    "pub_b" : ["172.16.2.0/24", "${var.aws_region}b", "Public B"]
    "pvt_a" : ["172.16.3.0/24", "${var.aws_region}a", "Private A"]
    "pvt_b" : ["172.16.4.0/24", "${var.aws_region}b", "Private B"]

  }


  vpc_id = aws_vpc.this.id

  cidr_block = each.value[0] #Pega o valor da coluna 0 do for_each acima

  availability_zone = each.value[1] #Pega o valor da coluna 1 do for_each acima

  tags = merge(local.common_tags, { Name = each.value[2] }) #Pega o valor da coluna 2 do for_each acima

}

#Criando as tabelas de Roteamento Publicas
resource "aws_route_table" "Public" {

  vpc_id = aws_vpc.this.id


  route {

    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.this.id

  }

  tags = merge(local.common_tags, { Name = "Terraform Routetable Public" })

}

#Criando as tabelas de Roteamento Privadas
resource "aws_route_table" "Private" {

  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, { Name = "Terraform Routetable Private" })

}

#Criando as associacoes entre tabelas de roteamento e subredes
resource "aws_route_table_association" "this" {

  #utilizando for para coletar informacoes nome e id das tags vindas da lista das subredes k= key e v= value 
  for_each = { for k, v in aws_subnet.this : v.tags.Name => v.id }

  #Recebe o valor retornado do for_each
  subnet_id = each.value

  # O comando substr faz uma pesquisa nas tres pimeiras letras do nome da subrede se for "Pub" entao aplica a router publica , se não a router private 
  route_table_id = substr(each.key, 0, 3) == "Pub" ? aws_route_table.Public.id : aws_route_table.Private.id

}