output "vpc_id" {

  value = aws_vpc.this.id

}

output "igw_id" {

  value = aws_internet_gateway.this.id

}

#Expondo informações da subrede
output "subnet_ids" {
  #utilizando for para coletar informacoes nome e id das tags vindas da lista das subredes k= key e v= value   
  value = { for k, v in aws_subnet.this : v.tags.Name => v.id }

}

#Expondo informações da tabela de roteamento

output "public_route_table_id" {

  value = aws_route_table.Public.id

}

output "private_route_table_id" {

  value = aws_route_table.Private.id

}

output "sg_web_id" {

  value = aws_security_group.web.id

}

output "sg_db_id" {

  value = aws_security_group.db.id

}

output "sg_alb_id" {

  value = aws_security_group.alb.id

}


output "alb_id" {

  value = aws_lb.this.id

}
