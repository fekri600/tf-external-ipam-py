.ONESHELL:
.SHELLFLAGS = -e -o pipefail -c
ENVIRONMENTS = staging production

# === Conditional Bootstrap Check ===
check-bootstrap:
	@echo "🔍 Checking if bootstrap infrastructure is already in place..."
	BACKEND_BUCKET_FILE=bootstrap/outputs/.backend_bucket
	GITHUB_ROLE_FILE=bootstrap/outputs/.github_role

	NEED_BOOTSTRAP=0

	if [[ -f "$$BACKEND_BUCKET_FILE" ]]; then
		BACKEND_BUCKET=$$(cat $$BACKEND_BUCKET_FILE)
	else
		BACKEND_BUCKET=$$(aws s3api list-buckets --query 'Buckets[?contains(Name, `terraform-backend`)].Name' --output text | head -n1 || true)
	fi

	if [[ -z "$$BACKEND_BUCKET" ]]; then
		echo "❌ Terraform backend bucket not found."
		NEED_BOOTSTRAP=1
	else
		echo "✅ Terraform backend bucket exists: $$BACKEND_BUCKET"
	fi

	if [[ -f "$$GITHUB_ROLE_FILE" ]]; then
		GITHUB_ROLE=$$(basename $$(cat $$GITHUB_ROLE_FILE))
	else
		GITHUB_ROLE="GitHubOIDCTrustRole"
	fi

	if aws iam get-role --role-name "$$GITHUB_ROLE" >/dev/null 2>&1; then
		echo "✅ GitHub OIDC role exists: $$GITHUB_ROLE"
	else
		echo "❌ GitHub OIDC role not found."
		NEED_BOOTSTRAP=1
	fi

	if [[ $$NEED_BOOTSTRAP -eq 1 ]]; then
		echo "🚧 Bootstrap is required."
		exit 100
	else
		echo "✅ No bootstrap needed."
	fi

# === Bootstrap Setup ===
bootstrap:
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

	@echo "✅ Bootstrap apply completed."

# === Delete Bootstrap ===
delete-bootstrap:
	@echo "🗑️ Destroying GitHub bootstrap infrastructure..."
	cd bootstrap && terraform destroy -auto-approve

	@echo "🧹 Cleaning up generated files..."
	rm -f bootstrap/outputs/.backend_bucket bootstrap/outputs/.backend_table bootstrap/outputs/.backend_region bootstrap/outputs/.key bootstrap/outputs/.github_role

	@echo "✅ Delete completed."

# === Run Test and Fetch Logs ===
test:
	terraform init && terraform apply -auto-approve
	@echo "📡 Waiting 20 seconds for logs to be delivered..."
	sleep 20

	@echo "📡 Fetching CloudWatch logs for connectivity tests..."
	@mkdir -p outputs
	@for env in $(ENVIRONMENTS); do \
		echo "🔍 Environment: $$env"; \
		LOG_GROUP="/aws/ssm/connectivity-$$env"; \
		INSTANCE_TAG="i360moms-$$env-ec2"; \
		INSTANCE_ID=$$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$$INSTANCE_TAG" --query "Reservations[0].Instances[0].InstanceId" --output text); \
		LOG_STREAM=$$(aws logs describe-log-streams --log-group-name $$LOG_GROUP --order-by LastEventTime --descending --limit 1 --query "logStreams[0].logStreamName" --output text 2>/dev/null); \
		if [ "$$LOG_STREAM" = "None" ] || [ -z "$$LOG_STREAM" ]; then \
			echo "⚠️  Logs not found for $$env. Skipping."; \
		else \
			echo "📥 Downloading logs for $$env..."; \
			aws logs get-log-events \
				--log-group-name "$$LOG_GROUP" \
				--log-stream-name "$$LOG_STREAM" \
				--limit 50 \
				--output text > outputs/connectivity_test_$$env.txt; \
			echo "✅ Logs saved to outputs/connectivity_test_$$env.txt"; \
		fi; \
	done
