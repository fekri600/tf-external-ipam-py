.ONESHELL:
.SHELLFLAGS = -e -o pipefail -c

apply:
	@echo "🔧 Deploying backend module..."
	cd modules/backend_setup && terraform init && terraform apply -auto-approve

	@echo "📦 Saving backend details..."
	cd modules/backend_setup && terraform output -raw bucket_name > .backend_bucket
	cd modules/backend_setup && terraform output -raw dynamodb_table_name > .backend_table
	cd modules/backend_setup && terraform output -raw region > .backend_region
	cd modules/backend_setup && echo "terraform/state/root.tfstate" > .key

	@echo "🛠️ Generating providers.tf..."
	bash generate_provider_file.sh

	@echo "📄 Copying providers.tf to modules/oidc..."
	cp providers.tf modules/oidc/providers.tf

	@echo "🚀 Deploying GitHub OIDC pipeline..."
	BACKEND_BUCKET=$$(cat modules/backend_setup/.backend_bucket)
	cd modules/oidc && \
		terraform init && \
		( terraform workspace list | grep -q 'oidc' && terraform workspace select oidc || terraform workspace new oidc ) && \
		terraform apply -auto-approve -var="state_bucket_name=$$BACKEND_BUCKET" && \
		terraform output -raw github_trust_role_arn > .github_role

	@echo "✅ Apply completed."


delete:
	@echo "🗑️ Destroying backend infrastructure..."
	cd modules/backend_setup && terraform destroy -auto-approve

	@echo "🗑️ Destroying GitHub OIDC pipeline infrastructure..."
	cd modules/oidc && \
		terraform init && \
		( terraform workspace list | grep -q 'oidc' && terraform workspace select oidc || terraform workspace new oidc ) && \
		terraform destroy -auto-approve

	@echo "🧹 Cleaning up generated files..."
	rm -f modules/backend_setup/.backend_bucket modules/backend_setup/.backend_table modules/backend_setup/.backend_region modules/backend_setup/.key modules/oidc/.github_role

	@echo "✅ Delete completed."
