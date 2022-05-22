output "ec2_public_ip" {
  value = "ssh -i ~/.ssh/ebs-poc-id_rsa ubuntu@${aws_instance.ec2.public_ip}"
}