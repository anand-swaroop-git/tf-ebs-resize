#---------networking/main.tf

# Get information about availability zones
data "aws_availability_zones" "available" {}

# Create VPC
resource "aws_vpc" "poc_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

}

# Gateway
resource "aws_internet_gateway" "poc_internet_gateway" {
  vpc_id = aws_vpc.poc_vpc.id
}

# Public subnets
resource "aws_subnet" "poc_public_subnet" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.poc_vpc.id
  map_public_ip_on_launch = "true"
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]

}

resource "aws_security_group" "poc_security_group" {
  name        = var.name_sg
  description = var.description_sg
  vpc_id      = aws_vpc.poc_vpc.id

  # default inbound rules
  dynamic "ingress" {
    for_each = ["22"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

  }
  # custom inbound rules
  dynamic "ingress" {
    for_each = var.inbound_sg_rules
    content {
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      cidr_blocks     = ingress.value.cidr_blocks
      self            = ingress.value.self
      description     = ingress.value.description
      security_groups = ingress.value.security_groups
    }
  }
  # outbound rules.
  dynamic "egress" {
    for_each = var.outbound_sg_rules
    content {
      from_port       = egress.value.from_port
      to_port         = egress.value.to_port
      protocol        = egress.value.protocol
      cidr_blocks     = egress.value.cidr_blocks
      self            = egress.value.self
      description     = egress.value.description
      security_groups = egress.value.security_groups
    }
  }
}

# Routing and association for public subnets
#-----------------------------------------------------------------
resource "aws_route_table" "poc_public_rt" {
  vpc_id = aws_vpc.poc_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.poc_internet_gateway.id
  }
}

resource "aws_route_table_association" "poc_public_assoc" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.poc_public_subnet[count.index].id
  route_table_id = aws_route_table.poc_public_rt.id
}


