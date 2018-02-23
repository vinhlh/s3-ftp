KMS_KEY_ID=alias/oms/ecs
SECRETS_BUCKET_NAME=oms-services.secrets
APP_NAME=s3-ftp
DOCKER_REPO=589072213673.dkr.ecr.ap-southeast-1.amazonaws.com/s3-ftp

OK_COLOR=\033[32;01m
NO_COLOR=\033[0m

build:
	@echo "$(OK_COLOR)==>$(NO_COLOR) Building $(DOCKER_REPO)"
	@docker build -t $(DOCKER_REPO) .

push:
	@echo "$(OK_COLOR)==>$(NO_COLOR) Pushing $(DOCKER_REPO)"
	@docker push $(DOCKER_REPO)

run:
	@echo "$(OK_COLOR)==>$(NO_COLOR) Running $(DOCKER_REPO)"
	@docker rm -f $(APP_NAME) || true
	@docker run --privileged --name $(APP_NAME) -v ~/.aws:/root/.aws -p 21:21 -p 40000-40400:40000-40400 $(DOCKER_REPO)

sync:
	@echo "$(OK_COLOR)==>$(NO_COLOR) Syncing secrets to s3://$(SECRETS_BUCKET_NAME)/$(APP_NAME)"
	@aws s3 cp secrets s3://$(SECRETS_BUCKET_NAME)/$(APP_NAME).secrets --sse "aws:kms" --sse-kms-key-id "$(KMS_KEY_ID)"
