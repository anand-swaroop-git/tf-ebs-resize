aws_region = "ap-southeast-2"


vpc_cidr            = "10.1.0.0/16"
poc_av_zone_subnet  = ["10.1.48.0/20"]
public_subnet_cidrs = ["10.1.0.0/20"]
name_sg             = "poc_security_group"
description_sg      = "Created by Terraform."
inbound_sg_rules = [
  { from_port : "0",
    to_port : "0",
    protocol : "-1",
    description : null,
    self : true,
    cidr_blocks : ["0.0.0.0/0"],
    security_groups : []
  }
]

# outbound rules
outbound_sg_rules = [
  { from_port : "0",
    to_port : "0",
    protocol : "-1",
    description : null,
    self : false,
    cidr_blocks : ["0.0.0.0/0"],
    security_groups : []
  }
]
route = [
  { cidr_block     = "0.0.0.0/0",
    nat_gateway_id = "true"
  }
]