_AWS_ACM_MK_VERSION=0.99.1

ACM_CERTIFICATE_FILEPATH?=example.crt
ACM_PRIVATE_KEY_FILEPATH?=example.key
ACM_CERTIFICATE_CHAIN_FILEPATH?=example-bundle.crt

__CERTIFICATE?= file://$(ACM_CERTIFICATE_FILEPATH)
__PRIVATE_KEY?= file://$(ACM_PRIVATE_KEY_FILEPATH)
__CERTIFICATE_CHAIN?= file://$(ACM_CERTIFICATE_CHAIN_FILEPATH)

#----------------------------------------------------------------------
# Usage
#

_aws_view_makefile_macros :: _acm_view_makefile_macros
_acm_view_makefile_macros ::

_aws_view_makefile_targets :: _acm_view_makefile_targets
_acm_view_makefile_targets:
	@echo "AWS::ACM ($(_AWS_ACM_MK_VERSION)) targets:"
	@echo "     _acm_import_certificate               - Import a certificate to ACM"
	@echo "     _acm_list_certificates                - List ACM-managed certificates"
	@echo

_aws_view_makefile_variables :: _acm_view_makefile_variables
_acm_view_makefile_variables:
	@echo "AWS::ACM ($(_AWS_ACM_MK_VERSION)) variables:"
	@echo "    ACM_CERTIFICATE_CHAIN_FILEPATH=$(ACM_CERTIFICATE_CHAIN_FILEPATH)"
	@echo "    ACM_CERTIFICATE_FILEPATH=$(ACM_CERTIFICATE_FILEPATH)"
	@echo "    ACM_PRIVATE_KEY_FILEPATH=$(ACM_PRIVATE_KEY_FILEPATH)"
	@echo

#----------------------------------------------------------------------
# PRIVATE TARGETS
#

_acm_list_certificates:
	@$(INFO) "$(AWS_LABEL)List ACM-managed certificates ..."; $(NORMAL)
	$(AWS) acm list-certificates

_acm_import_certificate:
	$(AWS) acm import-certificate $(__CERTIFICATE) $(__PRIVATE_KEY) $(__CERTIFICATE_CHAIN)
