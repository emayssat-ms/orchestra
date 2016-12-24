_AWS_EC2_INSTANCES_MK_VERSION=0.99.4

EC2_INSTANCE_ID?=$(word 1, $(EC2_INSTANCE_IDS))
# EC2_INSTANCE_IDS?=
# EC2_INSTANCE_TYPE?=t2.micro
# EC2_TERMINATE_INSTANCES_FIELDS?={InstanceId:InstanceId,PreviousState:PreviousState.Name,CurrentState:CurrentState.Name}
# EC2_TERMINATE_INSTANCES_QUERY_FILTER?=

EC2_TERMINATE_INSTANCES_FIELDS?=[InstanceId,PreviousState.Name,CurrentState.Name]
EC2_VIEW_INSTANCES_METADATA_FIELDS?=[Tags[?Key=='Name']|[0].Value,InstanceId,InstanceType,ImageId,Placement.AvailabilityZone,PublicIpAddress,State.Name]

#--- MACROS

get_instance_ids_V=$(call get_instance_ids_FV,tag:Name,$(1),&InstanceId)
get_instance_ids_FV=$(call get_instance_ids_FVS,$(1),$(2),&InstanceId)
get_instance_ids_FVS=$(shell $(AWS) ec2 describe-instances --filters "Name=$(1),Values=$(2)" "Name=instance-state-name,Values=running" --query 'sort_by(Reservations[].Instances[],$(3))[].InstanceId' --output text)

get_instance_id_V=$(word 1, $(call get_instance_ids_FVS,tag:Name,$(1),&InstanceId))
get_instance_id_FV=$(word 1, $(call get_instance_ids_FVS,$(1),$(2),&InstanceId))
get_instance_id_FVI=$(word $(3), $(call get_instance_ids_FVS,$(1),$(2),&InstanceId))
get_instance_id_FVSI=$(word $(4), $(call get_instance_ids_FVS,$(1),$(2),$(3)))

get_instance_metadata_V=$(call get_instance_metadata_FV,instance-id,$(1))
get_instance_metadata_FV=$(call get_instance_metadata_FVI,$(1),$(2),0)
get_instance_metadata_FVI=$(call get_instance_metadata_FVSI,$(1),$(2),&InstanceId,$(3))
get_instance_metadata_FVSI=$(shell $(AWS) ec2 describe-instances --filters "Name=$(1),Values=$(2)" "Name=instance-state-name,Values=running" --query 'sort_by(Reservations[].Instances[], $(3))[$(4)].$(EC2_VIEW_INSTANCES_METADATA_FIELDS)' --output text)

#----------------------------------------------------------------------
# USAGE
#

_ec2_view_makefile_macros :: _instance_view_makefile_macros
_instance_view_makefile_macros ::
	@echo "AWS::EC2::Instance ($(_AWS_EC2_INSTANCES_MK_VERSION)) macros:" 
	@echo "    get_instance_ids_{V|FV|FVS}             - Returns a list of instance ids (Filter,Value,SortBy)"
	@echo "    get_instance_id_{V|FV|FVI|FVSI}         - Returns 1 instance id (Filter,Value,SortBy,Index)"
	@echo "    get_instance_metadata_{V|FV|FVI|FVSI}   - Returns metadata for 1 instance (Filter,Value,SortBy,Index)"
	@echo

_ec2_view_makefile_targets :: _instance_view_makefile_targets
_instance_view_makefile_targets ::
	@echo "AWS::EC2::Instance ($(_AWS_EC2_INSTANCES_MK_VERSION)) targets:" 
	@echo "    _ec2_apply_termination_protection       - Applies termination protection to all INSTANCE_IDS"
	@echo "    _ec2_describe_instances                 - Describes all instances in a deployment"
	@echo "    _ec2_describe_instances_with_ami_id     - Displays information on instances with specific AMI_ID"
	@echo "    _ec2_describe_instances_with_key        - Displays information on instances with specific KEY"
	@echo "    _ec2_remove_termination_protection      - Removes termination protection of all INSTANCE_IDS"
	@echo

_ec2_view_makefile_variables :: _instance_view_makefile_variables
_instance_view_makefile_variables ::
	@echo "AWS::EC2::Instances ($(_AWS_EC2_INSTANCES_MK_VERSION)) variables:"
	@echo "    EC2_INSTANCE_ID=$(EC2_INSTANCE_ID)"
	@echo "    EC2_INSTANCE_IDS=$(EC2_INSTANCE_IDS)"
	@echo "    EC2_VIEW_INSTANCE_METADATA_FIELDS=$(EC2_VIEW_INSTANCE_METADATA_FIELDS)"
	@echo "    EC2_INSTANCE_TYPE=$(EC2_INSTANCE_TYPE)"
	@echo

#----------------------------------------------------------------------
# AWS OPERATIONS
#

_ec2_apply_termination_protection:
	# Not yet implemented for auto-scaled instance !!!

_ec2_remove_termination_protection:
	$(if $(strip $(EC2_INSTANCE_IDS)), \
		@$(INFO) "$(AWS_LABEL)Removing termination protection for $(EC2_INSTANCE_IDS) ..."; $(NORMAL) \
	,)
	$(foreach I, $(EC2_INSTANCE_IDS),  \
		$(AWS) ec2 modify-instance-attribute --instance-id $(I) --no-disable-api-termination; \
	)

_ec2_terminate_instances: INFO_MESSAGE?="$(AWS_LABEL)Terminating selected instances: $(EC2_INSTANCE_IDS) ..."
_ec2_terminate_instances:
	@$(INFO) "$(INFO_MESSAGE)"; $(NORMAL)
	$(if $(strip $(EC2_INSTANCE_IDS)), \
		$(AWS)  ec2 terminate-instances --instance-ids $(EC2_INSTANCE_IDS) --query "TerminatingInstances[$(TERMINATE_INSTANCES_QUERY_FILTER)].$(EC2_TERMINATE_INSTANCES_FIELDS)" ,\
		@$(WARN) "No instances found!"; $(NORMAL) \
	)

_ec2_view_instances_metadata: INFO_MESSAGE="$(AWS_LABEL)Describing instances in stack $(SSH_KEY_NAME)"
_ec2_view_instances_metadata: __FILTERS?= --filters "Name=instance-id,Values=$(subst $(SPACE),$(COMMA),$(strip $(EC2_INSTANCE_IDS)))" "Name=instance-state-name,Values=running"
_ec2_view_instances_metadata: __QUERY?= --query "Reservations[].Instances[].$(EC2_VIEW_INSTANCES_METADATA_FIELDS)"
_ec2_view_instances_metadata:
	@$(INFO) "$(INFO_MESSAGE)"; $(NORMAL)
	$(AWS) ec2 describe-instances $(__FILTERS) $(__QUERY)
