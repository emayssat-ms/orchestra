_AWS_EC2_SECURITYGROUP_MK_VERSION=0.99.0

#--- INPUT PARAMETERS
# SGR_CIDR?=203.0.113.0/24
# SGR_DESCRIPTION=
# SGR_PREFIX?=$(IMAGE_PREFIX)
SGR_ID?=$(firstword $(SGR_IDS))
# SGR_IDS?=sg-a9c688cd sg-a9c688cd
# SGR_NAME?=
SGR_PROTOCOL?=tcp
SGR_PORT?=$(firstword $(SGR_PORTS))
# SGR_PORTS?=22 80
# SGR_SOURCE_GROUP?=

__CIDR?= --cidr $(SGR_CIDR)
__GROUP_ID?= --group-id $(SGR_ID)
__GROUP_IDS?= --group-ids $(SGR_IDS)
__GROUP_NAME?= --group-name $(SGR_NAME)
__PORT?= --port $(SGR_PORT)
__PROTOCOL?= --protocol $(SGR_PROTOCOL)

SGR_VIEW_GROUP_INGRESS_RULES_FIELDS?=.[IpRanges[0].CidrIp,IpProtocol,FromPort,ToPort]
SGR_VIEW_GROUPS_INGRESS_RULES_FIELDS?=.[IpRanges[0].CidrIp,IpProtocol,FromPort,ToPort]
SGR_VIEW_GROUPS_METADATA_FIELDS?=.[GroupId,GroupName]

get_security_group_ids_V=$(call get_security_group_ids_FV, group-name, $(1))
get_security_group_ids_FV=$(call get_security_group_ids_FVS, $(1), $(2), &GroupName)
get_security_group_ids_FVS=$(call get_security_group_ids_FVSI, $(1), $(2), $(3),)
get_security_group_ids_FVSI=$(shell $(AWS) ec2 describe-security-groups --filters "Name=$(strip $(1)),Values=$(strip $(2))" --query 'sort_by(SecurityGroups[], $(3))[$(4)].GroupId' --output text)

get_security_group_id_V=$(word 1, call get_security_group_ids_V, $(1))
get_security_group_id_FV=$(word 1, $(call get_security_group_ids_FV, $(1), $(2))
get_security_group_id_FVI=$(word $(3), $(call get_security_group_ids_FV, $(1), $(2))
get_security_group_id_FVSI=$(word $(4), $(call get_security_group_ids_FVS, $(1), $(2), $(3),))

#----------------------------------------------------------------------
# USAGE
#

_aws_view_makefile_macros:: _securitygroup_view_makefile_macros
_securitygroup_view_makefile_macros:
	@echo "AWS::EC2::SecurityGroup ($(_AWS_EC2_SNAPSHOT_MK_VERSION)) macros:"
	@echo "    get_security_group_ids_{V|FV|FVI|FVSI}      - Get security group ids"
	@echo "    get_security_group_id_{V|FV|FVI|FVSI}       - Get 1 security group id"
	@echo

_aws_view_makefile_targets :: _securitygroup_view_makefile_targets
_securitygroup_view_makefile_targets:
	@echo "AWS::EC2::SecurityGroup ($(_AWS_EC2_SECURITYGROUP_MK_VERSION)) targets:"
	@echo "    _securitygroup_authorize_ingress_port       - Authorize 1 ingress port for a given CIDR"
	@echo "    _securitygroup_authorize_ingress_ports      - Authorize many ingress ports for a given CIDR"
	@echo "    _securitygroup_create_security_group        - Create a security group"
	@echo "    _securitygroup_revoke_ingress_port          - Revoke 1 ingress port for a given CIDR"
	@echo "    _securitygroup_revoke_ingress_ports         - Revoke many ingress ports for a given CIDR"
	@echo "    _securitygroup_view_ingress_rules           - Display ingress rules of a security group"
	@echo "    _securitygroup_view_groups_metadata         - Return metadata on provided group ids"
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

_securitygroup_authorize_ingress_port:
	@$(INFO) "$(AWS_LABEL)Authorizing '$(SGR_CIDR)' to connect to port(s) '$(SGR_PORT)' ..."; $(NORMAL)
	$(AWS) ec2 authorize-security-group-ingress $(__GROUP_ID) $(__PROTOCOL) $(__PORT) $(__CIDR)

_securitygroup_create_security_group:
	@$(INFO) "$(AWS_LABEL)Create security group '$(SGR_NAME)' ..."; $(NORMAL)
	$(AWS) ec2 create-security-group $(__GROUP_NAME) --description $(SGR_DESCRIPTION)

_securitygroup_revoke_ingress_port:
	@$(INFO) "$(AWS_LABEL)Revoking '$(SGR_CIDR)' access to port(s) '$(SGR_PORT)' on $(SGR_ID) ..."; $(NORMAL)
	-$(AWS) ec2 revoke-security-group-ingress $(__GROUP_ID) $(__PROTOCOL) $(__PORT) $(__CIDR)

export SGR_ID
export SGR_PROTOCOL
export SGR_CIDR
_securitygroup_authorize_ingress_ports:
	$(foreach P, $(SGR_PORTS), \
		$(MAKE) SGR_PORT=$(P) _securitygroup_authorize_ingress_port; \
	)
	
_securitygroup_revoke_ingress_ports:
	$(foreach P, $(SGR_PORTS), \
		$(MAKE) SGR_PORT=$(P) _securitygroup_revoke_ingress_port; \
	)
	
_securitygroup_view_group_ingress_rules:
	@$(INFO) "$(AWS_LABEL)View ingress rules for $(SGR_ID) ..."; $(NORMAL)
	$(AWS) ec2 describe-security-groups --group-ids $(SGR_ID) --query 'SecurityGroups[].IpPermissions[]$(SGR_VIEW_GROUP_INGRESS_RULES_FIELDS)'

_securitygroup_view_groups_ingress_rules:
	@$(INFO) "$(AWS_LABEL)View ingress rules for $(SGR_IDS) ..."; $(NORMAL)
	$(AWS) ec2 describe-security-groups $(__GROUP_IDS) --query 'SecurityGroups[].IpPermissions[]$(SGR_VIEW_GROUPS_INGRESS_RULES_FIELDS)'

_securitygroup_view_groups_metadata: __FILTER= --filter "Name=group-id,Values=$(subst $(SPACE),$(COMMA),$(strip $(SGR_IDS)))"
_securitygroup_view_groups_metadata: __QUERY?= --query "sort_by(SecurityGroups,&GroupName)[]$(SGR_VIEW_GROUPS_METADATA_FIELDS)"
_securitygroup_view_groups_metadata:
	@$(INFO) "$(AWS_LABEL)View metadata for security groups: $(SGR_IDS) ..."; $(NORMAL)
	$(AWS) ec2 describe-security-groups $(__FILTER) $(__QUERY)
