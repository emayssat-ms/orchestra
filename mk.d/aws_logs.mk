_AWS_LOGS_MK_VERSION=0.99.0

# LOGS_GROUP_NAME?=
# LOGS_STREAM_NAME?=

__LOG_GROUP_NAME= --log-group-name $(LOGS_GROUP_NAME)
__LOG_STREAM_NAME= --log-stream-name $(LOGS_STREAM_NAME)


#----------------------------------------------------------------------
# USAGE
#
_aws_view_makefile_macros :: _logs_view_makefile_macros
_logs_view_makefile_macros :: ;

_aws_view_makefile_targets :: _logs_view_makefile_targets
_logs_view_makefile_targets ::
	@echo "AWS::Cloudwatch ($(_AWS_LOGS_MK_VERSION)) targets:"
	@echo "    _logs_delete_log_groups        - Delete an existing log group"
	@echo "    _logs_delete_log_group_stream  - Delete an existing log group stream"
	@echo "    _logs_list_log_groups          - List all log groups"
	@echo "    _logs_list_log_group_streams   - List all streams of a log groups"
	@echo "    _logs_view_log_events          - View events from a log group stream"
	@echo

_aws_view_makefile_variables :: _logs_view_makefile_variables
_logs_view_makefile_variables ::
	@echo "AWS::Cloudwatch ($(_AWS_LOGS_MK_VERSION)) variables:"
	@echo "    LOGS_GROUP_NAME=$(LOGS_GROUP_NAME)"
	@echo "    LOGS_STREAM_NAME=$(LOGS_STREAM_NAME)"
	@echo

#----------------------------------------------------------------------
# OPERATIONS 
#

_logs_delete_log_group:
	$(AWS) logs delete-log-group $(__LOG_GROUP_NAME)

_logs_delete_log_group_stream:
	$(AWS) logs delete-log-steam $(__LOG_GROUP_NAME) $(__LOG_STREAM_NAME)

_logs_list_log_groups:
	$(AWS) logs describe-log-groups --query 'logGroups[*].[logGroupName]'

_logs_list_log_group_streams:
	$(AWS) logs describe-log-streams $(__LOG_GROUP_NAME) --query 'logStreams[*].logStreamName'

_logs_view_log_events:
	$(AWS) logs get-log-events $(__LOG_GROUP_NAME) $(__LOG_STREAM_NAME) --query 'events[*].message'

