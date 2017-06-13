_AWS_EC2_MK_VERSION=0.99.0

EC2_VIEW_ACCOUNT_LIMITS_FIELDS?=.[AttributeName,AttributeValues[0].AttributeValue]

#----------------------------------------------------------------------
# USAGE
#

_aws_view_makefile_macros :: _ec2_view_makefile_macros
_ec2_view_makefile_macros ::

_aws_view_makefile_targets :: _ec2_view_makefile_targets
_ec2_view_makefile_targets ::

_aws_view_makefile_variables :: _ec2_view_makefile_variables
_ec2_view_makefile_variables ::

#----------------------------------------------------------------------
# PRIVATE TARGETS
#

-include $(MK_DIR)/aws_ec2_image.mk
-include $(MK_DIR)/aws_ec2_instance.mk
-include $(MK_DIR)/aws_ec2_keypair.mk
-include $(MK_DIR)/aws_ec2_networkinterface.mk
-include $(MK_DIR)/aws_ec2_securitygroup.mk
-include $(MK_DIR)/aws_ec2_snapshot.mk
-include $(MK_DIR)/aws_ec2_vpc.mk

#----------------------------------------------------------------------
# PUBLIC TARGETS
#

_aws_view_account_limits :: _ec2_view_account_limits
_ec2_view_account_limits:
	@$(INFO) "$(AWS_LABEL)EC2 limits ..."; $(NORMAL)
	$(AWS) ec2 describe-account-attributes --query 'AccountAttributes[*]$(EC2_VIEW_ACCOUNT_LIMITS_FIELDS)'
