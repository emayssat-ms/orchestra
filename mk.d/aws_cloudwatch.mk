_AWS_CLOUDWATCH_MK_VERSION=0.99.3

CWH_ACTION_ENABLED?=false
# CWH_ACTION_PREFIX?=
# CWH_ALARM_ACTIONS?= arn:aws:sns:us-east-1:111122223333:MyTopic
# CWH_ALARM_DESCRIPTION?=
# CWH_ALARM_METRIC_NAME?= sys.cpu
# CWH_ALARM_NAME_PREFIX?=
CWH_ALARM_NAME?= $(word 1,$(CWH_ALARM_NAMES))
# CWH_ALARM_NAMES?=
# CWH_DESCRIBE_ALARMS_QUERY_FILTER?= ?contains(AlarmName,'Foo')
# CWH_HISTORY_ITEM_TYPE?=
# CWH_HISTORY_END_DATE?=
# CWH_HISTORY_START_DATE?=
# CWH_LIST_METRICS_QUERY_FILTER?=? contains(MetricName,'Foo')
# CWH_METRIC_DIMENSIONS?=
# CWH_METRIC_NAME?= CPUUtilization
# CWH_METRIC_NAMESPACE?= "AWS/SNS"
# CWH_NUMBER_SAMPLES?= 2
# CWH_OK_ACTIONS?=
# CWH_SAMPLING_PERIOD?= 60
# CWH_TRIGGER_STATISTIC?= Average
# CWH_TRIGGER_COMPARISON_OPERATOR?= GreaterThanThreshold
# CWH_TRIGGER_THRESHOLD?= 70
# CWH_TRIGGER_UNIT?= Percent
# CWH_STATE_REASON?="State changed for testing purpose"
# CWH_STATE_VALUE?=INSUFFICIENT_DATA

__ACTION_ENABLED= $(if $(filter true,$(CWH_ACTION_ENABLED)),--action-enabled,--no-action-enabled)
__ACTION_PREFIX?= $(if $(CWH_ACTION_PREFIX),--action-prefix $(CWH_ACTION_PREFIX))
__ALARM_DESCRIPTION?= $(if $(CWH_ALARM_DESCRIPTION),--alarm-description $(CWH_ALARM_DESCRIPTION))
__ALARM_NAME_PREFIX?= $(if $(CWH_ALARM_NAME_PREFIX),--alarm-name-prefix $(CWH_ALARM_NAME_PREFIX))
__ALARM_NAME?= $(if $(CWH_ALARM_NAME),--alarm-name $(CWH_ALARM_NAME))
__ALARM_NAMES?= $(if $(CWH_ALARM_NAMES),--alarm-names $(CWH_ALARM_NAMES))
__COMPARISON_OPERATOR?= $(if $(CWH_TRIGGER_COMPARISON_OPERATOR),--comparison-operator $(CWH_TRIGGER_COMPARISON_OPERATOR))
__EVALUATION_PERIOD?= $(if $(CWH_SAMPLING_PERIOD),--evaluation-period $(CWH_SAMPLING_PERIOD))
__THRESHOLD?= $(if $(CWH_TRIGGER_THRESHOLD),--threshold $(CWH_TRIGGER_THRESHOLD))
__UNIT?= $(if $(CWH_TRIGGER_UNIT),--unit $(CWH_TRIGGER_UNIT))


__DIMENSIONS?= $(if $(CWH_METRIC_DIMENSIONS),--dimensions $(CWH_METRIC_DIMENSIONS))
__NAMESPACE?= $(if $(CWH_METRIC_NAMESPACE), --namespace $(CWH_METRIC_NAMESPACE))
__METRIC_NAME?= $(if $(CWH_METRIC_NAME), --metric-name $(CWH_METRIC_NAME))
__METRIC?= $(__METRIC_NAME) $(__NAMESPACE) $(__DIMENSIONS)

__ALARM_ACTIONS?= $(if $(CWH_ALARM_ACTIONS),--alarm-actions $(CWH_ALARM_ACTIONS))
__INSUFFICIENT_DATA_ACTIONS?= $(if $(CWH_INSUFFICIENT_DATA_ACTIONS),--insufficient-data-action $(CWH_INSUFFICIENTDATA_ACTIONS))
__OK_ACTIONS?= $(if $(CWH_OK_ACTIONS),--ok-action $(CWH_OK_ACTIONS))
__ACTIONS?= $(__ALARM_ACTIONS) $(__OK_ACTIONS) $(__INSUFFICIENT_DATA_ACTIONS)

__END_DATE?= $(if $(CWH_HISTORY_END_DATE), --start-date $(CWH_HISTORY_END_DATE))
__HISTORY_ITEM_TYPE?= $(if $(CWH_HISTORY_ITEM_TYPE), --history-item-type $(CWH_HISTORY_ITEM_TYPE))
__START_DATE?= $(if $(CWH_HISTORY_START_DATE), --start-date $(CWH_HISTORY_START_DATE))
__HISTORY?= $(__HISTORY_ITEM_TYPE) $(__START_DATE) $(__END_DATE)

__STATE_REASON?= $(if $(CWH_STATE_REASON),--state-reason "$(CWH_STATE_REASON)")
__STATE_REASON_DATA?= $(if $(CWH_STATE_REASON_DATA),--state-reason-data $(CWH_STATE_REASON_DATA))
__STATE_VALUE?= $(if $(CWH_STATE_VALUE),--state-value $(CWH_STATE_VALUE))
__STATE?= $(__STATE_VALUE) $(__STATE_REASON) $(__STATE_REASON_DATA)

CWH_VIEW_ALARM_DETAILS_FIELDS?={MetricName:MetricName,Namespace:Namespace,Sampling:join(' ',[to_string(EvaluationPeriods), 'Samples', to_string(Period), 'sec apart']),Trigger:join(' ',[Statistic, ComparisonOperator, to_string(Threshold), Unit]),Dimensions:Dimensions}
CWH_VIEW_ALARM_STATE_FIELDS?={LastUpdated:StateUpdatedTimestamp,StateReason:StateReason,State:StateValue}
CWH_VIEW_ALARMS_STATUS_FIELDS?=[AlarmName,StateValue]

#--- MACROS

get_alarms_S=$(shell $(AWS) cloudwatch describe-alarms --query "sort_by(MetricAlarms,$(1))[$(CWH_DESCRIBE_ALARMS_QUERY_FILTER)].AlarmName" --output text)
get_alarms=$(call get_alarms_S,&AlarmName)
get_alarm_I=$(word $(1), $(call get_alarms))

#----------------------------------------------------------------------
# USAGE
#

_aws_view_makefile_macros :: _cwh_view_makefile_macros
_cwh_view_makefile_macros:
	@echo "AWS::CloudWatcH ($(_AWS_CLOUDWATCH_MK_VERSION)) macros:"
	@echo "   get_alarms                           - Returns alarms based on a query filter"
	@echo "   get_alarms_S                         - Returns a sorted-list of alarms (SortBy)"
	@echo "   get_alarm_I                          - Returns 1 alarm (Index)"
	@echo

_aws_view_makefile_targets :: _cwh_view_makefile_targets
_cwh_view_makefile_targets:
	@echo "AWS::CloudWatcH ($(_AWS_CLOUDWATCH_MK_VERSION)) targets:"
	@echo "    _cwh_create_alarm            - Create an alarm"
	@echo "    _cwh_delete_alarms           - Delete alarms"
	@echo "    _cwh_view_alarms             - Describe alarms"
	@echo "    _cwh_view_alarms_states      - Display the states of the alarms"
	@echo

_aws_view_makefile_variables :: _cwh_view_makefile_variables
_cwh_view_makefile_variables:
	@echo "AWS::CloudWatcH ($(_AWS_CLOUDWATCH_MK_VERSION)) variables:"
	@echo "    CWH_ACTION_ENABLED=$(CWH_ACTION_ENABLED)"
	@echo "    CWH_ACTION_PREFIX=$(CWH_ACTION_PREFIX)"
	@echo "    CWH_ALARM_ACTION=$(CWH_ALARM_ACTION)"
	@echo "    CWH_ALARM_DESCRIPTION=$(CWH_ALARM_DESCRIPTION)"
	@echo "    CWH_ALARM_NAME=$(CWH_ALARM_NAME)"
	@echo "    CWH_ALARM_NAME_PREFIX=$(CWH_ALARM_NAME_PREFIX)"
	@echo "    CWH_ALARM_NAMES=$(CWH_ALARM_NAMES)"
	@echo "    CWH_DESCRIBE_ALARMS_QUERY_FILTER=$(CWH_DESCRIBE_ALARMS_QUERY_FILTER)"
	@echo "    CWH_LIST_METRICS_QUERY_FILTER=$(CWH_LIST_METRICS_QUERY_FILTER)"
	@echo "    CWH_METRIC_DIMENSIONS=$(CWH_METRIC_DIMENSIONS)"
	@echo "    CWH_METRIC_NAME=$(CWH_METRIC_NAME)"
	@echo "    CWH_METRIC_NAMESPACE=$(CWH_METRIC_NAMESPACE)"
	@echo "    CWH_OK_ACTIONS=$(CWH_OK_ACTIONS)"
	@echo "    CWH_STATE_REASON=$(CWH_STATE_REASON)"
	@echo "    CWH_STATE_VALUE=$(CWH_STATE_VALUE)"
	@echo "    CWH_TRIGGER_STATISTIC=$(CWH_TRIGGER_STATISTIC)"
	@echo

_aws_install :: _cwh_install
_cwh_install:
	sudo apt-get install feedgnuplot

#----------------------------------------------------------------------
# PRIVATE TARGETS
#

__cwh_view_alarm_details:
	@echo -n "| "; $(INFO) "$(CWH_ALARM_NAME)"; $(NORMAL)
	$(AWS) cloudwatch describe-alarms --alarm-names $(CWH_ALARM_NAME) --query "MetricAlarms[$(CWH_DESCRIBE_ALARMS_QUERY_FILTER)].$(CWH_VIEW_ALARM_DETAILS_FIELDS)" \
	| tail -n +4

__cwh_view_alarm_state:
	@echo -n "| "; $(INFO) "$(CWH_ALARM_NAME)"; $(NORMAL)
	@$(AWS) cloudwatch describe-alarms --alarm-names $(CWH_ALARM_NAME) --query "MetricAlarms[$(CWH_DESCRIBE_ALARMS_QUERY_FILTER)].$(CWH_VIEW_ALARM_STATE_FIELDS)" \
	| tail -n +4

#----------------------------------------------------------------------
# PUBLIC TARGETS
#

_cwh_create_alarm:
	@$(INFO) "$(AWS_LABEL)Creating alarm: $(CWH_ALARM_NAME)"; $(NORMAL)
	$(AWS) cloudwatch put-metric-alarm $(__ALARM_NAME) $(__ALARM_DESCRIPTION) $(__ACTION_ENABLED) $(__ACTIONS) $(__METRIC) $(__PERIOD) $(__UNIT) $(__EVALUATION_PERIODS) $(__THRESHOLD) $(__COMPARISON_OPERATOR)

_cwh_delete_alarms:
	@$(INFO) "$(AWS_LABEL)Deleting alarms: $(CWH_ALARM_NAMES)"; $(NORMAL)
	$(AWS) cloudwatch delete-alarms $(__ALARM_NAMES)

_cwh_view_alarms_details: _cwh_view_alarms_status
	@$(foreach N, $(CWH_ALARM_NAMES), \
		make -s CWH_ALARM_NAME=$(N) __cwh_view_alarm_details; \
	)

_cwh_view_alarms_status:
	@$(INFO) "$(AWS_LABEL)Displaying alarm status ..."; $(NORMAL)
	$(AWS) cloudwatch describe-alarms $(__ALARM_NAMES) $(__ALARM_NAME_PREFIX) $(__STATE_VALUE) $(__ACTION_PREFIX) --query "MetricAlarms[$(CWH_DESCRIBE_ALARMS_QUERY_FILTER)].$(CWH_VIEW_ALARMS_STATUS_FIELDS)"

_cwh_view_alarms_states: _cwh_view_alarms_status
	@$(foreach N, $(CWH_ALARM_NAMES), \
		make -s CWH_ALARM_NAME=$(N) __cwh_view_alarm_state; \
	)

_cwh_view_metrics:
	$(AWS) cloudwatch list-metrics $(__METRICS)

_cwh_set_alarm_state:
	@$(INFO) "$(AWS_LABEL)Setting alarm '$(CWH_ALARM_NAME)' to state '$(CWH_STATE_VALUE)' ..."; $(NORMAL)
	$(AWS) cloudwatch set-alarm-state $(__ALARM_NAME) $(__STATE)

_cwh_view_alarm_history:
	@$(INFO) "$(AWS_LABEL)Displaying history for alarm '$(CWH_ALARM_NAME)' ..."; $(NORMAL)
	$(AWS) cloudwatch describe-alarm-history $(__ALARM_NAME) $(__HISTORY)
