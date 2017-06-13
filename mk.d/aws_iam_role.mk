_AWS_IAM_ROLE_MK_VERSION=0.99.0

# IAM_INSTANCE_PROFILE_NAME?=MyInstanceProfile
# IAM_ROLE_NAME?=MyRole
IAM_POLICY_DIR?=.
IAM_POLICY_NAME?= $(patsubst %.json,%,$(notdir $(IAM_POLICY_FILE)))

IAM_ROLE_NAME?=
IAM_ROLE_POLICY_FILE?=$(IAM_POLICY_DIR)/AssumeRolePolicy.json
IAM_ROLE_POLICY_DOCUMENT?=file://$(IAM_ROLE_POLICY_FILE)
IAM_POLICY_FILE?= $(firstword $(IAM_POLICY_FILES))
# IAM_POLICY_FILES?= $(IAM_POLICY_DIR)/MyPolicyName.json
IAM_POLICY_DOCUMENT?=file://$(IAM_POLICY_FILE)

__ASSUME_ROLE_POLICY_DOCUMENT?= --assume-role-policy-document $(IAM_ROLE_POLICY_DOCUMENT)
__INSTANCE_PROFILE_NAME?= --instance-profile-name $(IAM_INSTANCE_PROFILE_NAME)
__ROLE_NAME?= --role-name $(IAM_ROLE_NAME)
__POLICY_DOCUMENT?= --policy-document $(IAM_POLICY_DOCUMENT)
__POLICY_NAME?= --policy-name $(IAM_POLICY_NAME)

IAM_LIST_ROLES_QUERY_FILTER?=
IAM_VIEW_ROLE_FIELDS?=
IAM_VIEW_ROLES_FIELDS?=.[RoleName,Arn,CreateDate]

#--- MACROS
get_role_arn=$(call get_role_arn_N, $(IAM_ROLE_NAME))
get_role_arn_N=$(shell $(AWS) iam list-roles --query "Roles[?RoleName=='$(1)'].Arn" --output text)

#----------------------------------------------------------------------
# USAGE
#
_iam_view_makefile_macros :: _iam_role_view_makefile_macros
_iam_role_view_makefile_macros ::
	@echo "AWS::IAM::Role ($(_AWS_IAM_ROLE_MK_VERSION)) targets:"
	@echo "    get_role_arn                        - Get the ARN of a current role"
	@echo "    get_role_arn_N                      - Get the ARN of a role (Name)"
	@echo

_iam_view_makefile_targets :: _iam_role_view_makefile_targets
_iam_role_view_makefile_targets ::
	@echo "AWS::IAM::Role ($(_AWS_IAM_ROLE_MK_VERSION)) targets:"
	@echo "    _iam_add_role_to_instance_profile   - Add a role to an instance profile"
	@echo "    _iam_attach_policy                  - Attach a policy to an existing role"
	@echo "    _iam_attach_policies                - Attach policies to an existing role"
	@echo "    _iam_create_instance_profile        - Create an instance profile"
	@echo "    _iam_create_role        	           - Create a role based on a role policy document"
	@echo "    _iam_delete_role                    - Delete an existing role"
	@echo "    _iam_detach_policy                  - Detach a policy from a role"
	@echo "    _iam_detach_policies                - Detach policies from a role"
	@echo "    _iam_validate_policy_file           - Validate the JSON syntax of the policy file"
	@echo "    _iam_validate_policy_files          - Validate the JSON syntax of policy files"
	@echo "    _iam_validate_role_policy_file      - Validate the JSON syntax of the role policy file"
	@echo "    _iam_view_assumed_role              - Display assumed role"
	@echo "    _iam_view_roles                     - List all roles for this account"
	@echo "    _iam_view_role_policies             - List policies attached to a role"
	@echo "    _iam_view_role_policy_document      - Display the policy document attached to a role"
	@echo

_iam_view_makefile_variables :: _iam_role_view_makefile_variables
_iam_role_view_makefile_variables ::
	@echo "AWS::IAM::Role ($(_AWS_IAM_ROLE_MK_VERSION)) variables:"
	@echo "    IAM_INSTANCE_PROFILE_NAME=$(IAM_INSTANCE_PROFILE_NAME)"
	@echo "    IAM_ROLE_NAME=$(IAM_ROLE_NAME)"
	@echo "    IAM_ROLE_POLICY_DOCUMENT=$(IAM_ROLE_POLICY_DOCUMENT)"
	@echo "    IAM_POLICY_DOCUMENT=$(IAM_POLICY_DOCUMENT)"
	@echo "    IAM_POLICY_NAME=$(IAM_POLICY_NAME)"
	@echo

#----------------------------------------------------------------------
# PRIVATE TARGETS
# 

#----------------------------------------------------------------------
# PUBLIC TARGETS
# 

_iam_add_role_to_instance_profile:
	@$(INFO) "$(AWS_LABEL)Adding role '$(IAM_ROLE_NAME)' to instance profile '$(IAM_INSTANCE_PROFILE_NAME)' ..."; $(NORMAL)
	$(AWS) iam add-role-to-instance-profile $(__INSTANCE_PROFILE_NAME) $(__ROLE_NAME)

_iam_attach_policy:
	@$(INFO) "$(AWS_LABEL)Adding policy '$(IAM_POLICY_NAME)' to role '$(IAM_ROLE_NAME)' ..."; $(NORMAL)
	$(AWS) iam put-role-policy $(__ROLE_NAME) $(__POLICY_NAME) $(__POLICY_DOCUMENT)

_iam_attach_policies:
	$(foreach P, $(IAM_POLICY_NAMES), \
		$(MAKE) IAM_POLICY_NAME=$(P) _iam_attach_policy; \
	)

_iam_create_instance_profile:
	@$(INFO) "$(AWS_LABEL)Creating instance profile '$(IAM_INSTANCE_PROFILE_NAME)' ..."; $(NORMAL)
	$(AWS) iam create-instance-profile $(__INSTANCE_PROFILE_NAME)

_iam_create_role:
	@$(INFO) "$(AWS_LABEL)Creating role '$(IAM_ROLE_NAME)' ..."; $(NORMAL)
	$(AWS) iam create-role $(__ROLE_NAME) $(__ASSUME_ROLE_POLICY_DOCUMENT)

_iam_delete_role:
	@$(INFO) "$(AWS_LABEL)Deleting role '$(IAM_ROLE_NAME)' ..."; $(NORMAL)
	-$(AWS) iam delete-role $(__ROLE_NAME)

_iam_detach_policy:
	@$(INFO) "$(AWS_LABEL)Detaching policy '$(IAM_POLICY_NAME)' from role '$(IAM_ROLE_NAME)' ..."; $(NORMAL)
	-$(AWS) iam delete-role-policy $(__ROLE_NAME) $(__POLICY_NAME)

_iam_detach_policies:
	$(foreach P, $(IAM_POLICY_NAMES), \
		$(MAKE) IAM_POLICY_NAME=$(P) _iam_detach_policy; \
	)

_iam_validate_policy_file:
	@$(INFO) "$(LO_LABEL)Validating policy file '$(IAM_POLICY_FILE)' ..."; $(NORMAL)
	cat $(IAM_POLICY_FILE) | jq '.' 1>/dev/null

_iam_validate_policy_files:
	$(foreach P, $(IAM_POLICY_FILES), \
		$(MAKE) IAM_POLICY_FILE=$(P) _iam_validate_policy_file; \
	)

_iam_validate_role_policy_file:
	@$(INFO) "$(LO_LABEL)Validating the syntax of the role policy file '$(IAM_ROLE_POLICY_FILE)' ..."; $(NORMAL)
	cat $(IAM_ROLE_POLICY_FILE) | jq '.' 1>/dev/null

_iam_view_assume_role:
	@$(INFO) "$(AWS_LABEL)Listing assume roles ..."; $(NORMAL)
	$(AWS) iam get-role $(__ROLE_NAME) --query 'Role.AssumeRolePolicyDocument.Statement'

_iam_view_role:
	@$(INFO) "$(AWS_LABEL)Displaying information on role '$(IAM_ROLE_NAME)' ..."; $(NORMAL)
	$(AWS) iam list-roles --query "Roles[?RoleName=='$(IAM_ROLE_NAME)']$(IAM_VIEW_ROLE_FIELDS)"

_iam_view_roles:
	@$(INFO) "$(AWS_LABEL)Listing roles ..."; $(NORMAL)
	$(AWS) iam list-roles --query 'Roles[$(IAM_LIST_ROLE_QUERY_FILTER)]$(IAM_VIEW_ROLES_FIELDS)'

_iam_view_role_policies:
	@$(INFO) "$(AWS_LABEL)Listing policies of role '$(IAM_ROLE_NAME)' ..."; $(NORMAL)
	$(AWS) iam list-role-policies $(__ROLE_NAME) --query 'PolicyNames[*]'

_iam_view_role_policy_document:
	@$(INFO) "$(AWS_LABEL)Displaying document of policy '$(IAM_POLICY_NAME)' from role '$(IAM_ROLE_NAME)' ..."; $(NORMAL)
	$(AWS) iam get-role-policy $(__ROLE_NAME) $(__POLICY_NAME) --query 'PolicyDocument'
