_AWS_RDS_MK_VERSION = 0.99.0

# RDS_BACKUP_RETENTION_PERIOD?=7
RDS_INSTANCE?= $(firstword $(RDS_INSTANCES))
# RDS_INSTANCES?=

# RDS_DESCRIBE_DB_INSTANCES_QUERY_FILTER?=?DBSubnetGroup.VpcId=='vpc-5b35ca3f'

RDS_VIEW_INSTANCES_METADATA?=[Engine,EngineVersion,MultiAZ,DBInstanceClass,AvailabilityZone,DBInstanceStatus]

#----------------------------------------------------------------------
# USAGE
#

_aws_view_makefile_targets :: _rds_view_makefile_targets
_rds_view_makefile_targets :
	@echo "AWS::RDS ($(_AWS_RDS_MK_VERSION)) targets:"
	@echo "    _rds_view_instances_details		- Display all the available info on select db instances"
	@echo "    _rds_view_instances_metadata		- Display the select metadata on select db instances"
	@echo

_aws_view_makefile_variables :: _rds_view_makefile_variables
_rds_view_makefile_variables :
	@echo "AWS::RDS ($(_AWS_RDS_MK_VERSION)) variables:"
	@echo "    RDS_BACKUP_RETENTION_PERIOD=$(RDS_BACKUP_RETENTION_PERIOD)"
	@echo "    RDS_DESCRIBE_DB_INSTANCES_QUERY_FILTER=$(RDS_DESCRIBE_DB_INSTANCES_QUERY_FILTER)"
	@echo "    RDS_INSTANCE=$(RDS_INSTANCE)"
	@echo "    RDS_INSTANCES=$(RDS_INSTANCES)"
	@echo


#----------------------------------------------------------------------

_rds_view_instances_details: __QUERY?= --query "DBInstances[$(RDS_DESCRIBE_DB_INSTANCES_QUERY_FILTER)]"
_rds_view_instances_details:
	@$(INFO) "$(AWS_LABEL)View DB instance details ..."; $(NORMAL)
	$(AWS) rds describe-db-instances $(__FILTER) $(__QUERY)

_rds_view_instances_metadata: __QUERY?= --query "DBInstances[$(RDS_DESCRIBE_DB_INSTANCES_QUERY_FILTER)].$(RDS_VIEW_INSTANCES_METADATA)"
_rds_view_instances_metadata:
	@$(INFO) "$(AWS_LABEL)View DB instances metadiata ..."; $(NORMAL)
	$(AWS) rds describe-db-instances $(__FILTER) $(__QUERY)
