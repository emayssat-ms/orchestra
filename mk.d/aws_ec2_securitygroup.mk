_AWS_EC2_SECURITYGROUP_MK_VERSION=0.99.0

#--- INPUT PARAMETERS
# SGR_CIDR?=203.0.113.0/24
# SGR_DESCRIPTION=
# SGR_PREFIX?=$(IMAGE_PREFIX)
# SGR_IDS?=sg-a9c688cd
SGR_IDS?=$(SGROUP_ID)
# SGR_NAME?=
SGR_PROTOCOL?=tcp
SGR_PORT?=$(word 1, $(SGR_PORTS))
# SGR_PORTS?=22 80
# SGR_SOURCE_GROUP?=

SGR_ID?=$(word 1, $(SGR_IDS))


__CIDR?= --cidr $(SGR_CIDR)
__GROUP_ID?= --group-id $(SGR_ID)
__GROUP_IDS?= --group-ids $(SGR_IDS)
__GROUP_NAME?= --group-name $(SGR_NAME)
__PORT?= --port $(SGR_PORT)
__PROTOCOL?= --protocol $(SGR_PROTOCOL)

INGRESS_RULES_FIELDS?=[IpRanges[0].CidrIp,IpProtocol,FromPort,ToPort]

#----------------------------------------------------------------------
# USAGE
#

_aws_view_makefile_macros:: _securitygroup_view_makefile_macros
_securitygroup_view_makefile_macros:
	@echo "AWS::EC2::SecurityGroup ($(_AWS_EC2_SNAPSHOT_MK_VERSION)) macros:"
	@echo

_aws_view_makefile_targets :: _securitygroup_view_makefile_targets
_securitygroup_view_makefile_targets:
	@echo "AWS::EC2::SecurityGroup ($(_AWS_EC2_SECURITYGROUP_MK_VERSION)) targets:"
	@echo 

_aws_view_makefile_variables :: _securitygroup_view_makefile_variables
_securitygroup_view_makefile_variables:
	@echo "AWS::EC2::SecurityGroup ($(_AWS_EC2_SECURITYGROUP_MK_VERSION)) variables:"
	@echo "    SGR_DESCRIPTION=$(SGR_DESCRIPTION)"
	@echo "    SGR_ID=$(SGR_ID)"
	@echo "    SGR_IDS=$(SGR_IDS)"
	@echo "    SGR_NAME=$(SGR_NAME)"
	@echo "    SGR_PORT=$(SGR_PORT)"
	@echo "    SGR_PORTS=$(SGR_PORTS)"
	@echo

#----------------------------------------------------------------------
# AWS OPERATIONS
#

_securitygroup_view_ingress_rules:
	@$(INFO) "$(AWS_LABEL)View ingress rules for $(SGR_ID) ..."; $(NORMAL)
	$(AWS) ec2 describe-security-groups $(__GROUP_IDS) --query 'SecurityGroups[].IpPermissions[].$(INGRESS_RULES_FIELDS)'

_securitygroup_create_security_group:
	@$(INFO) "$(AWS_LABEL)Create security group '$(SGR_NAME)' ..."; $(NORMAL)
	$(AWS) ec2 create-security-group $(__GROUP_NAME) --description $(SGR_DESCRIPTION)

_securitygroup_authorize_ingress_port:
	@$(INFO) "$(AWS_LABEL)Authorizing '$(SGR_CIDR)' to connect to port(s) '$(SGR_PORT)' ..."; $(NORMAL)
	$(AWS) ec2 authorize-security-group-ingress $(__GROUP_ID) $(__PROTOCOL) $(__PORT) $(__CIDR)

export SGR_ID
export SGR_PROTOCOL
export SGR_CIDR
_securitygroup_authorize_ingress_ports:
	$(foreach P, $(SGR_PORTS), \
		$(MAKE) SGR_PORT=$(P) _securitygroup_authorize_ingress_port; \
	)
	
