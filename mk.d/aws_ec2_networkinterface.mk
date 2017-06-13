_AWS_EC2_ELASTICNETWORKINTERFACE_MK_VERSION=0.99.0

#--- INPUT PARAMETERS
# EC2_ENI_ATTACHMENT_ID?=eni-attach-66c4350a
# EC2_ENI_ATTRIBUTES?=attachment
# EC2_ENI_DEVICE_INDEX?=1
# EC2_ENI_DESCRIPTION?=
# EC2_ENI_SUBNET_ID?=
# EC2_ENI_GROUPS?=
# EC2_ENI_NETWORK_INTERFACE_ID?=
# EC2_ENI_NETWORK_INTERFACE_IDS?=
# EC2_ENI_PRIVATE_IP_ADDRESS?=
# EC2_ENI_PRIVATE_IP_ADDRESSES?=
# EC2_ENI_SECONDARY_PRIVATE_IP_ADDRESS_COUNT?=

__ATTACHMENT_ID?= $(if $(EC2_ENI_ATTACHMENT_ID),--attachment-id $(EC2_ENI_ATTACHMENT_ID))
__ATTRIBUTE?= $(if $(EC2_ENI_ATTRIBUTE),--attribute $(EC2_ENI_ATTRIBUTE))
__DEVICE_INDEX?= $(if $(EC2_ENI_DEVICE_INDEX),--device-index $(EC2_ENI_DEVICE_INDEX))
__SUBNET_ID?= $(if $(EC2_ENI_SUBNET_ID),--subnet-id $(EC2_ENI_SUBNET_ID))
__DESCRIPTION?= $(if $(EC2_ENI_DESCRIPTION),--description $(EC2_ENI_DESCRIPTION))
__PRIVATE_IP_ADDRESS?= $(if $(EC2_ENI_PRICATE_IP_ADDRESS),--private-ip-address $(EC2_ENI_PRIVATE_IP_ADDRESS))
__GROUPS?= $(if $(EC2_ENI_GROUPS),--groups $(EC2_ENI_GROUPS))
__NETWORK_INTERFACE_ID?= $(if $(EC2_ENI_INTERFACE_ID),--network-interface-id $(EC2_ENI_INTERFACE_ID))
__NETWORK_INTERFACE_IDS?= $(if $(EC2_ENI_INTERFACE_IDS),--network-interface-ids $(EC2_ENI_INTERFACE_IDS))
__PRIVATE_IP_ADDRESSES?= $(if $(EC2_ENI_PRIVATE_IP_ADDRESSES),--private-ip-addresses $(EC2_ENI_PRIVATE_IP_ADDRESSES))
__SECONDARY_PRIVATE_IP_ADDRESS_COUNT?= $(if $(EC2_ENI_SECONDARY_PRIVATE_IP_ADDRESS_COUNT),--secondary-private-address-count $(EC2_ENI_SECONDARY_PRIVATE_IP_ADDRESS_COUNT))

# EC2_DESCRIBE_NETWORK_INTERFACES_QUERY_FILTER?=?VpcId=vpc-12345678
EC2_VIEW_NETWORK_INTERFACES_FIELDS?=[TagSet[?Key=='Name']|[0].Value,NetworkInterfaceId,VpcId,SubnetId,AvailabilityZone,PrivateIpAddress,Status,Attachment.InstanceId]

#----------------------------------------------------------------------
# USAGE
#

_aws_view_makefile_macros:: _ec2_eni_view_makefile_macros
_ec2_eni_view_makefile_macros:
	@echo "AWS::EC2::ElasticNetworkInterface ($(_AWS_EC2_ELASTICNETWORKINTERFACE_MK_VERSION)) macros:"
	@echo

_aws_view_makefile_targets :: _ec2_eni_view_makefile_targets
_ec2_eni_view_makefile_targets:
	@echo "AWS::EC2::ElasticNetworkInterface ($(_AWS_EC2_ELASTICNETWORKINTERFACE_MK_VERSION)) targets:"
	@echo "    _ec2_attach_network_interface               - Attach an elastic network interface"
	@echo "    _ec2_create_network_interface               - Create an elastic network interface"
	@echo "    _ec2_detach_network_interface               - Detach an elastic network interface"
	@echo "    _ec2_describe_network_interfaces            - Describe existing network interfaces"
	@echo "    _ec2_describe_network_interface_attributes  - Describe network interfaces attributes"
	@echo 

_aws_view_makefile_variables :: _ec2_eni_view_makefile_variables
_ec2_eni_view_makefile_variables:
	@echo "AWS::EC2::ElasticNetworkInterface ($(_AWS_EC2_ELASTICNETWORKINTERFACE_MK_VERSION)) variables:"
	@echo "    EC2_ENI_ATTACHMENT_ID=$(EC2_ENI_ATTACHMENT_ID)"
	@echo "    EC2_ENI_ATTRIBUTES=$(EC2_ENI_ATTRIBUTES)"
	@echo "    EC2_ENI_DESCRIPTION=$(EC2_ENI_DESCRIPTION)"
	@echo "    EC2_ENI_DEVICE_INDEX=$(EC2_ENI_DEVICE_INDEX)"
	@echo "    EC2_ENI_SUBNET_ID=$(EC2_ENI_SUBNET_ID)"
	@echo "    EC2_ENI_GROUPS=$(EC2_ENI_GROUPS)"
	@echo "    EC2_ENI_INTERFACE_ID=$(EC2_ENI_INTERFACE_ID)"
	@echo "    EC2_ENI_INTERFACE_IDS=$(EC2_ENI_INTERFACE_IDS)"
	@echo "    EC2_ENI_PRIVATE_IP_ADDRESS=$(EC2_ENI_PRIVATE_IP_ADDRESS)"
	@echo "    EC2_ENI_PRIVATE_IP_ADDRESSES=$(EC2_ENI_PRIVATE_IP_ADDRESSES)"
	@echo "    EC2_ENI_PRIVATE_IP_ADDRESS_COUNT=$(EC2_ENI_PRIVATE_IP_ADDRESS_COUNT)"
	@echo

#----------------------------------------------------------------------
# PUBLIC TARGETS
#

_ec2_attach_network_interface:
	@$(INFO) "$(AWS_LABEL)Attaching network interface..."; $(NORMAL)
	$(AWS) ec2 attach-network-interface $(__NETWORK_INTERFACE_ID) $(__INSTANCE_ID) $(__DEVICE_INDEX)

_ec2_create_network_interface:
	@$(INFO) "$(AWS_LABEL)Creating a network interface..."; $(NORMAL)
	$(AWS) create-network-interface $(__SUBNET_ID) $(__DESCRIPTION) $(__PRIVATE_IP_ADDRESS) $(__GROUPS) $(__PRIVATE_IP_ADDRESSES) $(__SECONDARY_PRIVATE_IP_ADDRESS_COUNT)

_ec2_detach_network_interface:
	@$(INFO) "$(AWS_LABEL)Detaching network interface..."; $(NORMAL)
	$(AWS) ec2 detach-network-interface $(__ATTACHMENT_ID)

_ec2_view_network_interfaces: __QUERY?=--query "NetworkInterfaces[$(EC2_DESCRIBE_NETWORK_INTERFACES_QUERY_FILTER)].$(EC2_VIEW_NETWORK_INTERFACES_FIELDS)"
_ec2_view_network_interfaces:
	@$(INFO) "$(AWS_LABEL)Describe network interfaces..."; $(NORMAL)
	$(AWS) ec2 describe-network-interfaces $(__NETWORK_INTERFACE_IDS) $(__FILTERS) $(__QUERY)

_ec2_view_network_interface_attributes:
	@$(INFO) "$(AWS_LABEL)Describe network interfaces attributes..."; $(NORMAL)
	$(foreach A, $(ENI_ATTRIBUTES), \
		$(AWS) ec2 describe-network-interface-attribute $(__NETWORK_INTERFACE_ID) --attribute $(A) $(__QUERY) \
	)

