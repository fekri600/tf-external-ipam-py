.ONESHELL:
.SHELLFLAGS = -e -o pipefail -c

apply:
	@echo "🔧 Deploying backend module..."
	cd modules/backend_setup
	terraform init
	terraform apply -auto-approve

	@echo "📦 Saving backend details..."
	cd modules/backend_setup
	BACKEND_BUCKET=$$(terraform output -raw bucket_name)
	BACKEND_TABLE=$$(terraform output -raw dynamodb_table_name)
	BACKEND_REGION=$$(grep -A 1 'region' ../../providers.tf | tail -n 1 | sed 's/.*= "\(.*\)"/\1/')

	@echo "🛠️ Generating backend-config.hcl in modules/oidc/..."
	echo "bucket         = \"$$BACKEND_BUCKET\"" > ../../modules/oidc/backend-config.hcl
	echo "key            = \"terraform/state/infra_redesign_project.tfstate\"" >> ../../modules/oidc/backend-config.hcl
	echo "region         = \"$$BACKEND_REGION\"" >> ../../modules/oidc/backend-config.hcl
	echo "dynamodb_table = \"$$BACKEND_TABLE\"" >> ../../modules/oidc/backend-config.hcl

	@echo "$$BACKEND_BUCKET" > ../../modules/oidc/.backend_bucket

	@echo "⚙️ Initializing and applying root Terraform..."
	terraform init -backend-config=modules/oidc/backend-config.hcl
	terraform apply -auto-approve

apply-pipeline:
	@echo "🚀 Deploying GitHub OIDC pipeline..."
	cd modules/oidc
	BACKEND_BUCKET=$$(cat .backend_bucket)
	terraform init -backend-config=backend-config.hcl
	terraform apply -auto-approve -var="state_bucket_name=$$BACKEND_BUCKET"

delete:
	@echo "🗑️ Destroying root infrastructure..."
	terraform destroy -auto-approve

	@echo "🗑️ Destroying backend infrastructure..."
	cd modules/backend_setup
	terraform destroy -auto-approve

delete-pipeline:
	@echo "🗑️ Destroying GitHub OIDC pipeline infrastructure..."
	cd modules/oidc
	terraform destroy -auto-approve
