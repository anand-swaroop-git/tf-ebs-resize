##################################################################################
# VARIABLES
##################################################################################

variable "aws_region" {
  type        = string
  description = "AWS REGION"
}

#---------networking/variables.tf



variable "vpc_cidr" {}

variable "poc_av_zone_subnet" {
  type = list(any)
}

variable "public_subnet_cidrs" {}

variable "inbound_sg_rules" {
  type = list(object({
    to_port         = string,
    from_port       = string,
    cidr_blocks     = list(string),
    protocol        = string,
    self            = bool,
    description     = string,
    security_groups = list(string)
  }))
}

variable "outbound_sg_rules" {
  type = list(object({
    to_port         = string,
    from_port       = string,
    cidr_blocks     = list(string),
    protocol        = string,
    self            = bool,
    description     = string,
    security_groups = list(string)
  }))
}

variable "route" {
  type = list(map(string))
}

variable "name_sg" {}
variable "description_sg" {}

variable "initial_ebs_size" {}
variable "final_ebs_size" {}
