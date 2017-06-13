_AWS_IAM_MK_VERSION=0.99.0

#----------------------------------------------------------------------
# USAGE
#

_aws_view_makefile_macros :: _iam_view_makefile_macros
_iam_view_makefile_macros ::

_aws_view_makefile_targets :: _iam_view_makefile_targets
_iam_view_makefile_targets ::

_aws_view_makefile_variables :: _iam_view_makefile_variables
_iam_view_makefile_variables ::

#----------------------------------------------------------------------
# PRIVATE TARGETS
#

-include $(MK_DIR)/aws_iam_role.mk
-include $(MK_DIR)/aws_iam_certificate.mk

#----------------------------------------------------------------------
# PUBLIC TARGETS
#

