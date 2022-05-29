output "ec2_public_ip" {
  value = "ssh -i ~/.ssh/ebs-poc-id_rsa ubuntu@${aws_instance.ec2.public_ip}"
}

output "ec2_instance_id" {
  value = aws_instance.ec2.id
}

output "apig_endpoint" {
  value = aws_api_gateway_deployment.create-api-deployment-stage1.invoke_url
}


/* curl --location --request POST 'https://i3uztnxpq0.execute-api.ap-southeast-2.amazonaws.com/poc/poc' \
--header 'Content-Type: application/json' \
--data-raw '{
    "instance_id"  : "i-0fa9a62d8165664e4"
}' */