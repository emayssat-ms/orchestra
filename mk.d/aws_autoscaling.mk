_AWS_AUTOSCALING_MK_VERSION=0.99.0

ASG_GROUP_NAME?=$(word 1, $(ASG_GROUP_NAMES))
ASG_DESIRED_CAPACITY?=1
# ASG_GROUP_NAMES?=$(ASG_GROUP_NAME)
ASG_HONOR_COOLDOWN?=true
# ASG_POLICY?=
# ASG_POLICIES?=

__AUTO_SCALING_GROUP_NAME= $(if $(ASG_GROUP_NAME),--auto-scaling-group-name $(ASG_GROUP_NAME))
__DESIRED_CAPACITY= $(if $(ASG_DESIRED_CAPACITY),--desired-capacity $(ASG_DESIRED_CAPACITY))
__HONOR_COOLDOWN= $(if $(filter true, $(ASG_HONOR_COOLDOWN)),--honor-cooldown,--no-honor-cooldown)

ASG_VIEW_SCALING_ACTIVITIES_FIELDS?= [StartTime,EndTime,Description]
ASG_VIEW_SCALING_ACTIVITIES_FIELDS?= [StartTime,EndTime,Description,Details,Progress]
ASG_VIEW_SCALING_DETAILS_FIELDS?= [Description,Details]
ASG_VIEW_SCALING_GROUPS_FIELDS?= {AutoScalingGroupName:AutoScalingGroupName,Desired:join(' ', [to_string(MinSize), '<=', to_string(DesiredCapacity), '<=', to_string(MaxSize)])}
ASG_VIEW_SCALING_POLICIES_FIELDS?= {PolicyName:PolicyName,PolicyType:PolicyType,ScalingAdjustment:join(' ', [to_string(ScalingAdjustment), AdjustmentType, 'with', to_string(Cooldown), 'Cooldown']), CloudwatchAlarms:Alarms[].AlarmName}

# ASG_DESCRIBE_GROUPS_QUERY_FILTER?= ?contains(AutoScalingGroupName, 'Foo')
# ASG_DESCRIBE_POLICIES_QUERY_FILTER?= ?contains(PolicyName, 'Foo')
# ASG_DESCRIBE_POLICY_ALARMS_QUERY_FILTER?= ?contains(AlarmName, 'Foo')
ASG_DESCRIBE_ACTIVITIES_QUERY_FILTER?= 0:20:1

#--- MACROS

get_scaling_group_names=$(call get_scaling_group_names_S,&AutoScalingGroupName)
get_scaling_group_names_S=$(shell $(AWS) autoscaling describe-auto-scaling-groups --query "sort_by(AutoScalingGroups[$(ASG_DESCRIBE_GROUPS_QUERY_FILTER)],$(1))[].AutoScalingGroupName" --output text)

get_scaling_group_name=$(word 1, $(call get_scaling_group_names_S,&AutoScalingGroupName))
get_scaling_group_name_I=$(word $(1), $(call get_scaling_group_names_S,&AutoScalingGroupName))
get_scaling_group_name_SI=$(word $(2), $(call get_scaling_group_names_S,$(1)))

get_scaling_policies_N=$(shell $(AWS) autoscaling describe-policies --auto-scaling-group-name $(1) --query "sort_by(ScalingPolicies,&PolicyName)[$(ASG_DESCRIBE_POLICIES_QUERY_FILTER)].PolicyName" --output text)
get_scaling_policy_NI=$(word $(2), $(call get_scaling_policies_N,$(1)))

get_scaling_policy_alarms_N=$(shell $(AWS) autoscaling describe-policies --query "ScalingPolicies[? PolicyName=='$(1)'].Alarms[$(ASG_DESCRIBE_POLICY_ALARMS_QUERY_FILTER)].AlarmName" --output text)
get_scaling_policy_alarm_NI=$(word $(2), $(call get_scaling_policy_alarms_N,$(1)))

#----------------------------------------------------------------------
# USAGE
#

_aws_view_makefile_macros :: _asg_view_makefile_macros
_asg_view_makefile_macros:
	@echo "AWS::AutoScalinG ($(_AWS_AUTOSCALING_MK_VERSION)) macros:"
	@echo "    get_scaling_group_name             - Returns 1st auto scaling group name"
	@echo "    get_scaling_group_name_I           - Returns 1 auto scaling group name (Index)"
	@echo "    get_scaling_group_name_SI          - Returns 1 auto scaling group name (SortBy, Index)"
	@echo "    get_scaling_group_names            - Returns auto scaling group names given a query filter"
	@echo "    get_scaling_group_names_S          - Returns auto scaling group names (SortBy)"
	@echo "    get_scaling_policies_N             - Returns scaling policies for a auto scale group (Name)"
	@echo "    get_scaling_policy_NI              - Returns 1 scaling policies for a scale group (Name, Index)"
	@echo "    get_scaling_policy_alarms_N        - Returns the alarms of a scaling policy (Name)"
	@echo "    get_scaling_policy_alarm_NI        - Returns 1 alarm of a scaling policy (Name, Index)"
	@echo

_aws_view_makefile_targets :: _asg_view_makefile_targets
_asg_view_makefile_targets:
	@echo "AWS::AutoScalinG ($(_AWS_AUTOSCALING_MK_VERSION)) targets:"
	@echo "    _asg_view_scaling_activities     - View auto scaling activities of a particular ASG"
	@echo "    _asg_view_account_limits         - View account limits related to auto-scaling"
	@echo

_aws_view_makefile_variables :: _asg_view_makefile_variables
_asg_view_makefile_variables:
	@echo "AWS::AutoScalinG ($(_AWS_AUTOSCALING_MK_VERSION)) variables:"
	@echo "    ASG_DESIRED_CAPACITY=$(ASG_DESIRED_CAPACITY)"
	@echo "    ASG_GROUP_NAME=$(ASG_GROUP_NAME)"
	@echo "    ASG_GROUP_NAMES=$(ASG_GROUP_NAMES)"
	@echo "    ASG_DESCRIBE_GROUPS_QUERY_FILTER=$(ASG_DESCRIBE_GROUPS_QUERY_FILTER)"
	@echo "    ASG_HONOR_COOLDOWN=$(ASG_HONOR_COOLDOWN)"
	@echo "    ASG_POLICY=$(ASG_POLICY)"
	@echo "    ASG_POLICIES=$(ASG_POLICIES)"
	@echo "    ASG_POLICIES_QUERY_FILTER=$(ASG_POLICIES_QUERY_FILTER)"
	@echo "    ASG_POLICY_ALARMS_QUERY_FILTER=$(ASG_POLICY_ALARMS_QUERY_FILTER)"
	@echo

#----------------------------------------------------------------------
# PRIVATE TARGETS
#

__asg_view_group_scaling_policies:
	@echo -n "| "; $(INFO) "$(ASG_GROUP_NAME)"; $(NORMAL)
	@$(AWS) autoscaling describe-policies $(__AUTO_SCALING_GROUP_NAME) --query "ScalingPolicies[].$(ASG_VIEW_SCALING_POLICIES_FIELDS)"

__asg_view_group_scaling_activities:
	echo -n "| "; $(INFO) "$(ASG_GROUP_NAME)"; $(NORMAL)
	$(AWS) autoscaling describe-scaling-activities $(__AUTO_SCALING_GROUP_NAME) --query "Activities[$(DESCRIBE_ACTIVITIES_QUERY_FILTER)].$(ASG_VIEW_SCALING_ACTIVITIES_FIELDS)" | tail -n+4

__asg_view_scaling_details:
	echo -n "| "; $(INFO) "$(ASG_GROUP_NAME)"; $(NORMAL); \
	$(AWS) autoscaling describe-scaling-activities --auto-scaling-group-name $(ASG_GROUP_NAME) --query "Activities[].$(ASG_VIEW_SCALING_DETAILS_FIELDS)" | tail -n+4

#----------------------------------------------------------------------
# PUBLIC TARGETS
#

_asg_set_desired_capacity:
	@$(INFO) "$(AWS_LABEL)Reseting desired capacity of $(ASG_GROUP_NAME) to $(ASG_DESIRED_CAPACITY)"; $(NORMAL)
	$(AWS) autoscaling set-desired-capacity $(__AUTO_SCALING_GROUP_NAME) $(__DESIRED_CAPACITY) $(__HONOR_COOLDOWN)

_aws_view_account_limits :: _asg_view_account_limits
_asg_view_account_limits:
	@$(INFO) "$(AWS_LABEL)Auto-scaling limits ..."; $(NORMAL)
	$(AWS) autoscaling describe-account-limits

_asg_view_scaling_groups:
	@$(INFO) "$(AWS_LABEL)Displaying scaling groups ..."; $(NORMAL)
	$(AWS) autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[$(ASG_DESCRIBE_GROUPS_QUERY_FILTER)].$(ASG_VIEW_SCALING_GROUPS_FIELDS)"

_asg_view_groups_scaling_policies:
	@#$(INFO) "$(AWS_LABEL)Fetching groups scaling policies ..."; $(NORMAL)
	@$(foreach N, $(ASG_GROUP_NAMES), \
		make -s ASG_GROUP_NAME=$(N) __asg_view_group_scaling_policies; \
	)

_asg_view_groups_scaling_activities: _asg_view_scaling_groups
	@#$(INFO) "$(AWS_LABEL)Fetching groups scaling activites ..."; $(NORMAL)
	@$(foreach N, $(ASG_GROUP_NAMES), \
		make -s ASG_GROUP_NAME=$(N) __asg_view_group_scaling_activities; \
	)

_asg_view_scaling_details:
	@$(foreach N, $(ASG_GROUP_NAMES), \
		make -s ASG_GROUP_NAME=$(N) __asg_view_scaling_details; \
	)
