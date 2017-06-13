_AWS_ELASTICSEARCH_MK_VERSION=0.99.4

# ES_ACCESS_POLICIES?=
# ES_ADVANCED_OPTIONS?=
# ES_EBS_OPTIONS?=
# ES_DOMAIN_ARN?=arn:aws:es:us-west-1:374244366136:domain/machine-data
# ES_DOMAIN_ENDPOINT?=
# ES_DOMAIN_ENDPOINT_URL?=$(ES_DOMAIN_PROTOCOL)://$(ES_DOMAIN_ENDPOINT)
ES_DOMAIN_NAME?=$(firstword $(ES_DOMAIN_NAMES))
# ES_DOMAIN_NAMES?=machine-data
# ES_DOMAIN_PROTOCOL?=https
# ES_ELASTICSEARCH_CLUSTER_CONFIG?=
ES_ELASTICSEARCH_VERSION?=5.1
ES_PROXY_LISTEN?= localhost:9200
# ES_PROXY_VERBOSE?= true
# ES_SNAPSHOT_OPTIONS?=

__ADVANCED_OPTIONS?= $(if $(ES_ADVANCED_OPTIONS), --advanced-options $(ES_ADVANCED_OPTIONS))
__ACCESS_POLICIES?= $(if $(ES_ACCESS_POLICIES), --access-policies $(ES_ACCESS_POLICIES))
__DOMAIN_NAME?= $(if $(ES_DOMAIN_NAME), --domain-name $(ES_DOMAIN_NAME))
__DOMAIN_NAMES?= $(if $(ES_DOMAIN_NAMES), --domain-names $(ES_DOMAIN_NAMES))
__EBS_OPTIONS?= $(if $(ES_EBS_OPTIONS), --ebs-options $(ES_EBS_OPTIONS))
__ELASTICSEARCH_CLUSTER_CONFIG?= $(if $(ES_ELASTICSEARCH_CLUSTER_CONFIG), --elasticsearch-cluster-config $(ES_ELASTICSEARCH_CLUSTER_CONFIG))
__ELASTICSEARCH_VERSION?= $(if $(ES_ELASTICSEARCH_VERSION), --elasticsearch-version $(ES_ELASTICSEARCH_VERSION))
__SNAPSHOT_OPTIONS= $(if $(ES_SNAPSHOT_OPTIONS), --snapshot-options $(ES_SNAPSHOT_OPTIONS))

ES_PROXY_BIN?=aws-es-proxy
__ES_PROXY_OPTIONS+= $(if $(ES_PROXY_LISTEN), -listen $(ES_PROXY_LISTEN))
__ES_PROXY_OPTIONS+= $(if $(filter true, $(ES_PROXY_VERBOSE)), -verbose)
ES_PROXY?=$(__ES_PROXY_ENVIRONMENT) $(ES_PROXY_ENVIRONMENT) $(ES_PROXY_BIN) $(__ES_PROXY_OPTIONS) $(ES_PROXY_OPTIONS)

#--- MACROS
get_domain_endpoint_N=$(shell $(AWS) es describe-elasticsearch-domain --domain-name $(1) --query "DomainStatus.Endpoint" --output text)
get_domain_arn_N=$(shell $(AWS) es describe-elasticsearch-domain --domain-name $(1) --query "DomainStatus.ARN" --output text)

#----------------------------------------------------------------------
# USAGE
#

_aws_view_makefile_macros :: _ec2_instance_view_makefile_macros
_es_instance_view_makefile_macros ::
	@echo "AWS::ElasticSearch ($(_AWS_ELASTICSEARCH_MK_VERSION)) macros:" 
	@echo "    get_domain_endpoint_N                - Get the ES endpoint of a domain name (Name)"
	@echo

_aws_view_makefile_targets :: _es_instance_view_makefile_targets
_es_instance_view_makefile_targets ::
	@echo "AWS::ElasticSearch ($(_AWS_ELASTICSEARCH_MK_VERSION)) targets:" 
	@echo "    _es_create_domain                   - Create and ES domain"
	@echo "    _es_describe_domain                 - Displays details on select ES domain"
	@echo "    _es_describe_domains                - Displays details on select ES domains"
	@echo "    _es_list_domain_names               - List all ES domain names"
	@echo "    _es_list_instance_types             - List available instance types for a given ES version"
	@echo "    _es_list_tags                       - List tags attached to a given domain"
	@echo "    _es_list_versions                   - List all ES versions supported/available"
	@echo "    _es_start_local_proxy               - Start a local signature 4 proxy to an ES cluster"
	@echo

_aws_view_makefile_variables :: _es_instance_view_makefile_variables
_es_instance_view_makefile_variables ::
	@echo "AWS::ElasticSearch ($(_AWS_ELASTICSEARCH_MK_VERSION)) variables:"
	@echo "    ES_ACCESS_POLICIES=$(ES_ACCESS_POLICIES)"
	@echo "    ES_ADVANCED_OPTIONS=$(ES_ADVANCED_OPTIONS)"
	@echo "    ES_EBS_OPTIONS=$(ES_EBS_OPTIONS)"
	@echo "    ES_DOMAIN_ARN=$(ES_DOMAIN_ARN)"
	@echo "    ES_DOMAIN_ENDPOINT=$(ES_DOMAIN_ENDPOINT)"
	@echo "    ES_DOMAIN_ENDPOINT_URL=$(ES_DOMAIN_ENDPOINT_URL)"
	@echo "    ES_DOMAIN_NAME=$(ES_DOMAIN_NAME)"
	@echo "    ES_DOMAIN_NAMES=$(ES_DOMAIN_NAMES)"
	@echo "    ES_ELASTICSEARCH_VERSION=$(ES_ELASTICSEARCH_VERSION)"
	@echo "    ES_ELASTICSEARCH_CLUSTER_CONFIG=$(ES_ELASTICSEARCH_CLUSTER_CONFIG)"
	@echo "    ES_PROXY=$(ES_PROXY)"
	@echo "    ES_SNAPSHOT_OPTIONS=$(ES_SNAPSHOT_OPTIONS)"
	@echo

#----------------------------------------------------------------------
# PUBLIC TARGETS
#

_es_create_domain:
	@$(INFO) "$(AWS_LABEL)Displaying metadata on domain '$(ES_DOMAIN_NAME)' ..."; $(NORMAL)
	$(AWS) es create-elasticsearch-domain $(__DOMAIN_NAME) $(__ELASTICSEARCH_VERSION) $(__ELASTICSEARCH_CLUSTER_CONFIG) $(__EBS_OPTIONS) $(__ACCESS_POLICIES) $(__SNAPSHOT_OPTIONS) $(__ADVANCED_OPTIONS)

_es_describe_domain:
	@$(INFO) "$(AWS_LABEL)Displaying metadata on domain '$(ES_DOMAIN_NAME)' ..."; $(NORMAL)
	$(AWS) es describe-elasticsearch-domain $(__DOMAIN_NAME)

_es_describe_domains:
	@$(INFO) "$(AWS_LABEL)Describing ES domains '$(ES_DOMAIN_NAMES)' ..."; $(NORMAL)
	$(AWS) es describe-elasticsearch-domains $(__DOMAIN_NAMES)

_es_list_domain_names:
	@$(INFO) "$(AWS_LABEL)Displaying all elasticsearch domains ..."; $(NORMAL)
	$(AWS) es list-domain-names

_es_list_instance_types:
	@$(INFO) "$(AWS_LABEL)List supported instance types for ES version '$(ES_ELASTICSEARCH_VERSION)' ..."; $(NORMAL)
	$(AWS) es list-elasticsearch-instance-types $(__ELASTICSEARCH_VERSION)

_es_list_tags: ES_DOMAIN_ARN?=$(call get_domain_arn_N, $(ES_DOMAIN_NAME))
_es_list_tags:
	@$(INFO) "$(AWS_LABEL)Displaying tags of domain '$(ES_DOMAIN_NAME)' ..."; $(NORMAL)
	$(AWS) es list-tags --arn $(ES_DOMAIN_ARN)

_es_list_versions:
	@$(INFO) "$(AWS_LABEL)Displaying all elasticsearch versions ..."; $(NORMAL)
	$(AWS) es list-elasticsearch-versions

_es_start_local_proxy: ES_DOMAIN_ENDPOINT_URL?=https://$(call get_domain_endpoint_N, $(ES_DOMAIN_NAME))
_es_start_local_proxy:
	@$(INFO) "$(AWS_LABEL)Starting local signature 4 proxy to ES domain '$(ES_DOMAIN_NAME)' ..."; $(NORMAL)
	@$(WARN) "Use http://$(ES_PROXY_LISTEN)/_plugin/kibana/"; $(NORMAL)
	$(ES_PROXY) -endpoint $(ES_DOMAIN_ENDPOINT_URL)
