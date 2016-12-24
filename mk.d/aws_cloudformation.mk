_AWS_CLOUDFORMATION_MK_VERSION=0.99.6

# CFN_CAPABILITIES?=
# CFN_LIST_STACKS_QUERY_FILTER?=?contains(StackName,'$(CFN_STACK_NAME)-')||StackName=='$(CFN_STACK_NAME)'
# CFN_LOGICAL_RESOURCE_ID?=Druid1Eth1NetworkInterface
# CFN_LOGICAL_RESOURCE_ID_STACK?=Logs001msi-InstancesStack-1CZN8U4WI9Q6H
# CFN_ON_FAILURE=ROLLBACK
# CFN_STACK_BASENAME?=StackBasename
CFN_STACK_EVENTS_SLICE?=0:40:1
# CFN_STACK_NAME?=
# CFN_STACK_NAMES?=
# CFN_STACK_PREFIX?=
CFN_STACK_ROLLBACKS?=enabled
# CFN_STACK_SUFFIX?=000a
# CFN_STACK_TAGS?=Key=string,Value=string
CFN_WATCH_INTERVAL?=5

#--- ENVIRONMENT
CFN_DIR?=cfn.d
CFN_STACK_DIR_TOKEN?=$(CFN_DIR) $(AWS_ACCOUNT) $(CFN_STACK_PREFIX) $(CFN_STACK_BASENAME) $(CFN_STACK_SUFFIX)
CFN_STACK_DIR?=$(subst $(SPACE),/,$(strip $(CFN_STACK_DIR_TOKEN)))
CFN_PATCH_DIR?=$(CFN_STACK_DIR)/patches
CFN_POLICY_DIR?=$(CFN_STACK_DIR)/policies
CFN_TEMPLATE_DIR?=$(CFN_STACK_DIR)/templates

CFN_STACK_LOCK_POLICY_FILE?=$(CFN_POLICY_DIR)/$(CFN_STACK_LOCK_POLICY)
CFN_STACK_UNLOCK_POLICY_FILE?=$(CFN_POLICY_DIR)/$(CFN_STACK_UNLOCK_POLICY)
CFN_MASTER_TEMPLATE_JSON?=cfn_master.json
# CFN_MASTER_TEMPLATE_YAML?=cfn_master.yml
CFN_MASTER_TEMPLATE_FILE?=$(CFN_STACK_DIR)/$(CFN_MASTER_TEMPLATE_JSON)
CFN_TEMPLATE_FILES?=$(wildcard $(CFN_TEMPLATE_DIR)/*)
CFN_STACK_NAME?=$(CFN_STACK_PREFIX)$(CFN_STACK_BASENAME)$(CFN_STACK_SUFFIX)
CFN_STACK_LOCK_POLICY?=deny_update_all.json
CFN_STACK_UNLOCK_POLICY?=allow_update_all.json

__CAPABILITIES= $(if $(CFN_CAPABILITIES),--capabilities $(CFN_CAPABILITIES))
__DISABLE_ROLLBACK= $(if $(filter disabled,$(CFN_STACK_ROLLBACKS)),--disable-rollback)
__ON_FAILURE= $(if $(CFN_ON_FAILURE),--on_failure $(CFN_ON_FAILURE))
__PUBLIC_KEY_MATERIAL= --public-key-material "$$(cat $(KEYPAIR_PUB))"
__STACK_NAME= --stack-name $(CFN_STACK_NAME)
__PARAMETERS= $(if $(CFN_PARAMETERS_KEYVALUE),--parameters $(CFN_PARAMETERS_KEYVALUE))
__TAGS= $(if $(CFN_STACK_TAGS),--tags $(CFN_STACK_TAGS))

# CFN_STACK_NAMES=$(shell $(AWS) cloudformation list-stacks $(__STACK_STATUS_FILTER) --query "StackSummaries[$(CFN_LIST_STACKS_QUERY_FILTER)].StackName" --output=text)
# CFN_NESTED_STACKS=$(filter-out $(CFN_STACK_NAME), $(CFN_STACK_NAMES))

#--- DISPLAY
CFN_VIEW_STACK_EVENTS_REASONS_FIELDS?=[LogicalResourceId,ResourceStatus,ResourceStatusReason]
CFN_VIEW_STACK_EVENTS_FIELDS?=[Timestamp,LogicalResourceId,ResourceStatus]
CFN_VIEW_STACK_EVENTS_FIELDS?=[Timestamp,LogicalResourceId,ResourceType,ResourceStatus,ResourceStatusReason]
CFN_VIEW_STACK_OUTPUTS_FIELDS?=[OutputKey,OutputValue]
CFN_VIEW_STACK_PARAMETERS_FIELDS?=[ParameterKey,ParameterValue]
CFN_VIEW_STACK_RESOURCES_FIELDS?=[LogicalResourceId,ResourceType]
CFN_VIEW_STACK_RESOURCES_FIELDS?=[LogicalResourceId,ResourceType,PhysicalResourceIds]
CFN_VIEW_STACK_STATUS_FIELDS?=[CreationTime,StackName,StackStatus]
CFN_VIEW_STACK_STATUS_FIELDS?=[CreationTime,StackName,TemplateDescription,StackStatus]

CLOUDFORMER?=$(CFN_ENVIRONMENT) cloudformer
# CLOUDFORMER_PARAMETERS?=

#--- MACROS

# Returns None if nothing to sort!
get_stack_names_NS=$(shell $(AWS) cloudformation list-stacks $(__STACK_STATUS_FILTER) --query "sort_by(StackSummaries[?contains(StackName,'$(1)-')||StackName=='$(1)'],$(2)).StackName" --output=text)

get_stack_names_N=$(shell $(AWS) cloudformation list-stacks $(__STACK_STATUS_FILTER) --query "StackSummaries[?contains(StackName,'$(1)-')||StackName=='$(1)'].StackName" --output=text)

get_nested_stack_names_N=$(shell $(AWS) cloudformation list-stacks $(__STACK_STATUS_FILTER) --query "StackSummaries[?contains(StackName,'$(CFN_STACK_NAME)-')].StackName" --output=text)

execute_stack_output_SOD=$(if $(1),$(shell $(AWS) cloudformation describe-stacks --stack-name $(1) --query "Stacks[0].Outputs[?OutputKey=='$(2)'].OutputValue" --output text),$(3))

get_stack_output_SOD=$(if $(1),$(shell $(AWS) cloudformation describe-stacks --stack-name $(1) --query "Stacks[0].Outputs[?OutputKey=='$(2)'].OutputValue" --output text),$(3))

get_physical_resource_id_SLD=$(if $(1),$(shell $(AWS) cloudformation describe-stack-resource --stack-name $(1) --logical-resource-id $(2) --query "StackResourceDetail.PhysicalResourceId" --output text),$(3))

get_stack_status_SD=$(if $(1),$(shell $(AWS) cloudformation describe-stacks --stack-name $(1) --query 'Stacks[].StackStatus' --output text),$(2))

#----------------------------------------------------------------------
# USAGE
#

_aws_view_makefile_macros :: _cfn_view_makefile_macros
_cfn_view_makefile_macros:
	@echo "AWS::CloudFormatioN ($(_AWS_CLOUDFORMATION_MK_VERSION)) macros:"
	@echo "    execute_stack_output_SOD                    - Execute an output from a stack"
	@echo "    get_physical_resource_id_SLD                - Get a physical resource id based on logical name in stack"
	@echo "    get_nested_stacks_names_N                   - Returns a list of nested stacks"
	@echo "    get_stack_output_SOD                        - Get a specific output from a stack"
	@echo "    get_stack_status_SD                         - Returns the status of a stack"
	@echo

_aws_view_makefile_targets :: _cfn_view_makefile_targets
_cfn_view_makefile_targets:
	@echo "AWS::CloudFormatioN ($(_AWS_CLOUDFORMATION_MK_VERSION)) targets:"
	@echo "    _cfn_build_templates            - Build the cfn template"
	@echo "    _cfn_cancel_stack_update        - Cancel an on-going stack update"
	@echo "    _cfn_create_stack               - Create the stack"
	@echo "    _cfn_delete_patches             - Delete the patches"
	@echo "    _cfn_delete_stack               - Delete the existing stack"
	@echo "    _cfn_lock_stack                 - Prevent update of the stack"
	@echo "    _cfn_unlock_stack               - Allow limited update of the stack"
	@echo "    _cfn_update_stack               - Update the existing stack"
	@echo "    _cfn_view_templates             - See the generated cfn templates"
	@echo "    _cfn_view_resource_details      - View the detailed description of a specific resource"
	@echo "    _cfn_view_stack_events          - View a snapshot of stack events"
	@echo "    _cfn_view_stack_events_reason   - View failures and other reason for events"
	@echo "    _cfn_view_stack_list            - View a list of all clouformation stacks"
	@echo "    _cfn_view_stack_outputs         - View the stack's outputs"
	@echo "    _cfn_view_stack_policy          - View the policy attached to the stack"
	@echo "    _cfn_view_stack_status          - View the status of the current stack"
	@echo "    _cfn_view_stack_parameters      - View the stack's parameters"
	@echo "    _cfn_view_stack_resources       - View resources deployed in the stack"
	@echo "    _cfn_view_stack_summary         - View the stack summary"
	@echo "    _cfn_watch_stack_events         - View stack events as they come"
	@echo 

_aws_view_makefile_variables :: _cfn_view_makefile_variables
_cfn_view_makefile_variables:
	@echo "AWS::CloudFormatioN ($(_AWS_CLOUDFORMATION_MK_VERSION)) variables:"
	@echo "    CFN_LIST_STACKS_QUERY_FILTER=$(CFN_LIST_STACKS_QUERY_FILTER)"
	@echo "    CFN_LOGICAL_RESOURCE_ID=$(CFN_LOGICAL_RESOURCE_ID)"
	@echo "    CFN_LOGICAL_RESOURCE_ID_STACK=$(CFN_LOGICAL_RESOURCE_ID_STACK)"
	@echo "    CFN_MASTER_TEMPLATE_FILE=$(CFN_MASTER_TEMPLATE_FILE)"
	@echo "    CFN_ON_FAILURE=$(CFN_ON_FAILURE)"
	@echo "    CFN_PATCH_DIR=$(CFN_PATCH_DIR)"
	@echo "    CFN_POLICY_DIR=$(CFN_POLICY_DIR)"
	@echo "    CFN_STACK_BASENAME=$(CFN_STACK_BASENAME)"
	@echo "    CFN_STACK_DIR=$(CFN_STACK_DIR)"
	@echo "    CFN_STACK_EVENTS_SLICE=$(CFN_STACK_EVENTS_SLICE)"
	@echo "    CFN_STACK_LOCK_POLICY=$(CFN_STACK_LOCK_POLICY)"
	@echo "    CFN_STACK_NAME=$(CFN_STACK_NAME)"
	@echo "    CFN_STACK_PREFIX=$(CFN_STACK_PREFIX)"
	@echo "    CFN_STACK_SUFFIX=$(CFN_STACK_SUFFIX)"
	@echo "    CFN_STACK_ROLLBACKS=$(CFN_STACK_ROLLBACKS)"
	@echo "    CFN_STACK_SUMMARY_FIELDS=$(CFN_STACK_SUMMARY_FIELDS)"
	@echo "    CFN_STACK_TAGS=$(CFN_STACK_TAGS)"
	@echo "    CFN_STACK_UNLOCK_POLICY=$(CFN_STACK_UNLOCK_POLICY)"
	@echo "    CFN_TEMPLATE_DIR=$(CFN_TEMPLATE_DIR)"
	@echo "    CFN_WATCH_INTERVAL=$(CFN_WATCH_INTERVAL)"
	@echo " C  CFN_STACK_NAMES=$(CFN_STACK_NAMES)"
	@echo " C  CLOUDFORMER=$(CLOUDFORMER)"
	@echo

#----------------------------------------------------------------------
# PRIVATE TARGETS
#

__cfn_view_stack_outputs:
	@echo -n "| "; $(INFO) "$(CFN_STACK_NAME)"; $(NORMAL)
	@$(AWS) cloudformation describe-stacks --query "Stacks[?StackName=='$(CFN_STACK_NAME)'].Outputs[].$(CFN_VIEW_STACK_OUTPUTS_FIELDS)" --output table | tail -n+4

#----------------------------------------------------------------------
# PUBLIC TARGETS
#

_cfn_delete_stack:
	@$(INFO) "$(AWS_LABEL)Deleting stack $(CFN_STACK_NAME) ..."; $(NORMAL)
	$(AWS) cloudformation delete-stack $(__STACK_NAME)

_cfn_list_stack_directory: _cfn_lo_list_stack_directory _cfn_s3_list_stack_directory

_cfn_list_patches: _cfn_lo_list_patches _cfn_s3_list_patches

_cfn_list_policies: _cfn_lo_list_policies _cfn_s3_list_policies

_cfn_list_templates: _cfn_lo_list_templates _cfn_s3_list_templates

_cfn_remove_patches: _cfn_lo_remove_patches _cfn_s3_remove_patches

_cfn_remove_policies: _cfn_lo_remove_policies _cfn_s3_remove_policies

_cfn_remove_stack_directory: _cfn_lo_remove_stack_directory _cfn_s3_remove_stack_directory

_cfn_remove_templates: _cfn_lo_remove_templates _cfn_s3_remove_templates

_cfn_sync_patches: _cfn_s3_sync_patches

_cfn_sync_policies: _cfn_s3_sync_policies

_cfn_sync_stack_directory: _cfn_s3_sync_stack_directory

_cfn_sync_templates: _cfn_s3_sync_templates

# All stacks but those which were correctly deleted!
CFN_STACK_STATUS_FILTERS=  CREATE_IN_PROGRESS CREATE_FAILED CREATE_COMPLETE
CFN_STACK_STATUS_FILTERS+= ROLLBACK_IN_PROGRESS ROLLBACK_FAILED ROLLBACK_COMPLETE
CFN_STACK_STATUS_FILTERS+= DELETE_IN_PROGRESS DELETE_FAILED
CFN_STACK_STATUS_FILTERS+= UPDATE_IN_PROGRESS UPDATE_COMPLETE_CLEANUP_IN_PROGRESS UPDATE_COMPLETE
CFN_STACK_STATUS_FILTERS+= UPDATE_ROLLBACK_IN_PROGRESS UPDATE_ROLLBACK_FAILED
CFN_STACK_STATUS_FILTERS+= UPDATE_ROLLBACK_COMPLETE_CLEANUP_IN_PROGRESS UPDATE_ROLLBACK_COMPLETE
__STACK_STATUS_FILTER= --stack-status-filter $(CFN_STACK_STATUS_FILTERS) 

_cfn_view_stack_status:
	@$(INFO) "$(AWS_LABEL)Summaries for master stack '$(CFN_STACK_NAME)'"; $(NORMAL)
	$(AWS) cloudformation list-stacks $(__STACK_STATUS_FILTER) --query "StackSummaries[$(CFN_LIST_STACKS_QUERY_FILTER)].$(CFN_VIEW_STACK_STATUS_FIELDS)"

_cfn_view_stack_events:
	$(foreach S, $(CFN_STACK_NAMES), \
		echo -n "| "; $(INFO) "$S"; $(NORMAL); \
		$(AWS) cloudformation describe-stack-events --stack-name $(S) --query 'StackEvents[$(CFN_STACK_EVENTS_SLICE)].$(CFN_VIEW_STACK_EVENTS_FIELDS)' --output table | tail -n+4; \
	)

ifeq ($(INTERACTIVE_MODE),true)

_cfn_watch_stack_events:
	watch -n $(CFN_WATCH_INTERVAL) --color "$(MAKE) -e --quiet _cfn_view_stack_status _cfn_view_stack_events"

else

_cfn_watch_stack_events:
	@$(WARN) -n "This stack operation can take a few minutes ..."
	@_MATCHED=0; while [ $${_MATCHED} -eq 0 ]; do \
		_STACK_STATUS=`$(AWS) cloudformation describe-stacks --stack-name $(CFN_STACK_NAME) --query 'Stacks[].StackStatus' --output text 2>/dev/null`; \
		if [ -z $${_STACK_STATUS} ]; then _STACK_STATUS=DELETE_COMPLETE; fi; \
		_MATCHED=`expr match "$${_STACK_STATUS}" ".*_COMPLETE$$" + match "$${_STACK_STATUS}" ".*_FAILED$$"`; \
		echo -n "." ; sleep 1 ; \
	done; $(INFO) "\n$(AWS_LABEL)The stack operation on $(CFN_STACK_NAME) completed with status : $${_STACK_STATUS}"; $(NORMAL)

endif

_cfn_view_stack_events_reasons:
	@$(foreach S, $(CFN_STACK_NAMES), \
		echo -n "|  "; $(INFO) "Stack: $S"; $(NORMAL); \
		$(AWS) cloudformation describe-stack-events --stack-name $(S) --query 'StackEvents[?ResourceStatusReason!=None].$(CFN_VIEW_STACK_EVENTS_REASONS_FIELDS) | [$(CFN_STACK_EVENTS_SLICE)]' --output table | tail -n+4; \
	)

_cfn_view_stack_policy:
	-$(AWS) cloudformation get-stack-policy $(__STACK_NAME) 

_cfn_cancel_stack_update:
	-$(AWS) cloudformation cancel-update-stack $(__STACK_NAME)

_cfn_view_resource_details:
	@# Great to see metadata attached to a resource!
	$(AWS) cloudformation describe-stack-resource --stack-name $(CFN_LOGICAL_RESOURCE_ID_STACK) --logical-resource-id $(CFN_LOGICAL_RESOURCE_ID)

_cfn_view_stack_outputs:
	@$(foreach N, $(CFN_STACK_NAMES), \
		make -s CFN_STACK_NAME=$(N) __cfn_view_stack_outputs; \
	)

_cfn_view_stack_summary:
	# Metadata too long!
	$(AWS) cloudformation get-template-summary $(__STACK_NAME) #  --output json | jq '.'

_cfn_view_stack_parameters:
	@$(foreach S, $(CFN_STACK_NAMES), \
		echo -n "| ";$(INFO) "Stack: $(S)"; $(NORMAL); \
		$(AWS) cloudformation describe-stacks --query 'Stacks[?StackName==`$(S)`].Parameters[].$(CFN_VIEW_STACK_PARAMETERS_FIELDS)' | tail -n+4; \
	)

_cfn_view_stack_resources:
	@$(foreach S, $(CFN_STACK_NAMES), \
		echo -n "| ";$(INFO) "Stack: $(S)"; $(NORMAL); \
		$(AWS) cloudformation list-stack-resources --stack-name $(S) --query 'StackResourceSummaries[*].$(CFN_VIEW_STACK_RESOURCES_FIELDS)' --output table | tail -n+4;\
	)

#----------------------------------------------------------------------
# SINGLE REGION AWS OPERATIONS (SHORT TEMPLATES)
#

__LOCK_STACK_POLICY_BODY= --stack-policy-body file://$(CFN_STACK_LOCK_POLICY_FILE)
__UNLOCK_STACK_POLICY_BODY= --stack-policy-body file://$(CFN_STACK_UNLOCK_POLICY_FILE)
__TEMPLATE_BODY= --template-body file://

_cfn_lo_build_templates: _cfn_lo_remove_templates 
	@$(INFO) "$(LO_LABEL)Generatiing the templates ..."; $(NORMAL)
	$(CLOUDFORMER) $(CLOUDFORMER_PARAMETERS)

_cfn_lo_remove_patches:
	@$(INFO) "$(LO_LABEL)Removing patches..."; $(NORMAL)
	rm -rf $(CFN_PATCH_DIR)/

_cfn_lo_remove_policies:
	@$(INFO) "$(LO_LABEL)Removing policies..."; $(NORMAL)
	rm -rf $(CFN_POLICY_DIR)/

_cfn_lo_remove_stack_directory:
	@$(INFO) "$(LO_LABEL)Removing stack directory..."; $(NORMAL)
	rm -rf $(CFN_STACK_DIR)/

_cfn_lo_remove_templates:
	@$(INFO) "$(LO_LABEL)Removing templates..."; $(NORMAL)
	rm -rf $(CFN_TEMPLATE_DIR)/

_cfn_lo_list_stack_directory:
	@$(INFO) "$(LO_LABEL)Listing stack directory..."; $(NORMAL)
	-ls -la $(CFN_STACK_DIR)/

_cfn_lo_list_patches:
	@$(INFO) "$(LO_LABEL)Listing patches..."; $(NORMAL)
	-ls -la $(CFN_PATCH_DIR)/

_cfn_lo_list_policies:
	@$(INFO) "$(LO_LABEL)Listing policies..."; $(NORMAL)
	-ls -la $(CFN_POLICY_DIR)/

_cfn_lo_list_templates:
	@$(INFO) "$(LO_LABEL)Listing templates..."; $(NORMAL)
	-ls -la $(CFN_TEMPLATE_DIR)/

_cfn_lo_view_templates:
	# Do not pipe those 2 so you can navigate in less!
	@$(foreach F, $(CFN_TEMPLATE_FILES), \
		jq --color-output '.' $(F) > /tmp/$(notdir $(F)); \
	)
	@$(foreach F, $(CFN_TEMPLATE_FILES), \
		less -r /tmp/$(notdir $(F)); \
	)

_cfn_lo_view_templates_metadata:
	@$(INFO) "$(LO_LABEL)Display template metadata..."; $(NORMAL)
	@$(foreach F, $(CFN_TEMPLATE_FILES), \
		$(INFO) " * Template: $(F)"; $(NORMAL); \
		jq --color-output '.Metadata' $(F); \
	)

_cfn_lo_view_templates_summaries:
	@$(INFO) "$(LO_LABEL)Display template summaries..."; $(NORMAL)
	@$(foreach F, $(CFN_TEMPLATE_FILES), \
		$(INFO) " * Template: $(F)"; $(NORMAL); \
		$(AWS) cloudformation get-template-summary $(__TEMPLATE_BODY)$(F); \
	)

_cfn_lo_validate_templates:
	@$(INFO) "$(LO_LABEL)Validating the templates ..."; $(NORMAL)
	@$(foreach F, $(CFN_TEMPLATE_FILES), \
		$(INFO) " * Template: $(F)"; $(NORMAL); \
		$(AWS) cloudformation validate-template $(__TEMPLATE_BODY)$(F) --output json; \
		sleep 2; \
	)

_cfn_lo_validate_account:
	@$(INFO) "$(LO_LABEL)Checking whether the template is using the external resources from the proper account"; $(NORMAL)
	@$(foreach F, $(CFN_TEMPLATE_FILES), \
		$(INFO) " * Template: $(F)"; $(NORMAL); \
		[ "$(shell jq -r  '. | .Metadata.AwsAccount' $(F))" -eq "$(AWS_ACCOUNT)" ] || exit 1 ;\
	)
	@echo "Ok, template built for this account! Continuing..."

_cfn_lo_create_stack:
	$(AWS) cloudformation create-stack $(__CAPABILITIES)  $(__DISABLE_ROLLBACK) $(__LOCK_STACK_POLICY_BODY) $(__ON_FAILURE) $(__PARAMETERS) $(__STACK_NAME) $(__TAGS) $(__TEMPLATE_BODY)$(CFN_MASTER_TEMPLATE_FILE)
	ls -al $(KEYPAIR_PEM)

_cfn_lo_lock_stack:
	@echo "$(AWS_LABEL)Disabling stack updates ..."
	$(AWS) cloudformation set-stack-policy $(__STACK_NAME) $(__LOCK_STACK_POLICY_BODY)

_cfn_lo_unlock_stack:
	@$(INFO) "$(AWS_LABEL)Enabling update of select stack resources ..."; $(NORMAL)
	$(AWS) cloudformation set-stack-policy $(__STACK_NAME) $(__UNLOCK_STACK_POLICY_BODY)

_cfn_lo_update_stack: 
	# Make sure that the other template are on S3 if using nested template!
	@$(WARN) "Make sure that the stack policy allows stack updates"; $(NORMAL)
	$(AWS) cloudformation update-stack $(__STACK_NAME) $(__PARAMETERS) $(__CAPABILITIES) $(TEMPLATE_BODY)$(CFN_MASTER_TEMPLATE_FILE)

#----------------------------------------------------------------------
# SINGLE REGION AWS OPERATIONS (LONG OR NESTED TEMPLATES)
#

S3_BUCKET_NAME?=configs.$(R53_HOSTED_ZONE)
S3_BUCKET?=s3://$(S3_BUCKET_NAME)
S3_STACK_DIR_KEY_TOKEN?=$(CFN_DIR) $(CFN_STACK_PREFIX) $(CFN_STACK_BASENAME) $(CFN_STACK_SUFFIX)
S3_STACK_DIR_KEY=$(subst $(SPACE),/,$(strip $(S3_STACK_DIR_KEY_TOKEN)))
S3_STACK_DIR=$(S3_BUCKET)/$(S3_STACK_DIR_KEY)
S3_TEMPLATE_DIR_KEY=$(S3_STACK_DIR_KEY)/templates
S3_TEMPLATE_DIR=$(S3_BUCKET)/$(S3_TEMPLATE_DIR_KEY)
S3_PATCH_DIR_KEY=$(S3_STACK_DIR_KEY)/patches
S3_PATCH_DIR=$(S3_BUCKET)/$(S3_PATCH_DIR_KEY)
S3_POLICY_DIR_KEY=$(S3_STACK_DIR_KEY)/policies
S3_POLICY_DIR=$(S3_BUCKET)/$(S3_POLICY_DIR_KEY)
S3_MASTER_TEMPLATE_KEY=$(S3_TEMPLATE_DIR_KEY)/$(CFN_MASTER_TEMPLATE_JSON)
__TEMPLATE_URL= --template-url https://s3.amazonaws.com/$(S3_BUCKET_NAME)/
GRANTS_READ= read=uri=http://acs.amazonaws.com/groups/global/AllUsers
# GRANTS_WRITE=
# GRANTS_FULL= full=emailaddress=aws.$(AWS_ACCOUNT)@menlosecurity.com
__GRANTS= --grants $(GRANTS_READ) $(GRANTS_WRITE) $(GRANTS_FULL)
S3_STACK_LOCK_POLICY_KEY=$(S3_POLICY_DIR_KEY)/$(CFN_STACK_LOCK_POLICY)
S3_STACK_UNLOCK_POLICY_KEY=$(S3_POLICY_DIR_KEY)/$(CFN_STACK_UNLOCK_POLICY)
__LOCK_STACK_POLICY_URL= --stack-policy-url http://s3.amazonaws.com/$(S3_BUCKET_NAME)/$(S3_STACK_LOCK_POLICY_KEY)
__UNLOCK_STACK_POLICY_URL= --stack-policy-url http://s3.amazonaws.com/$(S3_BUCKET_NAME)/$(S3_STACK_UNLOCK_POLICY_KEY)


_cfn_s3_list_stack_directory:
	@$(INFO) "$(AWS_LABEL)Listing stack directory in S3 bucket."; $(NORMAL)
	$(AWS_S3) ls $(S3_STACK_DIR)/

_cfn_s3_list_patches:
	@$(INFO) "$(AWS_LABEL)Listing patches in S3 bucket."; $(NORMAL)
	$(AWS_S3) ls $(S3_PATCH_DIR)/

_cfn_s3_list_policies:
	@$(INFO) "$(AWS_LABEL)Listing policies in S3 bucket."; $(NORMAL)
	$(AWS_S3) ls $(S3_POLICY_DIR)/

_cfn_s3_list_templates:
	@$(INFO) "$(AWS_LABEL)Listing templates in S3 bucket."; $(NORMAL)
	$(AWS_S3) ls $(S3_TEMPLATE_DIR)/

_cfn_s3_remove_patches:
	@$(INFO) "$(AWS_LABEL)Removing patches directory: $(S3_PATCH_DIR)"; $(NORMAL)
	-$(AWS_S3) ls $(S3_PATCH_DIR)
	-$(AWS_S3) ls $(S3_PATCH_DIR)/
	-$(AWS_S3) rm --recursive $(S3_PATCH_DIR)
	-$(AWS_S3) ls $(S3_PATCH_DIR)/

_cfn_s3_remove_policies:
	@$(INFO) "$(AWS_LABEL)Removing policy directory: $(S3_POLICY_DIR)"; $(NORMAL)
	-$(AWS_S3) ls $(S3_POLICY_DIR)
	-$(AWS_S3) ls $(S3_POLICY_DIR)/
	-$(AWS_S3) rm --recursive $(S3_POLICY_DIR)
	-$(AWS_S3) ls $(S3_POLICY_DIR)/

_cfn_s3_remove_templates:
	@$(INFO) "$(AWS_LABEL)Removing template directory: $(S3_TEMPLATE_DIR)"; $(NORMAL)
	-$(AWS_S3) ls $(S3_TEMPLATE_DIR)
	-$(AWS_S3) ls $(S3_TEMPLATE_DIR)/
	-$(AWS_S3) rm --recursive $(S3_TEMPLATE_DIR)
	-$(AWS_S3) ls $(S3_TEMPLATE_DIR)/

_cfn_s3_remove_stack_directory:
	@$(INFO) "$(AWS_LABEL)Removing stack directory: $(S3_STACK_DIR)"; $(NORMAL)
	$(AWS_S3) ls $(S3_BUCKET)/
	-$(AWS_S3) ls $(S3_STACK_DIR)
	-$(AWS_S3) ls $(S3_STACK_DIR)/
	-$(AWS_S3) rm --recursive $(S3_STACK_DIR)
	-$(AWS_S3) ls $(S3_STACK_DIR)/

_cfn_s3_sync_patches: _cfn_s3_remove_patches
	@$(INFO) "$(AWS_LABEL)Sync'ing $(S3_PATCH_DIR) ..."; $(NORMAL)
	$(AWS_S3) cp --recursive $(CFN_PATCH_DIR)/ $(S3_PATCH_DIR)/  $(__GRANTS)

_cfn_s3_sync_policies: _cfn_s3_remove_policies
	@$(INFO) "$(AWS_LABEL)Sync'ing $(S3_POLICY_DIR) ..."; $(NORMAL)
	$(AWS_S3) cp --recursive $(CFN_POLICY_DIR)/ $(S3_POLICY_DIR)/  $(__GRANTS)

_cfn_s3_sync_stack_directory: _cfn_s3_remove_stack_directory
	@$(INFO) "$(AWS_LABEL)Sync'ing $(S3_STACK_DIR) ..."; $(NORMAL)
	$(AWS_S3) cp --recursive $(CFN_STACK_DIR)/ $(S3_STACK_DIR)/  $(__GRANTS)

_cfn_s3_sync_templates: _cfn_s3_remove_templates
	@$(INFO) "$(AWS_LABEL)Sync'ing $(S3_TEMPLATE_DIR) ..."; $(NORMAL)
	$(AWS_S3) cp --recursive $(CFN_TEMPLATE_DIR)/ $(S3_TEMPLATE_DIR)/  $(__GRANTS)

S3_TEMPLATE_KEYS=$(addprefix $(S3_TEMPLATE_DIR_KEY)/, $(notdir $(CFN_TEMPLATE_FILES)))
_clouformaiton_s3_view_templates_summaries:
	$(foreach K, $(S3_TEMPLATE_KEYS), \
		$(INFO) " * Template: $(K)"; $(NORMAL); \
		$(AWS) cloudformation get-template-summary $(__TEMPLATE_URL)$(K); \
	)

_cfn_s3_validate_templates:
	@$(INFO) "$(AWS_LABEL)Validating templates stored on S3 ..."; $(NORMAL)
	@$(foreach K, $(S3_TEMPLATE_KEYS), \
		$(INFO) " * Template: $(K)"; $(NORMAL); \
		$(AWS) cloudformation validate-template $(__TEMPLATE_URL)$(K) --output json; \
		sleep 2; \
	)

_cfn_s3_create_stack:
	@$(INFO) "$(AWS_LABEL)Creating stack $(CFN_STACK_NAME) ..."; $(NORMAL)
	$(AWS) cloudformation create-stack $(__CAPABILITIES) $(__DISABLE_ROLLBACK) $(__LOCK_STACK_POLICY_URL) $(__PARAMETERS) $(__STACK_NAME) $(__TAGS) $(__TEMPLATE_URL)$(S3_MASTER_TEMPLATE_KEY)

_cfn_s3_update_stack: 
	@$(INFO) "$(AWS_LABEL)Updating stack $(CFN_STACK_NAME) ..."; $(NORMAL)
	@$(WARN) "Make sure that the stack policy allows stack updates"; $(NORMAL)
	$(AWS) cloudformation update-stack $(__CAPABILITIES) $(__PARAMETERS) $(__STACK_NAME) $(__TEMPLATE_URL)$(S3_MASTER_TEMPLATE_KEY)

_cfn_s3_lock_stack:
	@$(INFO) "$(AWS_LABEL)Locking the stack to prevent any updates ..."; $(NORMAL)
	$(AWS) cloudformation set-stack-policy $(__STACK_NAME) $(__LOCK_STACK_POLICY_URL)

_cfn_s3_unlock_stack:
	@$(INFO) "$(AWS_LABEL)Unlocking the stack '$(CFN_STACK_NAME)' ..."; $(NORMAL)
	$(AWS) cloudformation set-stack-policy $(__STACK_NAME) $(__UNLOCK_STACK_POLICY_URL)

#----------------------------------------------------------------------
# MULTI-REGIONS
# STACK MANIPULATION

ifneq (,$(AWS_REGIONS))

DESTINATION_REGION=$(patsubst _%,%,$<)

_cfn_create_stack_in = $(addprefix _cfn_create_stack_in_, $(AWS_REGIONS))
_cfn_create_stack_worldwide: $(_cfn_create_stack_in)
	$(MAKE) AWS_REGION=$(DESTINATION_REGION) create_stack
$(_cfn_create_stack_in): _cfn_create_stack_in_%: _% 

_cfn_delete_stack_in = $(addprefix _cfn_delete_stack_in_, $(AWS_REGIONS))
_cfn_delete_stack_worldwide: $(_cfn_delete_stack_in)
	$(MAKE) AWS_REGION=$(DESTINATION_REGION) delete_stack
$(_cfn_delete_stack_in): _cfn_delete_stack_in_%: _% 

_cfn_update_stack_in = $(addprefix _cfn_update_stack_in_, $(AWS_REGIONS))
$(_cfn_update_stack_in): _cfn_update_stack_in_%: _% 
	$(MAKE) AWS_REGION=$(DESTINATION_REGION) update_stack
_cfn_update_stack_worldwide: $(_cfn_update_stack_in)

_cfn_unlock_stack_in = $(addprefix _cfn_unlock_stack_in_, $(AWS_REGIONS))
$(_cfn_unlock_stack_in): _cfn_unlock_stack_in_%: _% 
	$(MAKE) AWS_REGION=$(DESTINATION_REGION) unlock_stack
_cfn_unlock_stack_worldwide: $(_cfn_unlock_stack_in)

endif

