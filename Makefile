apply:
	terraform init
	terraform fmt
	terraform validate
	terraform apply --auto-approve
delete:
	terraform destroy --auto-approve