init:
	terraform init

plan:
	terraform plan

clean:
	rm -rf .terraform

fmt:
	terraform fmt && terraform validate

apply:
	make fmt && terraform apply --auto-approve

destroy:
	terraform apply -destroy --auto-approve