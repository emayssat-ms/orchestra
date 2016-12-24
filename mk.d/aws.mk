_AWS_MK_VERSION=0.99.3

AWS_LABEL?=[$(AWS_ACCOUNT) $(AWS_REGION)] #
LO_LABEL?=[local] #
AWS_OUTPUT?= table
# AWS_REGION?=us-west-1
# AWS_REGIONS?=ap-northest-1 ap-southeast-1 ap-southeast-2 eu-central-1 eu-west-1 us-east-1 us-west-1

ifeq ($(AWS_ACCOUNT),)
  ifeq ($(AWS_PROFILE), 0431)
    AWS_ACCOUNT=043132482622
  endif
  ifeq ($(AWS_PROFILE), 2381)
    AWS_ACCOUNT=238165537431
  endif
  ifeq ($(AWS_PROFILE), 3742)
    AWS_ACCOUNT=374244366136
  endif
  ifeq ($(AWS_PROFILE), 7009)
    AWS_ACCOUNT=700995487849
  endif
endif

ifneq ($(AWS_ACCOUNT),)
  AWS_ENVIRONMENT+=AWS_ACCOUNT=$(AWS_ACCOUNT)
endif

ifneq ($(AWS_OUTPUT),)
  __OUTPUT= --output $(AWS_OUTPUT)
  AWS_ENVIRONMENT+=AWS_OUTPUT=$(AWS_OUTPUT)
endif

ifneq ($(AWS_REGION),)
  __REGION= --region $(AWS_REGION)
  AWS_ENVIRONMENT+=AWS_REGION=$(AWS_REGION)
endif

ifneq ($(AWS_PROFILE),)
  __PROFILE= --profile $(AWS_PROFILE)
  AWS_ENVIRONMENT+=AWS_PROFILE=$(AWS_PROFILE)
endif

AWS=aws $(__OUTPUT) $(__REGION) $(__PROFILE)

MK_DIR?=.
-include $(MK_DIR)/aws_autoscaling.mk
-include $(MK_DIR)/aws_cloudformation.mk
-include $(MK_DIR)/aws_cloudwatch.mk
-include $(MK_DIR)/aws_ec2.mk
-include $(MK_DIR)/aws_elb.mk
-include $(MK_DIR)/aws_iam.mk
-include $(MK_DIR)/aws_lambda.mk
-include $(MK_DIR)/aws_logs.mk
-include $(MK_DIR)/aws_rds.mk
-include $(MK_DIR)/aws_route53.mk
-include $(MK_DIR)/aws_s3.mk

#----------------------------------------------------------------------
# USAGE
#

_view_makefile_macros :: _aws_view_makefile_macros
_aws_view_makefile_macros ::

_view_makefile_targets :: _aws_view_makefile_targets
_aws_view_makefile_targets ::
	@echo "AWS:: ($(_AWS_MK_VERSION)) targets:"
	@echo "    _aws_view_makefile_variables        - Display variables for debugging"
	@echo "    _aws_view_account_limits            - Display account limits"
	@echo

_view_makefile_variables :: _aws_view_makefile_variables
_aws_view_makefile_variables ::
	@echo "AWS:: ($(_AWS_MK_VERSION)) variables:"
	@echo "    AWS=$(AWS)"
	@echo "    AWS_ACCOUNT=$(AWS_ACCOUNT)"
	@echo "    AWS_ENVIRONMENT=$(AWS_ENVIRONMENT)"
	@echo "    AWS_LABEL=$(AWS_LABEL)"
	@echo "    AWS_OUTPUT=$(AWS_OUTPUT)"
	@echo "    AWS_PROFILE=$(AWS_PROFILE)"
	@echo "    AWS_REGION=$(AWS_REGION)"
	@echo "    AWS_REGIONS=$(AWS_REGIONS)"
	@echo

_install :: _aws_install
_aws_install ::
	sudo pip install awscli

#----------------------------------------------------------------------
# PRIVATE TARGETS
#

_aws_view_account_limits ::
