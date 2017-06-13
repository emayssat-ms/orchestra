_AWS_ROUTE53_MK_VERSION=0.99.3

# CLI53_ENVIRONMENT?=
# R53_HOSTED_ZONE?=$(HOSTED_ZONE)
# R53_CALLER_REFERENCE?=2014-04-01-18:47
# R53_HEALTH_CHECK_CONFIG?=file://C:\awscli\route53\create-health-check.json
# R53_HEALTH_CHECK_ID?=02ec8401-9879-4259-91fa-04e66d094674

ifneq ($(R53_HOSTED_ZONE),)
R53_HOSTED_ZONE_ID?=$(call get_hosted_zone_id_HD,$(R53_HOSTED_ZONE),)
endif

__CALLER_REFERENCE= $(if $(R53_CALLER_REFERENCE), --caller-reference $(R53_CALLER_REFERENCE))
__HEALTH_CHECK_CONFIG= $(if $(R53_HEALTH_CHECK_CONFIG), --health-check-config $(R53_HEALTH_CHECK_CONFIG))
__HEALTH_CHECK_ID= $(if $(R53_HEALTH_CHECK_ID), --health-check-id $(R53_HEALTH_CHECK_ID))

# Environment
R53_ZONES_DIR?=zones
R53_ZONE_DIR?=$(R53_ZONES_DIR)/$(R53_HOSTED_ZONE)

# Computed parameters 
__HOSTED_ZONE_ID= --hosted-zone-id $(R53_HOSTED_ZONE_ID)

ZONE_LIST_FIELDS?=Name,Id,ResourceRecordSetCount
# ZONE_LIST_QUERY_FILTER?=

#--- Macro
get_hosted_zone_id=$(call get_hosted_zone_id_H, $(R53_HOSTED_ZONE))
get_hosted_zone_id_H=$(shell $(AWS) route53 list-hosted-zones --query 'HostedZones[?Name==`$(1).`].[Id]' --output text | sed s_/hostedzone/__)
get_hosted_zone_id_HD=$(if $(1),$(shell $(AWS) route53 list-hosted-zones --query 'HostedZones[?Name==`$(1).`].[Id]' --output text | sed s_/hostedzone/__),$(2))


DESCRIBE_HEALTH_CHECKS_FIELDS?=.[Id,HealthCheckConfig.IPAddress,HealthCheckConfig.Type,HealthCheckConfig.Port]
VIEW_HEALTH_CHECK_STATUS_FIELDS?=.[StatusReport.CheckedTime,StatusReport.Status,IPAddress]

CLI53?=$(__CLI53_ENVIRONMENT) $(CLI53_ENVIRONMENT) cli53 $(__CLI53_OPTIONS) $(CLI53_OPTIONS)

#----------------------------------------------------------------------
# USAGE
#

_aws_view_makefile_macros :: _r53_view_makefile_macros
_r53_view_makefile_macros:
	@echo "AWS::Route53 ($(_AWS_ROUTE53_MK_VERSION)) macros:"
	@echo "    get_hosted_zone_id                      - Get the current hosted zone id"
	@echo "    get_hosted_zone_id_{H,HD}               - Get a hosted zone ID (Hosted Zone, Default)"
	@echo


_aws_view_makefile_targets :: _r53_view_makefile_targets
_r53_view_makefile_targets:
	@echo "AWS::Route53 ($(_AWS_ROUTE53_MK_VERSION)) targets:"
	@echo "    _r53_create_health_check            - Create a health check"
	@echo "    _r53_decribe_health_checks          - Describe health check"
	@echo "    _r53_diff_zone                      - Diff current zone with the latest one exported"
	@echo "    _r53_dump_zone                      - Dump the hosted-zone records in a bind file"
	@echo "    _r53_get_health_check               - Get health check"
	@echo "    _r53_get_health_check_status        - Get health check status"
	@echo "    _r53_get_health_check_count         - Get the number of health checks in the account"
	@echo "    _r53_get_rrsets                     - Get the record set"
	@echo "    _r53_list_hosted_zones              - Get all the hosted zone of the current aws account"
	@echo "    _r53_rollback_zone                  - Restore the latest exported zone file of hosted zone"
	@echo "    _r53_list_zone_records              - List select DNS records of an hosted zone"
	@echo

_aws_view_makefile_variables :: _r53_view_makefile_variables
_r53_view_makefile_variables:
	@echo "AWS::Route53 ($(_AWS_ROUTE53_MK_VERSION)) variables:"
	@echo "    CLI53=$(CLI53)"
	@echo "    R53_CALLER_REFERENCE=$(R53_CALLER_REFERENCE)"
	@echo "    R53_HEALTH_CHECK_CONFIG=$(R53_HEALTH_CHECK_CONFIG)"
	@echo "    R53_HEALTH_CHECK_ID=$(R53_HEALTH_CHECK_ID)"
	@echo "    R53_HOSTED_ZONE=$(R53_HOSTED_ZONE)"
	@echo "    R53_HOSTED_ZONE_ID=$(R53_HOSTED_ZONE_ID)"
	@echo "    R53_ZONE_DIR=$(R53_ZONE_DIR)"
	@echo "    R53_ZONES_DIR=$(R53_ZONES_DIR)"
	@echo


#----------------------------------------------------------------------
# PRIVATE TARGETS
#


#----------------------------------------------------------------------
# PUBLIC TARGETS
#

_r53_get_rrsets:
	$(AWS) route53 list-resource-record-sets $(__HOSTED_ZONE_ID)

_r53_view_zone_list:
	@$(INFO) "$(AWS_LABEL)Fetching existing hosted zones ..."; $(NORMAL)
	$(AWS) route53 list-hosted-zones --query "HostedZones[$(ZONE_LIST_QUERY_FILTER)].[$(ZONE_LIST_FIELDS)]"

_r53_dump_zone:
	mkdir -pv $(R53_ZONE_DIR)
	$(CLI53) export $(R53_HOSTED_ZONE) > $(R53_ZONE_DIR)/`date +%Y%m%d_%H%M%S.bind`

_R53_LAST_ZONE_EXPORT=`ls -1 *.bind | tail -1`
_r53_rollback_zone:
	cd $(R53_ZONE_DIR)/; $(CLI53) import  -r --wait $(R53_HOSTED_ZONE) -f $(_R53_LAST_ZONE_EXPORT)

_r53_diff_current_with_saved_zone:
	$(CLI53) export $(R53_HOSTED_ZONE) > /tmp/$(R53_HOSTED_ZONE).bind
	# diff alone returns exit code 1 if files are different, hence || true
	cd $(R53_ZONE_DIR)/; diff $(_R53_LAST_ZONE_EXPORT) /tmp/$(R53_HOSTED_ZONE).bind || true

_r53_view_zone_records:
	@$(INFO) "$(AWS_LABEL)Fetching relevant records from $(R53_HOSTED_ZONE) hosted zone..." && $(NORMAL)
	$(CLI53) export $(R53_HOSTED_ZONE)

#----------------------------------------------------------------------
# HEALTH CHECKS
#
_r53_create_health_check:
	$(AWS) route53 create-health-check $(__CALLER_REFERENCE) $(__HEALTH_CHECK_CONFIG)

_r53_describe_health_check:
	@$(INFO) "$(AWS_LABEL)Describing health check $(R53_HEALTH_CHECK_ID) ..."; $(NORMAL)
	$(AWS) route53 get-health-check $(__HEALTH_CHECK_ID)

_r53_describe_health_checks: __QUERY?= --query "HealthChecks[]$(DESCRIBE_HEALTH_CHECKS_FIELDS)"
_r53_describe_health_checks:
	@$(INFO) "$(AWS_LABEL)Listing all health checks ..."; $(NORMAL)
	$(AWS) route53 list-health-checks $(__FILTER) $(__QUERY)

_r53_get_health_check_status: __QUERY?=--query "HealthCheckObservations[]$(VIEW_HEALTH_CHECK_STATUS_FIELDS)"
_r53_get_health_check_status:
	@$(INFO) "$(AWS_LABEL)Reporting on the status of $(R53_HEALTH_CHECK_ID) ..."; $(NORMAL)
	$(AWS)  route53 get-health-check-status $(__HEALTH_CHECK_ID) $(__QUERY)

_r53_get_health_checks_count:
	$(AWS) route53 get-health-check-count
