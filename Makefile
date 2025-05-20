.ONESHELL:
.SHELLFLAGS = -e -o pipefail -c
ENVIRONMENTS = staging production

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
	@echo "📡 Waiting 20 seconds for logs to be delivered..."
	sleep 20

	@echo "📡 Fetching CloudWatch logs for connectivity tests..."
	@mkdir -p outputs
	@for env in staging production; do \
		echo "🔍 Environment: $$env"; \
		LOG_GROUP="/ssm_connectivity-$$env"; \
		INSTANCE_TAG="fekri-$$env-ec2"; \
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
