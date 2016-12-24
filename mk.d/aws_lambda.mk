_AWS_LAMBDA_MK_VERSION=0.99.0

LAMBDA_ACTION?= lambda:InvokeFunction
# LAMBDA_DESCRIPTION?=
# LAMBDA_FUNCTION_NAME?=
# LAMBDA_HANDLER?=
# LAMBDA_INVOKE_ARGS?=
LAMBDA_MEMORY_SIZE?= 128
# LAMBDA_PRINCIPAL?= sns.amazonaws.com
LAMBDA_RUNTIME?= python2.7
# LAMBDA_SOURCE_ARN?=
# LAMBDA_STATEMENT_ID?=
LAMBDA_TIMEOUT?= 60
LAMBDA_ZIP_DIR?= zips
# LAMBDA_ZIP_FILE?= fileb://path/file.zip

__DESCRIPTION= --description $(LAMBDA_DESCRIPTION)
__FUNCTION_NAME= --function-name $(LAMBDA_FUNCTION_NAME)
__HANDLER= --handler $(LAMBDA_HANDLER)
__INVOKE_ARGS= --invoke-args $(LAMBDA_INVOKE_ARGS)
__MEMORY_SIZE= --memory-size $(LAMBDA_MEMORY_SIZE)
__PRINCIPAL= --principal $(LAMBDA_PRINCIPAL)
__RUNTIME= --runtime $(LAMBDA_RUNTIME)
__ROLE= --role $(LAMBDA_ROLE)
__SOURCE_ARN= --source-arn $(LAMBDA_SOURCE_ARN)
__STATEMENT_ID= --statement-id $(LAMBDA_STATEMENT_ID)
__ZIP_FILE= --zip-file $(LAMBDA_ZIP_FILE)

#----------------------------------------------------------------------
# USAGE
#
_aws_view_makefile_macros :: _lambda_view_makefile_macros
_lambda_view_makefile_macros ::

_aws_view_makefile_targets :: _lambda_view_makefile_targets
_lambda_view_makefile_targets ::
	@echo "AWS::Lambda ($(_AWS_LAMBDA_MK_VERSION)) targets:"
	@echo "    _lambda_add_permission             - Allow an event source based on ARN"
	@echo "    _lambda_create_function            - Create a lambda function"
	@echo "    _lambda_delete_function            - Delete a lambda function"
	@echo "    _lambda_invoke_function            - Delete a lambda function"
	@echo "    _lambda_view_makefile_variables    - Display variables for debugging"
	@echo "    _lambda_zip_handlers               - Zipped files with handlers"
	@echo

_aws_view_makefile_variables :: _lambda_view_makefile_variables
_lambda_view_makefile_variables ::
	@echo "AWS::Lambda ($(_AWS_LAMBDA_MK_VERSION)) variables:"
	@echo "    LAMBDA_ACTION=$(LAMBDA_ACTION)"
	@echo "    LAMBDA_DESCRIPTION=$(LAMBDA_DESCRIPTION)"
	@echo "    LAMBDA_FUNCTION_NAME=$(LAMBDA_FUNCTION_NAME)"
	@echo "    LAMBDA_HANDLER=$(LAMBDA_HANDLER)"
	@echo "    LAMBDA_INVOKE_ARGS=$(LAMBDA_INVOKE_ARGS)"
	@echo "    LAMBDA_MEMORY_SIZE=$(LAMBDA_MEMORY_SIZE)"
	@echo "    LAMBDA_ROLE=$(LAMBDA_ROLE)"
	@echo "    LAMBDA_RUNTIME=$(LAMBDA_RUNTIME)"
	@echo "    LAMBDA_STATEMENT_ID=$(LAMBDA_STATEMENT_ID)"
	@echo "    LAMBDA_TIMEOUT=$(LAMBDA_TIMEOUT)"
	@echo "    LAMBDA_ZIP_DIR=$(LAMBDA_ZIP_DIR)"
	@echo "    LAMBDA_ZIP_FILE=$(LAMBDA_ZIP_FILE)"
	@echo

#----------------------------------------------------------------------
# OPERATIONS 
# 

_lambda_add_permission:
	$(AWS) lambda add-permission $(__FUNCTION_NAME) $(__STATEMENT_ID) $(__ACTION) $(__PRINCIPAL) $(__SOURCE_ARN)

_lambda_create_function:
	$(AWS) lambda create-function $(__FUNCTION_NAME) $(__RUNTIME) $(__ROLE) $(__HANDLER) $(__DESCRIPTION) $(__TIMEOUT) $(__MEMORY_SIZE) $(__ZIP_FILE)

_lambda_delete_function:
	$(AWS) lambda delete-function $(__FUNCTION_NAME)

_lamdba_invoke_function:
	$(AWS) lambda invoke-async $(__FUNCTION_NAME) $(__INVOKE_ARGS)

_lambda_zip_handlers: ;
