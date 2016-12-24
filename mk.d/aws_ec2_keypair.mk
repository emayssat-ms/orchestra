_AWS_EC2_KEYPAIR_MK_VERSION=0.99.1

#--- INPUT PARAMETERS
EC2_KEY_NAME?=$(SSH_KEY_NAME)
EC2_KEYPAIR_DIR?=$(SSH_KEYPAIR_DIR)
EC2_KEYPAIR_PEM?=$(EC2_KEYPAIR_DIR)/$(EC2_KEY_NAME).pem
EC2_KEYPAIR_PUB?=$(EC2_KEYPAIR_PEM).pub

#--- MAKEFILE PARAMETERS
__PUBLIC_KEY_MATERIAL= --public-key-material "$$(cat $(EC2_KEYPAIR_PUB))"
__KEY_NAME= --key-name $(EC2_KEY_NAME)

#----------------------------------------------------------------------
# USAGE
#

_ec2_usage :: _keypair_usage
_keypair_usage ::
	@echo "AWS::EC2::Keypair ($(_AWS_EC2_KEYPAIR_MK_VERSION)) targets:"
	@echo "    _ec2_create_keypair                     - Create a keypair on AWS"
	@echo "    _ec2_create_local_keypair               - Create a keypair on AWS"
	@echo "    _ec2_delete_keypair                     - Delete an existing keypair"
	@echo "    _ec2_import_local_key                   - Import a keypair"
	@echo "    _ec2_ls_key                             - List key files"
	@echo

_ec2_view_makefile_variables :: _keypair_view_makefile_variables
_keypair_view_makefile_variables ::
	@echo "AWS::EC2::Keypair ($(_AWS_EC2_KEYPAIR_MK_VERSION)) variables:"
	@echo "    EC2_KEY_NAME=$(EC2_KEY_NAME)"
	@echo "    EC2_KEYPAIR_DIR=$(EC2_KEYPAIR_DIR)"
	@echo " C  EC2_KEYPAIR_PEM=$(EC2_KEYPAIR_PEM)"
	@echo " C  EC2_KEYPAIR_PUB=$(EC2_KEYPAIR_PUB)"
	@echo

#----------------------------------------------------------------------
# AWS OPERATIONS
#

#--- KEY management
_ec2_create_keypair:
	mkdir -vp $(dir $(KEYPAIR_PEM))
	[ -e $(EC2_KEYPAIR_PEM) ] || $(AWS) ec2 create-key-pair $(__KEY_NAME) --query 'KeyMaterial' --output text > $(EC2_KEYPAIR_PEM); cat $(EC2_KEYPAIR_PEM)
	chmod 600 $(EC2_KEYPAIR_PEM)
	ls -al $(EC2_KEYPAIR_PEM)

_ec2_import_keypair:
	@$(INFO) "$(AWS_LABEL)Importing the ssh key if not already done ..."; $(NORMAL)
	-$(AWS) ec2 import-key-pair $(__KEY_NAME) $(__PUBLIC_KEY_MATERIAL) 

_ec2_delete_keypair:
	@$(INFO) "$(AWS_LABEL)Deleting existing keypair $(EC2_KEY_NAME) ..."; $(NORMAL)
	$(AWS) ec2 delete-key-pair $(__KEY_NAME) 
