_AWS_EC2_IMAGE_MK_VERSION=0.99.7

EC2_IMAGE_ATTRIBUTES?= description kernel ramdisk launchPermission productCodes blockDeviceMapping sriovNetSupport
# EC2_IMAGE_BASENAME?=ImageBasename
# EC2_IMAGE_DESCRIPTION?=
# EC2_IMAGE_LAUNCH_PERMISSION_ADD?=[{"UserId": "$(DESTINATION_ACCOUNT)"}]
# EC2_IMAGE_LAUNCH_PERMISSION_REMOVE?=[{"UserId": "$(DESTINATION_ACCOUNT)"}]
EC2_IMAGE_LAUNCH_PERMISSION?='{"Add":$(EC2_IMAGE_LAUNCH_PERMISSION_ADD)}'
EC2_IMAGE_OWNER?=$(firstword $(EC2_IMAGE_OWNERS))
EC2_IMAGE_OWNERS?=$(AWS_OWNER)
# EC2_IMAGE_PREFIX?=
# EC2_IMAGE_SUFFIX?=000a
# EC2_IMAGE_TAGS?=
# EC2_SOURCE_IMAGE?=
# EC2_SOURCE_REGION?=

EC2_IMAGE_NAME?=$(EC2_IMAGE_PREFIX)$(EC2_IMAGE_BASENAME)$(EC2_IMAGE_SUFFIX)
# EC2_IMAGE_ID?=$(shell $(AWS) ec2 describe-images $(__OWNERS)  --filters "Name=name,Values=$(EC2_IMAGE_NAME)" --query 'Images[].ImageId' --output text)
EC2_IMAGE_IDS?=$(EC2_IMAGE_ID)

EC2_VIEW_IMAGE_LIST_FIELDS?=[CreationDate,ImageId,Name,Description]
EC2_VIEW_IMAGE_STATES_FIELDS?=[CreationDate,ImageId,Name,State]
EC2_VIEW_IMAGE_USAGE_FIELDS?=[Tags[?Key=='Name'] | [0].Value, InstanceType]

__DESCRIPTION= $(if $(EC2_IMAGE_DESCRIPTION),--description "$(EC2_IMAGE_DESCRIPTION)")
__IMAGE_ID= $(if $(EC2_IMAGE_ID),--image-id $(EC2_IMAGE_ID))
__IMAGE_IDS= $(if $(EC2_IMAGE_IDS),--image-ids $(EC2_IMAGE_IDS))
__LAUNCH_PERMISSION= $(if $(EC2_IMAGE_LAUNCH_PERMISSION),--launch-permission $(EC2_IMAGE_LAUNCH_PERMISSION))
__NAME= $(if $(EC2_IMAGE_NAME),--name $(EC2_IMAGE_NAME))
__OWNER= $(if $(EC2_IMAGE_OWNER),--owner $(EC2_IMAGE_OWNER))
__OWNERS= $(if $(EC2_IMAGE_OWNERS),--owners $(EC2_IMAGE_OWNERS))
__SOURCE_IMAGE= $(if $(EC2_SOURCE_IMAGE),--source-image $(EC2_SOURCE_IMAGE))
__SOURCE_REGION= $(if $(EC2_SOURCE_REGION),--source-region $(EC2_SOURCE_REGION))
__IMAGE_TAGS= $(if $(EC2_IMAGE_TAGS),--tags $(EC2_IMAGE_TAGS))

#--- Macros

get_image_id_IOD=$(if $(1),$(shell $(AWS) ec2 describe-images --filters "Name=name,Values=$(1)" --owners $(2) --query 'Images[].ImageId' --output text),$(3))

#----------------------------------------------------------------------
# USAGE
#

_aws_view_makefile_macros :: _ec2_image_view_makefile_macros
_ec2_image_view_makefile_macros:
	@echo "AWS::EC2::Image ($(_AWS_EC2_IMAGE_MK_VERSION)) macros:"
	@echo "    get_image_id_IOD                   - Get an Image ID of given an image name, owners, or else default"
	@echo

_aws_view_makefile_targets :: _ec2_image_view_makefile_targets
_ec2_image_view_makefile_targets:
	@echo "AWS::EC2::Image ($(_AWS_EC2_IMAGE_MK_VERSION)) targets:"
	@echo "    _ec2_create_image                - Create an image from a running instance"
	@echo "    _ec2_deregister_image            - Deregister an existing image"
	@echo "    _ec2_tag_image                   - Tag an existing image"
	@echo "    _ec2_update_image                - Replace an existing image"
	@echo "    _ec2_view_image_attribute        - To display the attributes of AN images"
	@echo "    _ec2_view_image_list             - To display the list of image with same basename"
	@echo "    _ec2_view_image_properties       - To display the properties of one or more images"
	@echo "    _ec2_view_image_states           - To display the states of the images"
	@echo "    _ec2_view_image_tags             - To display the tags attach to AN image"
	@echo "    _ec2_view_image_usage            - To display the instances that are using this image"
	@echo 

_aws_view_makefile_variables :: _ec2_image_view_makefile_variables
_ec2_image_view_makefile_variables:
	@echo "AWS::EC2::Image ($(_AWS_EC2_IMAGE_MK_VERSION)) variables:"
	@echo "    EC2_IMAGE_ATTRIBUTES=$(EC2_IMAGE_ATTRIBUTES)"
	@echo "    EC2_IMAGE_BASENAME=$(EC2_IMAGE_BASENAME)"
	@echo "    EC2_IMAGE_ID=$(EC2_IMAGE_ID)"
	@echo "    EC2_IMAGE_LAUNCH_PERMISSION=$(EC2_IMAGE_LAUNCH_PERMISSION)"
	@echo "    EC2_IMAGE_OWNER=$(EC2_IMAGE_OWNER)"
	@echo "    EC2_IMAGE_OWNERS=$(EC2_IMAGE_OWNERS)"
	@echo "    EC2_IMAGE_PREFIX=$(EC2_IMAGE_PREFIX)"
	@echo "    EC2_IMAGE_SUFFIX=$(EC2_IMAGE_SUFFIX)"
	@echo "    EC2_IMAGE_TAGS=$(EC2_IMAGE_TAGS)"
	@echo "    EC2_SOURCE_IMAGE=$(EC2_SOURCE_IMAGE)"
	@echo "    EC2_SOURCE_REGION=$(EC2_SOURCE_REGION)"
	@echo " C  EC2_IMAGE_IDS=$(EC2_IMAGE_IDS)"
	@echo " C  EC2_IMAGE_NAME=$(EC2_IMAGE_NAME)"
	@echo

#----------------------------------------------------------------------
# AWS OPERATIONS
#

_ec2_create_image:
	@$(INFO) "$(AWS_LABEL)Creating an image of $(EC2_INSTANCE_ID) ..."
	@$(WARN) "If you want to replace an existing image, deregisted it first!"
	@$(NORMAL)
	$(AWS) ec2 create-image --instance-id $(EC2_INSTANCE_ID) $(__NAME) $(__DESCRIPTION)
	@$(WARN) "The image creation process forces a REBOOT of the host that is being imaged."
	@$(WARN) -n "The image creation process can take a few minutes ..."; 
	@while [ -z $${_IMAGE_ID} ]; do \
		_IMAGE_ID=`$(AWS) ec2 describe-images $(__OWNERS)  --filters "Name=name,Values=$(EC2_IMAGE_NAME)" --query 'Images[].ImageId' --output text`; \
        echo -n "." ; sleep 1 ; \
        done; $(INFO) "\n$(AWS_LABEL)Newly created image is: $(EC2_IMAGE_NAME) ($${_IMAGE_ID})"; $(NORMAL)

_ec2_deregister_image:
	@$(INFO) "$(AWS_LABEL)Deregistering image $(EC2_IMAGE_NAME) ..."; $(NORMAL)
  ifneq ($(EC2_IMAGE_ID),)
	$(AWS) ec2 deregister-image $(__IMAGE_ID)
	@$(WARN) "Found an IMAGE_ID with this name: $(EC2_IMAGE_ID)"
	@$(WARN) "Beware: If this image is used in a launch configuration, the autoscale group won't be able to scale out!" 
	@$(WARN) "Beware: If this image is used as a parameter to a cloudformation stack, you won't be able to update the stack!" 
	@$(WARN) -n "The deregistration of an image can take a few minutes ..."; 
	@_IMAGE_ID=$(EC2_IMAGE_ID); while [ ! -z $${_IMAGE_ID} ]; do \
		_IMAGE_ID=`$(AWS) ec2 describe-images $(__OWNERS)  --filters "Name=name,Values=$(EC2_IMAGE_NAME)" --query 'Images[].ImageId' --output text`; \
        echo -n "." ; sleep 1 ; \
        done; echo
	@$(INFO) "$(AWS_LABEL)Deregistered image:  $(EC2_IMAGE_NAME) ($(EC2_IMAGE_ID))"; $(NORMAL)
  else
	@$(WARN) "Could not find an IMAGE_ID with this image name '$(EC2_IMAGE_NAME)' in this region"; $(NORMAL)
  endif 

_ec2_change_launch_permission:
	@$(INFO) "$(AWS_LABEL)Changing launch permission image attribute for $(EC2_IMAGE_ID)"; $(NORMAL)
	@$(WARN) -n "$(AWS_LABEL)Waiting for image to be 'available'...";
	@while [ "$${_IMAGE_STATE}" != "available" ]; do \
		_IMAGE_STATE=`$(AWS) ec2 describe-images $(__OWNERS)  --filters "Name=name,Values=$(EC2_IMAGE_NAME)" --query 'Images[].State' --output text`; \
        echo -n "." ; sleep 1 ; \
        done; $(NORMAL); echo
	$(AWS) ec2 modify-image-attribute $(__IMAGE_ID) $(__LAUNCH_PERMISSION)

_ec2_tag_image:
	@$(INFO) "$(AWS_LABEL)Tagging ami/image: $(EC2_IMAGE_ID) ..."
	@$(WARN) "The image needs to be available in this region for this operation to complete successfully."
	@$(WARN) "If you just created, exported, or copied the image, it may not be accessible yet."
	@$(NORMAL)
	$(AWS) ec2 create-tags $(__IMAGE_TAGS) --resources $(EC2_IMAGE_ID)

_ec2_view_image_list:
	@$(INFO) "$(AWS_LABEL)Fetching images with IMAGE_OWNER=$(EC2_IMAGE_OWNER) and IMAGE_BASENAME=$(EC2_IMAGE_BASENAME)..."; $(NORMAL)
	$(AWS) ec2 describe-images $(__OWNERS) --query "sort_by(Images, &CreationDate)[? contains(Name, '$(EC2_IMAGE_BASENAME)')].$(EC2_VIEW_IMAGE_LIST_FIELDS)"

_ec2_view_image_states:
	@$(INFO) "$(AWS_LABEL)Fetching image states with IMAGE_BASENAME=$(EC2_IMAGE_BASENAME) ..."; $(NORMAL)
	$(AWS) ec2 describe-images $(__OWNERS) --query "sort_by(Images, &CreationDate)[? contains(Name, '$(EC2_IMAGE_BASENAME)')].$(EC2_VIEW_IMAGE_STATES_FIELDS)"

_ec2_view_image_tags:
	$(AWS) ec2 describe-images --query 'Images[0].Tags[]' $(__IMAGE_IDS)

_ec2_view_image_usage:
	@$(INFO) "$(AWS_LABEL)Fetching instances the are using $(EC2_IMAGE_ID)";
	@$(WARN) "The returned results are for the current account: $(AWS_ACCOUNT)"
	@$(WARN) "Beware if the image is shared with other accounts."
	@$(NORMAL)
	$(AWS) ec2 describe-instances --filters "Name=image-id,Values=$(EC2_IMAGE_ID)" --query "Reservations[].Instances[].$(EC2_VIEW_IMAGE_USAGE_FIELDS)"

_ec2_view_image_properties:
	$(AWS) ec2 describe-images $(__IMAGE_IDS) --output json | jq '.'

_ec2_view_image_attributes:
	@$(INFO) "$(AWS_LABEL)Inspecting $(EC2_IMAGE_ID)"; $(NORMAL)
	@$(foreach A, $(EC2_IMAGE_ATTRIBUTES), \
        $(INFO) " * Attribute: $(A)"; \
        $(AWS) ec2 describe-image-attribute $(__IMAGE_ID) --attribute $(A) --output json | jq '.' ; \
    )
