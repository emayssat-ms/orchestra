_AWS_MK_VERSION=0.99.3

# AWS_ACCOUNT_ID?=123456789012
AWS_CONFIG_FILE=~/.aws/config
AWS_CREDENTIALS_FILE=~/.aws/credentials
# AWS_ENVIRONMENT?=
AWS_LABEL?=[$(strip $(AWS_PROFILE) $(AWS_ACCOUNT_ID) $(AWS_REGION))] #
LO_LABEL?=[local] #
# AWS_OPTIONS?= --profile 1234
# AWS_OUTPUT?= table
# AWS_REGION?=us-west-1
# AWS_REGIONS?=ap-northest-1 ap-southeast-1 ap-southeast-2 eu-central-1 eu-west-1 us-east-1 us-west-1

__OUTPUT= $(if $(AWS_OUTPUT),--output $(AWS_OUTPUT),--output table)
__REGION= $(if $(AWS_REGION),--region $(AWS_REGION))
__PROFILE= $(if $(AWS_PROFILE),--profile $(AWS_PROFILE))

__AWS_OPTIONS+= $(__OUTPUT)
__AWS_OPTIONS+= $(__PROFILE)
__AWS_OPTIONS+= $(__REGION)

AWS?=$(__AWS_ENVIRONMENT) $(AWS_ENVIRONMENT) aws $(__AWS_OPTIONS) $(AWS_OPTIONS)

#--- MACROS

get_aws_account=$(call get_aws_account_P, $(AWS_PROFILE))
get_aws_account_P=$(shell $(AWS) --profile $(1) ec2 describe-security-groups --query 'SecurityGroups[0].OwnerId' --output text)
# get_aws_account=$(shell $(AWS) sts get-caller-identity --query 'Account' --output text)

get_aws_access_key_id=$(call get_aws_access_key_id_P, $(AWS_PROFILE))
get_aws_access_key_id_P=$(call get_aws_access_key_id_FP, $(AWS_CREDENTIALS_FILE), $(1))
get_aws_access_key_id_FP=$(shell ini_get $(1) -S $(2) -P aws_access_key_id)

get_aws_secret_access_key=$(call get_aws_secret_access_key_P, $(AWS_PROFILE))
get_aws_secret_access_key_P=$(call get_aws_secret_access_key_FP, $(AWS_CREDENTIALS_FILE), $(1))
get_aws_secret_access_key_FP=$(shell ini_get $(1) -S $(2) -P aws_secret_access_key)

#----------------------------------------------------------------------
# USAGE
#

_install_framework_dependencies :: _aws_install_framework_dependencies
_aws_install_framework_dependencies ::
	sudo pip install awscli

_view_makefile_macros :: _aws_view_makefile_macros
_aws_view_makefile_macros ::
	@echo "AWS:: ($(_AWS_MK_VERSION)) targets:"
	@echo "    get_aws_access_key_id                  - Get the current AWS_ACCESS_KEY_ID"
	@echo "    get_aws_access_key_id_{P|FP}           - Get an AWS_ACCESS_KEY_ID (File, Profile)"
	@echo "    get_aws_account                        - Get the AWS account for the current AWS profile"
	@echo "    get_aws_account_P                      - Get an AWS account given an AWS profile"
	@echo "    get_aws_secret_access_key              - Get the current AWS_SECRET_ACCESS_KEY"
	@echo "    get_aws_secret_access_key_{P|FP}       - Get an AWS_SECRET_ACCESS_KEY (File, Profile)"
	@echo


_view_makefile_targets :: _aws_view_makefile_targets
_aws_view_makefile_targets ::
	@echo "AWS:: ($(_AWS_MK_VERSION)) targets:"
	@echo "    _aws_view_makefile_variables           - Display variables for debugging"
	@echo "    _aws_view_account_limits               - Display account limits"
	@echo

_view_makefile_variables :: _aws_view_makefile_variables
_aws_view_makefile_variables ::
	@echo "AWS:: ($(_AWS_MK_VERSION)) variables:"
	@echo "    AWS=$(AWS)"
	@echo "    AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID)"
	@echo "    AWS_ACCOUNT_ID=$(AWS_ACCOUNT_ID)"
	@echo "    AWS_CONFIG_FILE=$(AWS_CONFIG_FILE)"
	@echo "    AWS_CREDENTIALS_FILE=$(AWS_CREDENTIALS_FILE)"
	@echo "    AWS_LABEL=$(AWS_LABEL)"
	@echo "    AWS_OUTPUT=$(AWS_OUTPUT)"
	@echo "    AWS_PROFILE=$(AWS_PROFILE)"
	@echo "    AWS_REGION=$(AWS_REGION)"
	@echo "    AWS_REGIONS=$(AWS_REGIONS)"
	@echo "    AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY)"
	@echo

#----------------------------------------------------------------------
# PRIVATE TARGETS
#


#----------------------------------------------------------------------
# PUBLIC TARGETS
#

MK_DIR?=.
-include $(MK_DIR)/aws_acm.mk
-include $(MK_DIR)/aws_autoscaling.mk
-include $(MK_DIR)/aws_cloudformation.mk
-include $(MK_DIR)/aws_cloudwatch.mk
-include $(MK_DIR)/aws_ec2.mk
-include $(MK_DIR)/aws_es.mk
-include $(MK_DIR)/aws_elb.mk
-include $(MK_DIR)/aws_iam.mk
-include $(MK_DIR)/aws_lambda.mk
-include $(MK_DIR)/aws_logs.mk
-include $(MK_DIR)/aws_rds.mk
-include $(MK_DIR)/aws_route53.mk
-include $(MK_DIR)/aws_s3.mk

_aws_view_account_limits ::
