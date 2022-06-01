output "ec2_public_ip" {
  value = "ssh -i ~/.ssh/ebs-poc-id_rsa ubuntu@${aws_instance.ec2.public_ip}"
}

output "ec2_instance_id" {
  value = aws_instance.ec2.id
}

output "apig_endpoint" {
  value = "${aws_api_gateway_deployment.create-api-deployment-stage1.invoke_url}/${aws_api_gateway_resource.api-gateway-resource.path_part}"
}

output "curl_command" {
  value = "curl --location --request POST ${aws_api_gateway_deployment.create-api-deployment-stage1.invoke_url}/${aws_api_gateway_resource.api-gateway-resource.path_part} --header 'Content-Type: application/json' --data-raw '{\"instance_id\": \"${aws_instance.ec2.id}\"}'"
}
