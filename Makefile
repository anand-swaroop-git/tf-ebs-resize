init:
	terraform init

plan:
	terraform plan

clean:
	rm -rf .terraform

fmt:
	terraform fmt && terraform validate

apply:
	terraform apply --auto-approve

destroy:
	terraform apply -destroy --auto-approve