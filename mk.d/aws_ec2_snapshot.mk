_AWS_EC2_SNAPSHOT_MK_VERSION=0.99.6

#--- INPUT PARAMETERS
# SNAPSHOT_OWNERS?=$(IMAGE_OWNERS)
# SNAPSHOT_PREFIX?=$(IMAGE_PREFIX)
# SNAPSHOT_ID?=
SNAPSHOT_IDS?=$(SNAPSHOT_ID)
# SNAPSHOT_TAGS?=
# SOURCE_IMAGE?=
# SOURCE_REGION?=

__SNAPSHOT_ID= --snapshot-id $(SNAPSHOT_ID)
__SNAPSHOT_IDS= --snapshot-ids $(SNAPSHOT_IDS)
__SNAPSHOT_TAGS= --tags $(SNAPSHOT_TAGS)

#----------------------------------------------------------------------
# USAGE
#

_aws_view_makefile_macros:: _snapshot_view_makefile_macros
_snapshot_view_makefile_macros:
	@echo "AWS::EC2::Snapshot ($(_AWS_EC2_SNAPSHOT_MK_VERSION)) macros:"
	@echo "    get_ami_id_IOD                   - Get an AMI ID of given an image name, owners, or else default"
	@echo

_aws_view_makefile_targets :: _snapshot_view_makefile_targets
_snapshot_view_makefile_targets:
	@echo "AWS::EC2::Snapshot ($(_AWS_EC2_SNAPSHOT_MK_VERSION)) targets:"
	@echo "    _ec2_view_snapshot_states        - View the state of the snapshots"
	@echo "    _ec2_tag_snapshot                - Tag an existing snapshot"
	@echo "    _ec2_view_snapshot_list          - View the list of available snapshot"
	@echo 

_aws_view_makefile_variables :: _snapshot_view_makefile_variables
_snapshot_view_makefile_variables:
	@echo "AWS::EC2::Snapshot ($(_AWS_EC2_SNAPSHOT_MK_VERSION)) variables:"
	@echo "    SNAPSHOT_ID=$(SNAPSHOT_ID)"
	@echo "    SNAPSHOT_IDS=$(SNAPSHOT_IDS)"
	@echo "    SNAPSHOT_TAGS=$(SNAPSHOT_TAGS)"
	@echo

#----------------------------------------------------------------------
# AWS OPERATIONS
#

_ec2_view_snapshot_states:
	@$(if $(SNAPSHOT_ID),, \
		$(ERROR) "$(AWS_LABEL)Image not exported to this region yet!"; $(NORMAL) \
	)
	@$(if $(findstring None, $(SNAPSHOT_ID)),\
		echo "$(AWS_LABEL)Snapshot file is being transfered and is not available yet!"\
	)
	@$(if $(findstring snap-, $(SNAPSHOT_ID)), \
		echo "$(AWS_LABEL)Snapshot is available: $(SNAPSHOT_ID)" \
	)

_ec2_tag_snapshot:
	@$(INFO) "$(AWS_LABEL)Tagging the snapshot: $(SNAPSHOT_ID) ...";
	@$(WARN) "The snapshot needs to be available in this region for this operation to complete successfully."
	@$(WARN) "If you just created, exported, or copied the snapshot, it may not be accessible yet."
	@$(NORMAL)
	$(AWS) ec2 create-tags $(__TAGS) --resources $(SNAPSHOT_ID)

_ec2_view_snapshot_list:
	# FIXME: Doesn't fully work as intended yet!
	@$(INFO) "$(AWS_LABEL)Fetching snapshot list with SNAPSHOT_PREFIX=$(SNAPSHOT_PREFIX) ..."; $(NORMAL)
	# $(AWS) ec2 describe-snapshots $(__OWNER_IDS) --query "sort_by(Snapshots, &CreationDate)[? contains(Name, '$(SNAPSHOT_PREFIX)')]"
	$(AWS) ec2 describe-snapshots $(__OWNER_IDS)
	# $(AWS) ec2 describe-snapshots $(__OWNER_IDS) --query "sort_by(Images, &CreationDate)[? contains(Name, '$(SNAPSHOT_PREFIX)')].{CreationDate:CreationDate, ImageId:ImageId, Name:Name, ZDescription:Description}"

_ec2_view_snapshot_tags:
	$(AWS) ec2 describe-snapshots --query 'Snapshots[0].Tags[]' $(__SNAPSHOT_IDS)
