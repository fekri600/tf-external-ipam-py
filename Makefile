apply:
	@echo "🔧 Deploying backend module..."
	cd modules/backend_setup && terraform init && terraform apply -auto-approve

	@echo "📦 Saving backend details..."
	cd modules/backend_setup && terraform output -raw bucket_name > ../../.backend_bucket
	cd modules/backend_setup && terraform output -raw dynamodb_table_name > ../../.backend_table
	echo us-east-1 > .backend_region

	@echo "🛠️ Generating provider.tf..."
	bash generate_provider_file.sh

	@echo "⚙️ Initializing and applying root Terraform..."
	terraform init
	terraform apply -auto-approve

delete:
	@echo "🗑️ Destroying root infrastructure..."
	terraform destroy -auto-approve
	
	@echo "🗑️ Destroying backend infrastructure..."
	cd modules/backend_setup && terraform destroy -auto-approve