_AWS_EC2_NETWORKINTERFACE_MK_VERSION=0.99.0

#--- INPUT PARAMETERS
# ENI_ATTACHMENT_ID?=eni-attach-66c4350a
# ENI_ATTRIBUTES?=attachment
# ENI_DEVICE_INDEX?=1
# ENI_DESCRIPTION?=
# ENI_SUBNET_ID?=
# ENI_GROUPS?=
# ENI_NETWORK_INTERFACE_ID?=
# ENI_NETWORK_INTERFACE_IDS?=
# ENI_PRIVATE_IP_ADDRESS?=
# ENI_PRIVATE_IP_ADDRESSES?=
# ENI_SECONDARY_PRIVATE_IP_ADDRESS_COUNT?=

ifneq (,$(ENI_ATTACHMENT_ID))
  __ATTACHMENT_ID?= --attachment-id $(ENI_ATTACHMENT_ID)
endif

ifneq (,$(ENI_ATTRIBUTE))
  __ATTRIBUTE?= --attribute $(ENI_ATTRIBUTE)
endif

ifneq (,$(ENI_DEVICE_INDEX))
  __DEVICE_INDEX?= --device-index $(ENI_DEVICE_INDEX)
endif

ifneq (,$(ENI_SUBNET_ID))
  __SUBNET_ID?= --subnet-id $(ENI_SUBNET_ID)
endif

ifneq (,$(ENI_DESCRIPTION))
  __DESCRIPTION?= --description $(ENI_DESCRIPTION)
endif

ifneq (,$(ENI_PRIVATE_IP_ADDRESS))
  __PRIVATE_IP_ADDRESS?= --private-ip-address $(ENI_PRIVATE_IP_ADDRESS)
endif

ifneq (,$(ENI_GROUPS))
  __GROUPS?= --groups $(ENI_GROUPS)
endif

ifneq (,$(ENI_NETWORK_INTERFACE_ID))
  __NETWORK_INTERFACE_ID?= --network-interface-id $(ENI_NETWORK_INTERFACE_ID)
endif

ifneq (,$(ENI_NETWORK_INTERFACE_IDS))
  __NETWORK_INTERFACE_IDS?= --network-interface-ids $(ENI_NETWORK_INTERFACE_IDS)
endif

ifneq (,$(ENI_PRIVATE_IP_ADDRESSES))
  __PRIVATE_IP_ADDRESSES?= --private-ip-addresses $(ENI_PRIVATE_IP_ADDRESSES)
endif

ifneq (,$(ENI_SECONDARY_PRIVATE_IP_ADDRESS_COUNT))
  __SECONDARY_PRIVATE_IP_ADDRESS_COUNT?= --secondary-private-address-count $(ENI_SECONDARY_PRIVATE_IP_ADDRESS_COUNT)
endif


DESCRIBE_NETWORK_INTERFACES_FIELDS?=NetworkInterfaceId,VpcId,SubnetId,AvailabilityZone,PrivateIpAddress,Status,Attachment.InstanceId

#----------------------------------------------------------------------
# USAGE
#

_aws_view_makefile_macros:: _networkinterface_view_makefile_macros
_networkinterface_view_makefile_macros:
	@echo "AWS::EC2::NetworkInterface ($(_AWS_EC2_NETWORKINTERFACE_MK_VERSION)) macros:"
	@echo

_aws_view_makefile_targets :: _networkinterface_view_makefile_targets
_networkinterface_view_makefile_targets:
	@echo "AWS::EC2::NetworkInterface ($(_AWS_EC2_NETWORKINTERFACE_MK_VERSION)) targets:"
	@echo "    _ec2_attach_network_interface               - Attach an elastic network interface"
	@echo "    _ec2_create_network_interface               - Create an elastic network interface"
	@echo "    _ec2_detach_network_interface               - Detach an elastic network interface"
	@echo "    _ec2_describe_network_interfaces            - Describe existing network interfaces"
	@echo "    _ec2_describe_network_interface_attributes  - Describe network interfaces attributes"
	@echo 

_aws_view_makefile_variables :: _networkinterface_view_makefile_variables
_networkinterface_view_makefile_variables:
	@echo "AWS::EC2::NetworkInterface ($(_AWS_EC2_NETWORKINTERFACE_MK_VERSION)) variables:"
	@echo "    ENI_ATTACHMENT_ID=$(ENI_ATTACHMENT_ID)"
	@echo "    ENI_ATTRIBUTES=$(ENI_ATTRIBUTES)"
	@echo "    ENI_DESCRIPTION=$(ENI_DESCRIPTION)"
	@echo "    ENI_DEVICE_INDEX=$(ENI_DEVICE_INDEX)"
	@echo "    ENI_SUBNET_ID=$(ENI_SUBNET_ID)"
	@echo "    ENI_GROUPS=$(ENI_GROUPS)"
	@echo "    ENI_NETWORK_INTERFACE_ID=$(ENI_NETWORK_INTERFACE_ID)"
	@echo "    ENI_NETWORK_INTERFACE_IDS=$(ENI_NETWORK_INTERFACE_IDS)"
	@echo "    ENI_PRIVATE_IP_ADDRESS=$(ENI_PRIVATE_IP_ADDRESS)"
	@echo "    ENI_PRIVATE_IP_ADDRESSES=$(ENI_PRIVATE_IP_ADDRESSES)"
	@echo "    ENI_PRIVATE_IP_ADDRESS_COUNT=$(ENI_PRIVATE_IP_ADDRESS_COUNT)"
	@echo

#----------------------------------------------------------------------
# AWS OPERATIONS
#

_ec2_attach_network_interface:
	@$(INFO) "$(AWS_LABEL)Attaching network interface..."; $(NORMAL)
	$(AWS) ec2 attach-network-interface $(__NETWORK_INTERFACE_ID) $(__INSTANCE_ID) $(__DEVICE_INDEX)

_ec2_create_network_interface:
	@$(INFO) "$(AWS_LABEL)Creating a network interface..."; $(NORMAL)
	$(AWS) create-network-interface $(__SUBNET_ID) $(__DESCRIPTION) $(__PRIVATE_IP_ADDRESS) $(__GROUPS) $(__PRIVATE_IP_ADDRESSES) $(__SECONDARY_PRIVATE_IP_ADDRESS_COUNT)

_ec2_describe_network_interfaces: __QUERY?=--query "NetworkInterfaces[].[$(DESCRIBE_NETWORK_INTERFACES_FIELDS)]"
_ec2_describe_network_interfaces:
	@$(INFO) "$(AWS_LABEL)Describe network interfaces..."; $(NORMAL)
	$(AWS) ec2 describe-network-interfaces $(__NETWORK_INTERFACE_IDS) $(__FILTERS) $(__QUERY)

_ec2_describe_network_interface_attributes:
	@$(INFO) "$(AWS_LABEL)Describe network interfaces attributes..."; $(NORMAL)
	$(foreach A, $(ENI_ATTRIBUTES), \
		$(AWS) ec2 describe-network-interface-attribute $(__NETWORK_INTERFACE_ID) --attribute $(A) $(__QUERY) \
	)

_ec2_detach_network_interface:
	@$(INFO) "$(AWS_LABEL)Detaching network interface..."; $(NORMAL)
	$(AWS) ec2 detach-network-interface $(__ATTACHMENT_ID)
