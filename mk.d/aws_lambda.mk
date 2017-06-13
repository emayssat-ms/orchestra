_AWS_LAMBDA_MK_VERSION=0.99.0

LBA_ACTION?= lambda:InvokeFunction
LBA_ALIAS_NAME?= $(firstword $(LBA_ALIAS_NAMES))
# LBA_ALIAS_NAMES?=
LBA_DEPLOYMENT_PACKAGE_BASENAME?= $(patsubst %,%.zip,$(LBA_FUNCTION_NAME))
LBA_DEPLOYMENT_PACKAGE_DIR?= $(realpath ./zips)
LBA_DEPLOYMENT_PACKAGE_FILE?= $(LBA_DEPLOYMENT_PACKAGE_DIR)/$(LBA_DEPLOYMENT_PACKAGE_BASENAME)
LBA_DEPLOYMENT_PACKAGE_S3_BUCKET_NAME?= mybucket
LBA_DEPLOYMENT_PACKAGE_S3_BUCKET_URI?= $(if $(LBA_DEPLOYMENT_PACKAGE_S3_BUCKET_NAME),s3://$(LBA_DEPLOYMENT_PACKAGE_S3_BUCKET_NAME))
LBA_DEPLOYMENT_PACKAGE_S3_KEY?= out/file.zip
LBA_DEPLOYMENT_PACKAGE_S3_URI?= $(LBA_DEPLOYMENT_PACKAGE_S3_BUCKET_URI)/$(LBA_DEPLOYMENT_PACKAGE_S3_KEY)
# LBA_EVENT_FILE?= /tmp/invoke_event_payload.json
# LBA_EVENT_SOURCE_ARN?=
# LBA_EVENT_SOURCE_
# LBA_FUNCTION_CODE?= S3Bucket=bucket-name,S3Key=zip-file-object-key
# LBA_FUNCTION_DEAD_LETTER_CONFIG?=
# LBA_FUNCTION_DESCRIPTION?= 'A great Function!'
# LBA_FUNCTION_ENVIRONMENT?= Variables={ENVVAR1=string,ENVVAR2=string}
# LBA_FUNCTION_HANDLER?= CreateThumbnail.handler
# LBA_FUNCTION_KMS_ARN?=
LBA_FUNCTION_LOG_GROUP_NAME?=$(if $(LBA_FUNCTION_NAME),/aws/lambda/$(LBA_FUNCTION_NAME))
LBA_FUNCTION_MEMORY_SIZE?= 128
# LBA_FUNCTION_NAME?= CreateThumbnail
# LBA_FUNCTION_ROLE?= arn:aws:iam::374244366136:role/Pac001a-InvalidateOnWriteExecutionRole-1U8MR768KZFRI
# LBA_FUNCTION_RUNTIME?= python2.7
LBA_FUNCTION_RUNTIME?= nodejs4.3
LBA_FUNCTION_TIMEOUT?= 3
# LBA_FUNCTION_VERSION?=
# LBA_FUNCTION_VPC_CONFIG?=
# LBA_INVOCATION_CLIENT_CONTEXT?=
# LBA_INVOCATION_LOG_TYPE?= Tail
LBA_INVOCATION_OUTPUT_FILE?=/tmp/invoke_output.json
LBA_INVOCATION_PAYLOAD?= $(if $(LBA_EVENT_FILE),file://$(LBA_EVENT_FILE))
# LBA_INVOCATION_QUALIFIER?= Tail
# LBA_INVOCATION_TYPE?= DryRun
# LBA_INVOKE_ARGS?=
# LBA_PRINCIPAL?= sns.amazonaws.com
LBA_CODE_DIR?= $(realpath ./code)
# LBA_SOURCE_ARN?=
# LBA_STATEMENT_ID?=

__CODE= $(if $(LBA_FUCNTION_CODE),--code $(LBA_FUNCTION_CODE))
__DEAD_LETTER_CONFIG?= $(if $(LBA_FUNCTION_DEAD_LETTER_CONFIG),--dead-letter-config $(LBA_FUNCTION_DEAD_LETTER_CONFIG))
__DESCRIPTION= $(if $(LBA_FUNCTION_DESCRIPTION),--description $(LBA_FUNCTION_DESCRIPTION))
# __ENVIRONMENT= $(if $(LBA_FUNCTION_ENVIRONMENT),--environment $(LBA_FUNCTION_ENVIRONMENT))
__ENABLE= $(if $(filter true,$(LBA_EVENT_SOURCE_ENABLED)),--enabled,--no-enabled)
__EVENT_SOURCE_ARN= $(if $(LBA_EVENT_SOURCE_ARN),--event-source-arn $(LBA_EVENT_SOURCE_ARN))
__FUNCTION_NAME= $(if $(LBA_FUNCTION_NAME),--function-name $(LBA_FUNCTION_NAME))
__FUNCTION_VERSION= $(if $(LBA_FUNCTION_VERSION),--function-version $(LBA_FUNCTION_VERSION))
__HANDLER= $(if $(LBA_FUNCTION_HANDLER),--handler $(LBA_FUNCTION_HANDLER))
__INVOCATION_TYPE= $(if $(LBA_INVOCATION_TYPE),--invocation-type $(LBA_INVOCATION_TYPE))
__INVOKE_ARGS= $(if $(LBA_INVOKE_ARGS),--invoke-args $(LBA_INVOKE_ARGS))
__KMS_KEY_ARN?= $(if $(LBA_FUNCTION_KMS_KEY_ARN),--kms-key-arn $(LBA_FUNCTION_KMS_KEY_ARN))
__MEMORY_SIZE= $(if $(LBA_FUNCTION_MEMORY_SIZE),--memory-size $(LBA_FUNCTION_MEMORY_SIZE))
__NAME= $(if $(LBA_ALIAS_NAME),--name $(LBA_ALIAS_NAME))
__PAYLOAD= $(if $(LBA_INVOCATION_PAYLOAD),--payload $(LBA_INVOCATION_PAYLOAD))
__PRINCIPAL= $(if $(LBA_PRINCIPAL),--principal $(LBA_PRINCIPAL))
__RUNTIME= $(if $(LBA_FUNCTION_RUNTIME),--runtime $(LBA_FUNCTION_RUNTIME))
__ROLE= $(if $(LBA_FUNCTION_ROLE),--role $(LBA_FUNCTION_ROLE))
__S3_BUCKET= $(if $(LBA_DEPLOYMENT_PACKAGE_S3_BUCKET_NAME),--s3-bucket $(LBA_DEPLOYMENT_PACKAGE_S3_BUCKET_NAME))
__S3_KEY= $(if $(LBA_DEPLOYMENT_PACKAGE_S3_KEY),--s3-key $(LBA_DEPLOYMENT_PACKAGE_S3_KEY))
__SOURCE_ARN= $(if $(LBA_SOURCE_ARN),--source-arn $(LBA_SOURCE_ARN))
__STATEMENT_ID= $(if $(LBA_STATEMENT_ID),--statement-id $(LBA_STATEMENT_ID))
__TIMEOUT= $(if $(LBA_FUNCTION_TIMEOUT),--timeout $(LBA_FUNCTION_TIMEOUT))
__UUID= $(if $(LBA_EVENT_SOURCE_ID),--uuid $(LBA_EVENT_SOURCE_ID))
__VPC_CONFIG= $(if $(LBA_FUNCTION_VPC_CONFIG),--vpc-config $(LBA_FUNCTION_VPC_CONFIG))
__ZIP_FILE= $(if $(LBA_DEPLOYMENT_PACKAGE_FILE),--zip-file fileb://$(LBA_DEPLOYMENT_PACKAGE_FILE))

LBA_LIST_FUNCTIONS_QUERY_FILTER?=
LBA_VIEW_FUNCTION_FIELDS?=
LBA_VIEW_FUNCTIONS_FIELDS?=.[LastModified,FunctionName,Runtime,Description]

ZIP_BIN?=zip
__ZIP_OPTIONS+= -r9
ZIP?= $(__ZIP_ENVIRONMENT) $(ZIP_ENVIRONMENT) $(ZIP_BIN) $(__ZIP_OPTIONS) $(ZIP_OPTIONS)

#----------------------------------------------------------------------
# USAGE
#

_aws_install_software_dependencies :: _lba_install_software_dependencies
_lba_install_software_dependencies:
	sudo apt-get install --upgrade zip

_aws_view_account_limits :: _lba_view_account_limits

_aws_view_makefile_macros :: _lambda_view_makefile_macros
_lambda_view_makefile_macros ::

_aws_view_makefile_targets :: _lambda_view_makefile_targets
_lambda_view_makefile_targets ::
	@echo "AWS::LamBdA ($(_AWS_LAMBDA_MK_VERSION)) targets:"
	@echo "    _lba_add_permission                   - Allow an event source based on ARN"
	@echo "    _lba_create_alias                     - Create an alias to a lambda function"
	@echo "    _lba_create_deployment_package        - Create a project deployment package"
	@echo "    _lba_create_function                  - Create a lambda function"
	@echo "    _lba_delete_alias                     - Delete an alias to a lambda function"
	@echo "    _lba_delete_deployment_package        - Delete the created deployment package"
	@echo "    _lba_delete_event_source_mapping      - Delete the mapping between an event source and a lambda"
	@echo "    _lba_delete_function                  - Delete a lambda function"
	@echo "    _lba_invoke_function                  - Execute a lambda function"
	@echo "    _lba_invoke_async_function            - Execute a lambda function asynchronously"
	@echo "    _lba_list_local_deployment_packages   - List local deployment packages"
	@echo "    _lba_list_remote_deployment_packages  - List remote deployment packages"
	@echo "    _lba_copy_deployment_package          - Copy deployment package to S3"
	@echo "    _lba_update_function_code             - Update the code of a lambda function"
	@echo "    _lba_update_function_config           - Update the configuration of a lambda function"
	@echo "    _lba_view_account_settings            - Retrieve lambda limits information"
	@echo "    _lba_view_function_aliases            - View the aliases of a lambda function"
	@echo "    _lba_view_function_details            - View the details of a lambda function"
	@echo "    _lba_view_functions                   - View existing lambda function"
	@echo "    _lba_view_versions_by_function        - View availabe version of a lambda function"
	@echo

_aws_view_makefile_variables :: _lambda_view_makefile_variables
_lambda_view_makefile_variables ::
	@echo "AWS::LamBdA ($(_AWS_LAMBDA_MK_VERSION)) variables:"
	@echo "    LBA_ACTION=$(LBA_ACTION)"
	@echo "    LBA_ALIAS_NAME=$(LBA_ALIAS_NAME)"
	@echo "    LBA_ALIAS_NAMES=$(LBA_ALIAS_NAMES)"
	@echo "    LBA_CODE_DIR=$(LBA_CODE_DIR)"
	@echo "    LBA_DEPLOYMENT_PACKAGE_BASENAME=$(LBA_DEPLOYMENT_PACKAGE_BASENAME)"
	@echo "    LBA_DEPLOYMENT_PACKAGE_DIR=$(LBA_DEPLOYMENT_PACKAGE_DIR)"
	@echo "    LBA_DEPLOYMENT_PACKAGE_FILE=$(LBA_DEPLOYMENT_PACKAGE_FILE)"
	@echo "    LBA_DEPLOYMENT_PACKAGE_S3_BUCKET_NAME=$(LBA_DEPLOYMENT_PACKAGE_S3_BUCKET_NAME)"
	@echo "    LBA_DEPLOYMENT_PACKAGE_S3_KEY=$(LBA_DEPLOYMENT_PACKAGE_S3_KEY)"
	@echo "    LBA_EVENT_FILE=$(LBA_EVENT_FILE)"
	@echo "    LBA_EVENT_SOURCE_ID=$(LBA_EVENT_SOURCE_ID)"
	@echo "    LBA_EVENT_SOURCE_ENABLED=$(LBA_EVENT_SOURCE_ENABLED)"
	@echo "    LBA_FUNCTION_CODE=$(LBA_FUNCTION_CODE)"
	@echo "    LBA_FUNCTION_DESCRIPTION=$(LBA_FUNCTION_DESCRIPTION)"
	@echo "    LBA_FUNCTION_NAME=$(LBA_FUNCTION_NAME)"
	@echo "    LBA_FUNCTION_HANDLER=$(LBA_FUNCTION_HANDLER)"
	@echo "    LBA_FUNCTION_MEMORY_SIZE=$(LBA_FUNCTION_MEMORY_SIZE)"
	@echo "    LBA_FUNCTION_ROLE=$(LBA_FUNCTION_ROLE)"
	@echo "    LBA_FUNCTION_RUNTIME=$(LBA_FUNCTION_RUNTIME)"
	@echo "    LBA_FUNCTION_TIMEOUT=$(LBA_FUNCTION_TIMEOUT)"
	@echo "    LBA_FUNCTION_VERSION=$(LBA_FUNCTION_VERSION)"
	@echo "    LBA_INVOCATION_CLIENT_CONTEXT=$(LBA_INVOCATION_CLIENT_CONTEXT)"
	@echo "    LBA_INVOCATION_LOG_TYPE=$(LBA_INVOCATION_LOG_TYPE)"
	@echo "    LBA_INVOCATION_OUTPUT_FILE=$(LBA_INVOCATION_OUTPUT_FILE)"
	@echo "    LBA_INVOCATION_PAYLOAD=$(LBA_INVOCATION_PAYLOAD)"
	@echo "    LBA_INVOCATION_QUALIFIER=$(LBA_INVOCATION_QUALIFIER)"
	@echo "    LBA_INVOCATION_TYPE=$(LBA_INVOCATION_TYPE)"
	@echo "    LBA_INVOKE_ARGS=$(LBA_INVOKE_ARGS)"
	@echo "    LBA_FUNCTION_LOG_GROUP=$(LBA_FUNCTION_LOG_GROUP)"
	@echo "    LBA_STATEMENT_ID=$(LBA_STATEMENT_ID)"
	@echo "    LBA_VIEW_FUNCTIONS_FIELDS=$(LBA_VIEW_FUNCTIONS_FIELDS)"
	@echo "    ZIP=$(ZIP)"
	@echo

#----------------------------------------------------------------------
# PUBLIC_TARGETS
# 

_lba_add_permission:
	$(AWS) lambda add-permission $(__FUNCTION_NAME) $(__STATEMENT_ID) $(__ACTION) $(__PRINCIPAL) $(__SOURCE_ARN)

_lba_create_alias:
	@$(INFO) "$(AWS_LABEL)Creating a new alias for '$(LBA_FUNCTION_NAME)/$(LBA_FUNCTION_VERSION)' ..."; $(NORMAL)
	$(AWS) lambda create-alias $(__FUNCTION_NAME) $(__FUNCTION_VERSION)

_lba_create_event_source_mapping:
	@$(INFO) "$(AWS_LABEL)Creating a new event source mapping ..."; $(NORMAL)
	$(AWS) lambda create-event-source-mapping $(__ENABLED) $(__EVENT_SOURCE_ARN) $(__FUNCTION_NAME) $(__STARTING_POSITION) $(__STARTING_POSITION_TIMESTAMP)

_lba_create_function:
	@$(INFO) "$(AWS_LABEL)Creating the new lambda '$(LBA_FUNCTION_NAME)' ..."; $(NORMAL)
	$(AWS) lambda create-function $(__FUNCTION_NAME) $(__CODE) $(__DESCRIPTION) $(__HANDLER) $(__MEMORY_SIZE) $(__ROLE) $(__RUNTIME) $(__TIMEOUT) $(__ZIP_FILE)

_lba_create_deployment_package:
	@$(INFO) "$(LO_LABEL)Packaging deployment package for '$(LBA_FUNCTION_NAME)' ..."; $(NORMAL)
	mkdir -p $(LBA_DEPLOYMENT_PACKAGE_DIR)/
	cd $(LBA_CODE_DIR); $(ZIP) $(LBA_DEPLOYMENT_PACKAGE_DIR)/$(LBA_DEPLOYMENT_PACKAGE_BASENAME) *

_lba_delete_alias:
	@$(INFO) "$(AWS_LABEL)Deleting existing alias '$(LBA_ALIAS_NAME)' of '$(LBA_FUNCTION_NAME)' ..."; $(NORMAL)
	-$(AWS) lambda delete-alias $(__FUNCTION_NAME) $(__NAME)

_lba_delete_deployment_package:
	@$(INFO) "$(LO_LABEL)Deleting deployment package for lambda '$(LBA_FUNCTION_NAME)' ..."; $(NORMAL)
	-rm -rf $(LBA_DEPLOYMENT_PACKAGE_FILE)

_lba_delete_deployment_packages:
	@$(INFO) "$(LO_LABEL)Deleting existing packaged Executing lambda '$(LBA_FUNCTION_NAME)' ..."; $(NORMAL)
	-cd $(LBA_DEPLOYMENT_PACKAGE_DIR); rm -rf *

_lba_delete_event_source_mapping:
	@$(INFO) "$(AWS_LABEL)Deleting existing event source mapping '$(LBA_EVENT_SOURCE_MAPPING_ID)' ..."; $(NORMAL)
	-$(AWS) lambda delete-event-source-mapping $(__UUID)

_lba_delete_function:
	@$(INFO) "$(AWS_LABEL)Deleting existing lambda '$(LBA_FUNCTION_NAME)' ..."; $(NORMAL)
	-$(AWS) lambda delete-function $(__FUNCTION_NAME)

_lba_get_policy:
	@$(INFO) "$(AWS_LABEL)Fetching policy attached to lambda '$(LBA_FUNCTION_NAME)' ..."; $(NORMAL)
	$(AWS) lambda get-policy $(__FUNCTION_NAME) $(__QUALIFIER)

_lba_invoke_function:
	@$(INFO) "$(AWS_LABEL)Executing lambda '$(LBA_FUNCTION_NAME)' ..."; $(NORMAL)
	$(AWS) lambda invoke $(__FUNCTION_NAME) $(__INVOCATION_TYPE) $(__PAYLOAD) $(LBA_INVOCATION_OUTPUT_FILE)

_lba_invoke_async_function:
	@$(INFO) "$(AWS_LABEL)Executing asynchronously lambda '$(LBA_FUNCTION_NAME)' ..."; $(NORMAL)
	$(AWS) lambda invoke-async $(__FUNCTION_NAME) $(__INVOKE_ARGS)

_lba_list_local_deployment_packages:
	@$(INFO) "$(LO_LABEL)List local deployment packages ..."; $(NORMAL)
	-ls -la $(LBA_DEPLOYMENT_PACKAGE_DIR)/

_lba_list_remote_deployment_packages:
	@$(INFO) "$(AWS_LABEL)List remote deployment packages ..."; $(NORMAL)
	@$(ERROR) "NOT IMPLEMENTED YET!"; $(NORMAL)

_lba_copy_deployment_package:
	@$(INFO) "$(AWS_LABEL)Copying deployment packages to S3 ..."; $(NORMAL)
	$(AWS_S3) cp $(LBA_DEPLOYMENT_PACKAGE_FILE) $(LBA_DEPLOYMENT_PACKAGE_S3_URI)

_lba_update_function_code:
	@$(INFO) "$(AWS_LABEL)Updating code of lambda '$(LBA_FUNCTION_NAME)' ..."; $(NORMAL)
	$(AWS) lambda update-function-code $(__FUNCTION_NAME) $(__PUBLISH) $(__S3_BUCKET) $(__S3_KEY) $(__S3_OBJECT_VERSION) $(__ZIP_FILE) 

_lba_update_function_configuration:
	@$(INFO) "$(AWS_LABEL)Updating configuration of lambda '$(LBA_FUNCTION_NAME)' ..."; $(NORMAL)
	$(AWS) lambda update-function-configuration $(__FUNCTION_NAME) $(__DEAD_LETTER_CONFIG) $(__DESCRIPTION) $(__ENVIRONMENT) $(__HANDLER) $(__KMS_KEY_ARN) $(__MEMORY_SIZE) $(__ROLE) $(__RUNTIME) $(__TIMEOUT) $(__VPC_CONFIG)

_lba_view_account_limits:
	@$(INFO) "$(AWS_LABEL)Retrieving lambda limits information ..."; $(NORMAL)
	$(AWS) lambda get-account-settings

_lba_view_event_file:
	@$(INFO) "$(AWS_LABEL)Displaying event file ..."; $(NORMAL)
	@$(WARN) "Event file: $(LBA_EVENT_FILE)"; $(NORMAL)
	-@cat $(LBA_EVENT_FILE)

_lba_view_function_details:
	@$(INFO) "$(AWS_LABEL)View function List available lambdas ..."; $(NORMAL)
	$(AWS) lambda list-functions --query "Functions[?FunctionName=='$(LBA_FUNCTION_NAME)']$(LBA_VIEW_FUNCTION_FIELDS)"

_lba_view_functions:
	@$(INFO) "$(AWS_LABEL)List available lambdas ..."; $(NORMAL)
	$(AWS) lambda list-functions --query 'reverse(sort_by(Functions,&LastModified)[$(LBA_LIST_FUNCTIONS_QUERY_FILTER)]$(LBA_VIEW_FUNCTIONS_FIELDS))'

_lba_view_function_aliases:
	@$(INFO) "$(AWS_LABEL)List aliases of lambda '$(LBA_FUNCTION_NAME) ..."; $(NORMAL)
	$(AWS) lambda list-aliases $(__FUNCTION_NAME) $(__FUNCTION_VERSION)

_lba_view_invocation_output_file:
	@$(INFO) "$(LO_LABEL)Displaying invocation output file ..."; $(NORMAL)
	@$(WARN) "File: $(LBA_INVOCATION_OUTPUT_FILE)"; $(NORMAL)
	-@cat $(LBA_INVOCATION_OUTPUT_FILE)

_lba_view_versions_by_function:
	@$(INFO) "$(AWS_LABEL)List available versions of lambda '$(LBA_FUNCTION_NAME)' ..."; $(NORMAL)
	$(AWS) lambda list-versions-by-function $(__FUNCTION_NAME)
