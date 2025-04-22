# Variables
TERRAFORM = terraform
ENV ?= np
TF_DIR = .
RUNTIME_LANG = python
RUNTIME_VERSION = 3.12
IMAGE_PREFIX = lambda-${RUNTIME_LANG}-${RUNTIME_VERSION}
LAMBDA_DIR=sources/src/functions

LOWER_FUNCTION := $(shell echo "$(FUNCTION)" | tr '[:upper:]' '[:lower:]')
FUNCTIONS := $(shell find $(LAMBDA_DIR) -type f -name "index.py" -exec dirname {} \; | sed 's|sources/src/functions/||' | sort | uniq)

# Commands
.PHONY: build run run-all clean clean-all logs logs-all

validate-function:
	@if [ -z "$(FUNCTION)" ]; then \
		echo "Error: FUNCTION variable is not set."; \
		echo "Usage: make build FUNCTION=<functionName>"; \
		exit 1; \
	fi
	@if [ ! -d "$(LAMBDA_DIR)/$(FUNCTION)" ]; then \
		echo "Error: Directory '$(LAMBDA_DIR)/$(FUNCTION)' does not exist."; \
		exit 1; \
	fi

build: validate-function
	@echo "Building Lambda function: $(FUNCTION)"
	docker build \
		--build-arg FUNCTION_NAME=$(FUNCTION) \
		--build-arg RUNTIME_LANG=$(RUNTIME_LANG) \
		--build-arg RUNTIME_VERSION=$(RUNTIME_VERSION) \
		-t $(IMAGE_PREFIX)-$(LOWER_FUNCTION):latest \
		-f docker/Dockerfile \
		.

run: validate-function
	@echo "Running Lambda function: $(FUNCTION)"
	@if [ "$(shell docker ps -q -f name=lambda-$(LOWER_FUNCTION))" ]; then \
		echo "Container 'lambda-$(LOWER_FUNCTION)' already exists. Removing..."; \
		docker rm -f lambda-$(LOWER_FUNCTION); \
	fi
	make build build FUNCTION=$(FUNCTION)
	docker run -d \
		--name "lambda-$(LOWER_FUNCTION)" \
		-p "8080" \
		-v "${PWD}/$(LAMBDA_DIR)/$(FUNCTION):/var/task/lambda" \
		-v "${PWD}/sources/src/layers/shared:/var/task/shared" \
		-v "${HOME}/.aws:/root/.aws/:ro" \
		$(IMAGE_PREFIX)-$(LOWER_FUNCTION):latest

run-all:
	@echo "Building and running all Lambda functions..."
	@for FUNCTION in $(FUNCTIONS); do \
		make build FUNCTION=$$FUNCTION && \
		make run FUNCTION=$$FUNCTION || exit 1; \
	done

logs: validate-function
	@echo "Tailing logs for Lambda function: $(FUNCTION)"
	@docker logs -f "lambda-$(LOWER_FUNCTION)" 2>&1 | ts "[lambda-$(LOWER_FUNCTION)] [%Y-%m-%d %H:%M:%S]"

logs-all:
	@echo "Tailing logs for all Lambda containers..."
	@for FUNCTION in $(FUNCTIONS); do \
		docker logs -f "lambda-$$(echo $$FUNCTION | tr '[:upper:]' '[:lower:]')" 2>&1 | ts "[lambda-$$(echo $$FUNCTION | tr '[:upper:]' '[:lower:]')] [%Y-%m-%d %H:%M:%S]" & \
	done
	wait

clean: validate-function
	@echo "Cleaning Lambda function: $(FUNCTION)"
	@docker rm -f lambda-$(LOWER_FUNCTION) 2>/dev/null || true
	@docker rmi my-lambda-$(LOWER_FUNCTION):latest 2>/dev/null || true
	@echo "Cleanup complete for '$(FUNCTION)'."

clean-all:
	@echo "Cleaning all Lambda functions..."
	@for FUNCTION in $(FUNCTIONS); do \
		make clean FUNCTION=$$FUNCTION; \
	done
	@echo "All Lambdas cleaned up."

init:
	@echo "Initializing Terraform for environment: $(ENV)"
	./scripts/ssm_param.sh > environments/remote.tfbackend
	cd $(TF_DIR) && $(TERRAFORM) init -backend-config=environments/remote.tfbackend -reconfigure --upgrade

plan:
	@echo "Planning Terraform changes for environment: $(ENV)"
	cd $(TF_DIR) && $(TERRAFORM) plan -var-file=environments/np.tfvars

apply:
	@echo "Applying Terraform changes for environment: $(ENV)"
	cd $(TF_DIR) && $(TERRAFORM) apply $(TF_PLAN) -var-file=environments/np.tfvars

destroy:
	@echo "Destroying Terraform infrastructure for environment: $(ENV)"
	cd $(TF_DIR) && $(TERRAFORM) destroy -var-file=environments/np.tfvars
