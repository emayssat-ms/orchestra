_AWS_S3_MK_VERSION=0.99.1

# S3_CANNED_ACL?=private
S3_BUCKET_URI?=s3://$(S3_BUCKET_NAME)
S3_BUCKET_LOCATION?=us-east-1
S3_BUCKET_NAME?=mybucket
# S3_LIFECYCLE_CONFIGURATION?='{ "Rules": [{ "Status": "Enabled", "ID": "Delete all objects after 1 day", "Prefix": "", "Expiration": { "Days": 1 } }]}'
S3_OBJECT_KEY?=
S3_OBJECT_URI?=$(S3_BUCKET_URI)/$(S3_OBJECT_KEY)
S3_WEBSITE_URL?=http://$(S3_BUCKET_NAME).s3-website-$(S3_BUCKET_LOCATION).amazonaws.com
S3_OBJECT_URL?=$(S3_WEBSITE_URL)/$(S3_OBJECT_KEY)


__S3_REGION?=
ifneq ($(S3_BUCKET_LOCATION),)
  __S3_REGION=--region $(S3_BUCKET_LOCATION)
endif

AWS_S3?=aws $(__PROFILE) $(__S3_REGION) s3
AWS_S3API?=aws $(__PROFILE) s3api 
S3CMD?=s3cmd --config $(HOME)/.s3cfg


__BUCKET?= --bucket $(S3_BUCKET_NAME)

# S3_GRANTS_FULL?= full=emailaddress=user@example.com
# S3_GRANTS_READ?= read=uri=http://acs.amazonaws.com/groups/global/AllUsers
# S3_GRANTS_READ_TAG?= 
# S3_GRANTS_WRITE?= write=uri=http://acs.amazonaws.com/groups/global/AllUsers
# S3_GRANTS_WRITE_ACP?= 
# S3_GRANTS_WRITE_TAG?= 
S3_GRANTS?=$(strip $(S3_GRANTS_FULL) $(S3_GRANTS_READ) $(S3_GRANTS_WRITE))

ifneq ($(S3_GRANTS),)
__GRANTS?= --grants $(S3_GRANTS)
endif

ifneq ($(S3_CANNED_ACL),)
__ACL?= --acl $(S3_CANNED_ACL)
endif

__LIFECYCLE_CONFIGURATION?= --lifecycle-configuration $(S3_LIFECYCLE_CONFIGURATION)

CURL?= curl -s

#----------------------------------------------------------------------
# USAGE
#
_aws_view_makefile_macros :: _s3_view_makefile_macros
_s3_view_makefile_macros ::

_aws_view_makefile_targets :: _s3_view_makefile_targets
_s3_view_makefile_targets:
	@echo "AWS::S3 ($(_AWS_S3_MK_VERSION)) targets:"
	@echo "     _s3_copy_from                       - Copy a file from S3 to localhost"
	@echo "     _s3_copy_to                         - Copy a file from localhost to S3"
	@echo "     _s3_create_bucket                   - Create a S3 buckets with affinity to the current region"
	@echo "     _s3_create_bucket                   - Create a S3 buckets with affinity to the current region"
	@echo "     _s3_view_bucket_list                - List available S3 buckets"
	@echo "     _s3_view_bucket_location            - Show the location/region of an S3 bucket"
	@echo

_aws_view_makefile_variables :: _s3_view_makefile_variables
_s3_view_makefile_variables:
	@echo "AWS::S3 ($(_AWS_S3_MK_VERSION)) variables:"
	@echo "    LO_RESOURCE_PATH=$(LO_RESOURCE_PATH)"
	@echo "    S3_BUCKET_LOCATION=$(S3_BUCKET_LOCATION)"
	@echo "    S3_BUCKET_NAME=$(S3_BUCKET_NAME)"
	@echo "    S3_BUCKET_URI=$(S3_BUCKET_URI)"
	@echo "    S3_CANNED_ACL=$(S3_CANNED_ACL)"
	@echo "    S3_GRANTS_FULL=$(S3_GRANTS_FULL)"
	@echo "    S3_GRANTS_READ=$(S3_GRANTS_READ)"
	@echo "    S3_GRANTS_WRITE=$(S3_GRANTS_WRITE)"
	@echo "    S3_OBJECT_KEY=$(S3_OBJECT_KEY)"
	@echo "    S3_OBJECT_URI=$(S3_OBJECT_URI)"
	@echo "    S3_OBJECT_URL=$(S3_OBJECT_URL)"
	@echo "    S3_WEBSITE_URL=$(S3_WEBSITE_URL)"
	@echo

#----------------------------------------------------------------------
# PRIVATE TARGETS
#

_s3_copy_from:
	@$(INFO) "$(AWS_LABEL)Fetching $(LO_RESOURCE_PATH) from S3 ..."; $(NORMAL)
	$(AWS_S3) cp $(S3_OBJECT_URI) $(LO_RESOURCE_PATH)

_s3_copy_to:
	@$(INFO) "$(AWS_LABEL)Copying $(LO_RESOURCE_PATH) to S3 ..."; $(NORMAL)
	$(AWS_S3) cp $(LO_RESOURCE_PATH) $(S3_OBJECT_URI) $(__GRANTS) 

_s3_create_bucket:
	@$(INFO) "$(AWS_LABEL)Creating bucket '$(S3_BUCKET_URI)' ..."; $(NORMAL)
	$(AWS_S3) $(__REGION) mb $(S3_BUCKET_URI)
	@$(WARN) "$(AWS_LABEL)Bucket's region affinity (aka LocationContraint) is $(AWS_REGION)"; $(NORMAL)

_s3_curl_object_url:
	@$(INFO) "$(AWS_LABEL)Fetching object '$(S3_OBJECT_URI)' using URL ..."; $(NORMAL)
	$(CURL) $(S3_OBJECT_URL) | tail -20

_s3_put_bucket_lifecycle:
	$(AWS_S3API) put-bucket-lifecycle $(__BUCKET) $(__LIFECYCLE_CONFIGURATION)

_s3_view_bucket_list:
	@$(INFO) "$(AWS_LABEL)Listing available buckets ..."; $(NORMAL)
	$(AWS_S3) ls

_s3_view_bucket_location:
	@$(INFO) "$(AWS_LABEL)Examining bucket '$(S3_BUCKET_NAME)' ..."; $(NORMAL)
	$(AWS_S3API) get-bucket-location $(__BUCKET) 
