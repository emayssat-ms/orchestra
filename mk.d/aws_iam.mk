_AWS_IAM_MK_VERSION=0.99.0

# IAM_INSTANCE_PROFILE_NAME?=MyInstanceProfile
# IAM_ROLE_NAME?=MyRole
IAM_POLICY_DIR?=.
# IAM_POLICY_NAME?=MyPolicy

IAM_ROLE_POLICY_FILE?=$(IAM_POLICY_DIR)/AssumeRolePolicy.json
IAM_ROLE_POLICY_DOCUMENT?=file://$(IAM_ROLE_POLICY_FILE)
IAM_POLICY_FILE?=$(IAM_POLICY_DIR)/$(IAM_POLICY_NAME).json
IAM_POLICY_DOCUMENT?=file://$(IAM_POLICY_FILE)

__ASSUME_ROLE_POLICY_DOCUMENT?= --assume-role-policy-document $(IAM_ROLE_POLICY_DOCUMENT)
__INSTANCE_PROFILE_NAME?= --instance-profile-name $(IAM_INSTANCE_PROFILE_NAME)
__ROLE_NAME?= --role-name $(IAM_ROLE_NAME)
__POLICY_DOCUMENT?= --policy-document $(IAM_POLICY_DOCUMENT)
__POLICY_NAME?= --policy-name $(IAM_POLICY_NAME)

#----------------------------------------------------------------------
# USAGE
#
_aws_view_makefile_macros :: _iam_view_makefile_macros
_iam_view_makefile_macros ::

_aws_view_makefile_targets :: _iam_view_makefile_targets
_iam_view_makefile_targets ::
	@echo "AWS::IAM ($(_AWS_IAM_MK_VERSION)) targets:"
	@echo "    _iam_add_role_to_instance_profile   - Adds a role to an instance profile"
	@echo "    _iam_create_instance_profile        - Creates an instance profile"
	@echo "    _iam_create_role        	           - Creates a role"
	@echo "    _iam_delete_role                    - Deletes an existing role"
	@echo "    _iam_delete_role_policy             - Deletes a policy attached to a role"
	@echo "    _iam_view_assumed_role              - Displays assumed role"
	@echo "    _iam_view_roles                     - Lists all roles for this account"
	@echo "    _iam_view_role_policies             - Lists policies attached to a role"
	@echo "    _iam_view_role_policy_document      - Displays the policy document attached to a role"
	@echo

_aws_view_makefile_variables :: _iam_view_makefile_variables
_iam_view_makefile_variables ::
	@echo "AWS::IAM ($(_AWS_IAM_MK_VERSION)) variables:"
	@echo "    IAM_INSTANCE_PROFILE_NAME=$(IAM_INSTANCE_PROFILE_NAME)"
	@echo "    IAM_ROLE_NAME=$(IAM_ROLE_NAME)"
	@echo "    IAM_ROLE_POLICY_DOCUMENT=$(IAM_ROLE_POLICY_DOCUMENT)"
	@echo "    IAM_POLICY_DOCUMENT=$(IAM_POLICY_DOCUMENT)"
	@echo "    IAM_POLICY_NAME=$(IAM_POLICY_NAME)"
	@echo

#----------------------------------------------------------------------
# OPERATIONS 
# 

_iam_add_role_to_instance_profile:
	@$(INFO) "$(AWS_LABEL)Adding role '$(IAM_ROLE_NAME)' to instance profile '$(IAM_INSTANCE_PROFILE_NAME)' ..."; $(NORMAL)
	$(AWS) iam add-role-to-instance-profile $(__INSTANCE_PROFILE_NAME) $(__ROLE_NAME)

_iam_create_instance_profile:
	@$(INFO) "$(AWS_LABEL)Creating instance profile '$(IAM_INSTANCE_PROFILE_NAME)' ..."; $(NORMAL)
	$(AWS) iam create-instance-profile $(__INSTANCE_PROFILE_NAME)

_iam_create_role:
	@$(INFO) "$(AWS_LABEL)Creating role '$(IAM_ROLE_NAME)' ..."; $(NORMAL)
	$(AWS) iam create-role $(__ROLE_NAME) $(__ASSUME_ROLE_POLICY_DOCUMENT)

_iam_delete_role:
	@$(INFO) "$(AWS_LABEL)Deleting role '$(IAM_ROLE_NAME)' ..."; $(NORMAL)
	$(AWS) iam delete-role $(__ROLE_NAME)

_iam_delete_role_policy:
	@$(INFO) "$(AWS_LABEL)Deleting policy '$(IAM_POLICY_NAME)' from role '$(IAM_ROLE_NAME)' ..."; $(NORMAL)
	$(AWS) iam delete-role-policy $(__ROLE_NAME) $(__POLICY_NAME)

_iam_put_role_policies:
	@$(INFO) "$(AWS_LABEL)Adding policy '$(IAM_POLICY_NAME)' to role '$(IAM_ROLE_NAME)' ..."; $(NORMAL)
	$(AWS) iam put-role-policy $(__ROLE_NAME) $(__POLICY_NAME) $(__POLICY_DOCUMENT)

_iam_validate_policy:
	@$(INFO) "$(LO_LABEL)Validating policy document '$(IAM_POLICY_FILE)' ..."; $(NORMAL)
	cat $(IAM_POLICY_FILE) | jq '.' 1>/dev/null

_iam_view_assume_role:
	@$(INFO) "$(AWS_LABEL)Listing assume roles ..."; $(NORMAL)
	$(AWS) iam get-role $(__ROLE_NAME) --query 'Role.AssumeRolePolicyDocument.Statement'

_iam_view_roles:
	@$(INFO) "$(AWS_LABEL)Listing roles ..."; $(NORMAL)
	$(AWS) iam list-roles --query 'Roles[*].[RoleName]'

_iam_view_role_policies:
	@$(INFO) "$(AWS_LABEL)Listing policies of role '$(IAM_ROLE_NAME)' ..."; $(NORMAL)
	$(AWS) iam list-role-policies $(__ROLE_NAME) --query 'PolicyNames[*]'

_iam_view_role_policy_document:
	@$(INFO) "$(AWS_LABEL)Displaying document of policy '$(IAM_POLICY_NAME)' from role '$(IAM_ROLE_NAME)' ..."; $(NORMAL)
	$(AWS) iam get-role-policy $(__ROLE_NAME) $(__POLICY_NAME) --query 'PolicyDocument'
