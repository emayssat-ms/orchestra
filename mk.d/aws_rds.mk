_AWS_RDS_MK_VERSION = 0.99.0

# RDS_BACKUP_RETENTION_PERIOD?=7
# RDS_INSTANCE?=
# RDS_INSTANCES?=

#----------------------------------------------------------------------
# USAGE
#

_aws_view_makefile_targets :: _rds_view_makefile_targets
_rds_view_makefile_targets :
	@echo "AWS::RDS ($(_AWS_RDS_MK_VERSION)) targets:"
	@echo "    _rds_desribe_db_instances		- Describe the db instances in the region"
	@echo

_aws_view_makefile_variables :: _rds_view_makefile_variables
_rds_view_makefile_variables :
	@echo "AWS::RDS ($(_AWS_RDS_MK_VERSION)) variables:"
	@echo "    RDS_BACKUP_RETENTION_PERIOD=$(RDS_BACKUP_RETENTION_PERIOD)"
	@echo "    RDS_INSTANCE=$(RDS_INSTANCE)"
	@echo "    RDS_INSTANCES=$(RDS_INSTANCES)"
	@echo


#----------------------------------------------------------------------

_rds_describe_db_instances:
	$(AWS) rds describe-db-instances $(__FILTER) $(__QUERY)
