_AWS_LOGS_MK_VERSION=0.99.0

# LGS_GROUP_NAME?=
# LGS_STREAM_NAME?=

__LOG_GROUP_NAME= $(if $(LGS_GROUP_NAME),--log-group-name $(LGS_GROUP_NAME))
__LOG_STREAM_NAME= $(if $(LGS_STREAM_NAME),--log-stream-name '$(LGS_STREAM_NAME)')

LGS_DESCRIBE_LOG_GROUPS_QUERY_FILTER?=
LGS_DESCRIBE_LOG_STREAMS_QUERY_FILTER?=
LGS_GET_LOG_EVENTS_QUERY_FILTER?=
LGS_VIEW_LOG_EVENTS_FIELDS?=.[timestamp,message]
LGS_VIEW_LOG_GROUPS_FIELDS?=.[logGroupName]
LGS_VIEW_LOG_GROUP_STREAMS_FIELDS?=.logStreamName

#--- MACRO

get_last_modified_log_stream_G=$(shell $(AWS) logs describe-log-streams --log-group-name $(1) --query 'reverse(sort_by(logStreams,&lastEventTimestamp))[0].logStreamName' --output text)

#----------------------------------------------------------------------
# USAGE
#

_aws_view_makefile_macros :: _lgs_view_makefile_macros
_lgs_view_makefile_macros :: ;
	@echo "AWS::Cloudwatch ($(_AWS_LOGS_MK_VERSION)) macros:"
	@echo "    get_last_modified_log_stream_G   - Get the last stream for a given log group (GROUP)"
	@echo

_aws_view_makefile_targets :: _lgs_view_makefile_targets
_lgs_view_makefile_targets ::
	@echo "AWS::Cloudwatch ($(_AWS_LOGS_MK_VERSION)) targets:"
	@echo "    _lgs_delete_log_groups        - Delete an existing log group"
	@echo "    _lgs_delete_log_group_stream  - Delete an existing log group stream"
	@echo "    _lgs_view_log_groups          - List all log groups"
	@echo "    _lgs_view_log_group_streams   - List all streams of a log groups"
	@echo "    _lgs_view_log_events          - View events from a log group stream"
	@echo

_aws_view_makefile_variables :: _lgs_view_makefile_variables
_lgs_view_makefile_variables ::
	@echo "AWS::Cloudwatch ($(_AWS_LOGS_MK_VERSION)) variables:"
	@echo "    LGS_GROUP_NAME=$(LGS_GROUP_NAME)"
	@echo "    LGS_STREAM_NAME=$(LGS_STREAM_NAME)"
	@echo

#----------------------------------------------------------------------
# PUBLIC TARGETS
#

_lgs_delete_log_group:
	$(AWS) logs delete-log-group $(__LOG_GROUP_NAME)

_lgs_delete_log_group_stream:
	$(AWS) logs delete-log-steam $(__LOG_GROUP_NAME) $(__LOG_STREAM_NAME)

_lgs_view_log_groups:
	@$(INFO) "$(AWS_LABEL)Fetching existing log groups ..."; $(NORMAL)
	$(AWS) logs describe-log-groups --query 'logGroups[$(LGS_DESCRIBE_LOG_GROUPS_QUERY_FILTER)]$(LGS_VIEW_LOG_GROUPS_FIELDS)'

_lgs_view_log_group_streams:
	@$(INFO) "$(AWS_LABEL)Fetching streams from log group '$(LGS_GROUP_NAME)' ..."; $(NORMAL)
	$(AWS) logs describe-log-streams $(__LOG_GROUP_NAME) --query 'logStreams[$(LGS_DESCRIBE_LOG_STREAMS_QUERY_FILTER)]$(LGS_VIEW_LOG_GROUP_STREAMS_FIELDS)'

_lgs_view_log_events: NOW_UTC:=$(shell date --utc +'%Y-%m-%dT%H:%M:%S UTC')
_lgs_view_log_events:
	@$(INFO) "$(AWS_LABEL)Fetching log events from stream ..."; $(NORMAL)
	@$(WARN) "Log group: $(LGS_GROUP_NAME)"; $(NORMAL)
	@$(WARN) "Stream: $(LGS_STREAM_NAME)"; $(NORMAL)
	@$(WARN) "Now: $(NOW_UTC)"; $(NORMAL)
	@echo
	@$(AWS) logs get-log-events $(__LOG_GROUP_NAME) $(__LOG_STREAM_NAME) --query "sort_by(events,&timestamp)[$(LBS_GET_LOG_EVENTS_QUERY_FILTER)]$(LGS_VIEW_LOG_EVENTS_FIELDS)" --output text
	@echo
	@$(WARN) "Now: $(NOW_UTC)"; $(NORMAL)
	@$(WARN) "Last entry is the most recent."; $(NORMAL)
	@$(WARN) "Log group: $(LGS_GROUP_NAME)"; $(NORMAL)
	@$(WARN) "Stream: $(LGS_STREAM_NAME)"; $(NORMAL)


