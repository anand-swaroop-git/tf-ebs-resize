resource "aws_key_pair" "ebs-poc" {
  key_name   = "ebs-poc"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQDn4JX6EB4NWC6qoRFfz+TZ3SU3sZ78aBcRTZ2Lzq7r09IVYGnrKm7QuAWfvRMmCISQq+n1y+z0GHG5mCae+V9Cxlfey34VvzOgRDaOC0FJxtzyYqAeQP7K8LE5sGTdu+4LAyx1ssNm6EFysABKlGR2hmlY8Xst6gBiEY3mk5NHuQ== anandswaroop@MacBook-Pro.local"
}
resource "aws_security_group" "allow_web" {
  name        = "standalone"
  vpc_id      = aws_vpc.poc_vpc.id
  description = "Allows access to Web Port"
  #allow http 
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # allow https
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # allow SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
    create_before_destroy = true
  }
}

# TODO: Remove hardcoded AMI
resource "aws_instance" "ec2" {
  ami                    = "ami-0b21dcff37a8cd8a4"
  instance_type          = "c5.large"
  subnet_id              = aws_subnet.poc_public_subnet[0].id
  vpc_security_group_ids = [aws_security_group.allow_web.id]
  iam_instance_profile   = aws_iam_instance_profile.dev-resources-iam-profile.name
  key_name               = aws_key_pair.ebs-poc.key_name
  root_block_device {
    delete_on_termination = true
    volume_type           = "gp2"
    volume_size           = var.initial_ebs_size
  }
  user_data = file("ssm_agent_install.sh")
}

resource "aws_iam_instance_profile" "dev-resources-iam-profile" {
  name = "ec2_profile"
  role = aws_iam_role.dev-resources-iam-role.name
}
resource "aws_iam_role" "dev-resources-iam-role" {
  name               = "dev-ssm-role"
  description        = "The role for the developer resources EC2"
  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": {
"Effect": "Allow",
"Principal": {"Service": "ec2.amazonaws.com"},
"Action": "sts:AssumeRole"
}
}
EOF
  tags = {
    stack = "test"
  }
}
resource "aws_iam_role_policy_attachment" "dev-resources-ssm-policy" {
  role       = aws_iam_role.dev-resources-iam-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}