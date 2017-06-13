_AWS_IAM_CERTIFICATE_MK_VERSION=0.99.0

# IAM_CERTIFICATE_NAME?= star-surfcrew-com
# IAM_CERTIFICATE_BODY?=
# IAM_CERTIFICATE_PRIVATE_KEY?=

__SERVER_CERTIFICATE_NAME?= --server-certificate-name $(IAM_CERTIFICATE_NAME)
__CERTIFICATE_BODY?= --certificate-body $(IAM_CERTIFICATE_BODY)
__CERTIFICATE_CHAIN?= --certificate-chain $(IAM_CERTIFICATE_CHAIN)
__PRIVATE_KEY_FILE?= --private-key $(IAM_CERTIFICATE_PRIVATE_KEY)

#--- MACROS
get_certificate_arn=$(call get_certificate_arn_N, $(IAM_CERTIFICATE_NAME))
get_certificate_arn_N=$(shell $(AWS) iam get-server-certificate --server-certificate-name $(1) --query 'ServerCertificate.ServerCertificateMetadata.Arn' --output text)

#----------------------------------------------------------------------
# USAGE
#
_iam_view_makefile_macros :: _iam_certificate_view_makefile_macros
_iam_certificate_view_makefile_macros ::
	@echo "AWS::IAM::Certificate ($(_AWS_IAM_CERTIFICATE_MK_VERSION)) targets:"
	@echo "    get_certificate_arn                 - Get the ARN of a current certificate"
	@echo "    get_certificate_arn_N               - Get the ARN of a certificate (Name)"
	@echo

_iam_view_makefile_targets :: _iam_certificate_view_makefile_targets
_iam_certificate_view_makefile_targets ::
	@echo "AWS::IAM::Certificate ($(_AWS_IAM_CERTIFICATE_MK_VERSION)) targets:"
	@echo "    _iam_get_server_certificate          - Display PEM-encoded certificate, CA bundle, metadata"
	@echo "    _iam_upload_server_certificate       - Upload a certificate to IAM"
	@echo "    _iam_view_certificate_metadata       - Display the metadata of the current certificate"
	@echo

_iam_view_makefile_variables :: _iam_certificate_view_makefile_variables
_iam_certificate_view_makefile_variables ::
	@echo "AWS::IAM::Certificate ($(_AWS_IAM_CERTIFICATE_MK_VERSION)) variables:"
	@echo "    IAM_CERTIFICATE_BODY=$(IAM_CERTIFICATE_BODY)"
	@echo "    IAM_CERTIFICATE_CHAIN=$(IAM_CERTIFICATE_CHAIN)"
	@echo "    IAM_CERTIFICATE_NAME=$(IAM_CERTIFICATE_NAME)"
	@echo "    IAM_CERTIFICATE_PRIVATE_KEY=$(IAM_CERTIFICATE_PRIVATE_KEY)"
	@echo

#----------------------------------------------------------------------
# PRIVATE TARGETS
# 

#----------------------------------------------------------------------
# PUBLIC TARGETS
# 

_iam_get_server_certificate:
	@$(INFO) "Display content of certificate '$(IAM_CERTIFICATE_NAME)' ..."; $(NORMAL)
	$(AWS) iam get-server-certificate $(__SERVER_CERTIFICATE_NAME) --output json

_iam_view_certificate_metadata:
	@$(INFO) "Display the metadata of certificate '$(IAM_CERTIFICATE_NAME)' ..."; $(NORMAL)
	$(AWS) iam get-server-certificate $(__SERVER_CERTIFICATE_NAME) --query 'ServerCertificate.ServerCertificateMetadata'

_iam_upload_server_certificate:
	@$(INFO) "Upload certificate '$(IAM_CERTIFICATE_NAME)' ..."; $(NORMAL)
	$(AWS) iam upload-server-certificate $(__SERVER_CERTIFICATE_NAME) $(__CERTIFICATE_BODY) $(__CERTIFICATE_CHAIN) $(__PRIVATE_KEY)
