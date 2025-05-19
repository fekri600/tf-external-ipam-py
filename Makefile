.ONESHELL:
.SHELLFLAGS = -e -o pipefail -c

apply:
	@echo "🔧 Deploying bootstrap ..."
	cd bootstrap && terraform init && terraform apply -auto-approve

	@echo "📦 Saving backend details..."
	cd bootstrap && terraform output -raw bucket_name > outputs/.backend_bucket
	cd bootstrap && terraform output -raw dynamodb_table_name > outputs/.backend_table
	cd bootstrap && terraform output -raw region > outputs/.backend_region
	cd bootstrap && echo "terraform/state/root.tfstate" > outputs/.key
	
	@echo "📦 Saving oidc details..."
	
	cd bootstrap && terraform output -raw TRUST_ROLE_GITHUB > outputs/.github_role

	@echo "🛠️ Generating providers.tf..."
	bash scripts/generate_provider_file.sh

	@echo "✅ Apply completed."


delete:
	@echo "🗑️ Destroying GitHub bootstrap infrastructure..."
	
	cd bootstrap && terraform destroy -auto-approve

	@echo "🧹 Cleaning up generated files..."
	rm -f bootstrap/outputs/.backend_bucket bootstrap/outputs/.backend_table bootstrap/outputs/.backend_region bootstrap/outputs/.key bootstrap/outputs/.github_role

	@echo "✅ Delete completed."

test:
	terraform init && terraform apply -auto-approve
	