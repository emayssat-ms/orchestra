_AWS_ELB_MK_VERSION=0.99.1

# Input parameters
ELB_LOAD_BALANCER_NAME?=

__LOAD_BALANCER_NAME= --load-balancer-name $(ELB_LOAD_BALANCER_NAME)

#----------------------------------------------------------------------
# Usage
#
_aws_view_makefile_macros :: _elb_view_makefile_macros
_elb_view_makefile_macros ::

_aws_view_makefile_targets :: _elb_view_makefile_targets
_elb_view_makefile_targets:
	@echo "AWS::ELB ($(_AWS_ELB_MK_VERSION)) targets:"
	@echo "     _elb_get_all_elbs                     - Show all the ELB attached to this account"
	@echo

_aws_view_makefile_variables :: _elb_view_makefile_variables
_elb_view_makefile_variables:
	@echo "AWS::ELB ($(_AWS_ELB_MK_VERSION)) variables:"
	@echo "    ELB_LOAD_BALANCER_NAME=$(ELB_LOAD_BALANCER_NAME)"
	@echo



#----------------------------------------------------------------------
# PRIVATE TARGETS
#
_elb_get_all_elbs:
	@$(INFO) "$(AWS_LABEL)Finding all load balancers ..."; $(NORMAL)
	$(AWS) elb describe-load-balancers

_elb_view_elb_attributes:
	$(AWS) elb describe-load-balancer-attributes $(__LOAD_BALANCER_NAME)

_elb_view_elb:
	$(AWS) elb describe-load-balancers $(__LOAD_BALANCER_NAME)
