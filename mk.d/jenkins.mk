_JENKINS_MK_VERSION=0.99.0

JENKINS_API?=json
JENKINS_BUILD_NUMBER?=lastBuild
# wget $(JENKINS_SERVER_URL)/jnlpJars/jenkins-cli.jar
# JENKINS_CLI_JAR=${HOME}/bin/jenkins-cli.jar
# JENKINS_CLI_PRIVATE_KEY=${HOME}/.ssh/jenkins.key
# JENKINS_CLI_PUBLIC_KEY=${HOME}/.ssh/jenkins.pem
JENKINS_CONSOLE_TAIL?=9999
JENKINS_GROOVY_SCRIPT?=$(JENKINS_GROOVY_SCRIPT_DIR)/hello_world.grv
JENKINS_GROOVY_SCRIPT_DIR?=grv/script
# JENKINS_GROOVY_ARGUMENTS?=
JENKINS_LOGROTATOR?=-1 10
JENKINS_JOB_CONFIG_GRV_DIR?=grv/jobs
JENKINS_JOB_CONFIG_GRV?=$(JENKINS_JOB_CONFIG_GRV_DIR)/$(JENKINS_JOB_NAME).grv
JENKINS_JOB_CONFIG_XML_DIR?=xml/jobs
JENKINS_JOB_CONFIG_XML?=$(JENKINS_JOB_CONFIG_XML_DIR)/$(JENKINS_JOB_NAME).xml
JENKINS_JOB_NAME?=$(word 1, $(JENKINS_JOB_NAMES))
# JENKINS_JOB_NAMES?=
# JENKINS_BUILD_PARAMETERS?=
JENKINS_LABEL?=[jenkins] #
JENKINS_NODE_CONFIG_XML_DIR?=xml/nodes
JENKINS_NODE_CONFIG_XML?=$(JENKINS_NODE_CONFIG_XML_DIR)/$(JENKINS_NODE_NAME).xml
JENKINS_NODE_NAME?=$(word 1, $(JENKINS_NODE_NAMES))
# JENKINS_NODE_NAMES?=
JENKINS_PROFILE?=
# JENKINS_SERVER?=jenkins-ng2.domain.com
JENKINS_SEED_BUILD_NUMBER?=lastBuild
JENKINS_SEED_JOB?=dsl_seed
JENKINS_SEED_JOB_CONFIG_XML?=$(JENKINS_JOB_CONFIG_XML_DIR)/$(JENKINS_SEED_JOB).xml
# JENKINS_SEED_BUILD_PARAMETERS?=
# JENKINS_API_KEY?=12abcdef-1234-1234-abcd-1234567abcdef
# JENKINS_USER?=emayssat-ms
# JENKINS_XML_XPATH?=?xpath=concat(//crumbRequestField,":",//crumb)'
JENKINS_WATCH_INTERVAL?=5

JENKINS_CLI?=java -jar $(JENKINS_CLI_JAR) -s $(JENKINS_SERVER_URL) -i $(JENKINS_CLI_PRIVATE_KEY)

JENKINS_SERVER_URL?=https://$(JENKINS_SERVER)
JENKINS_COMPUTER_URL?=$(JENKINS_SERVER_URL)/computer
JENKINS_JOB_URL?=$(JENKINS_SERVER_URL)/job/$(JENKINS_JOB_NAME)
JENKINS_BUILD_URL?=$(JENKINS_JOB_URL)/$(JENKINS_BUILD_NUMBER)
JENKINS_SEED_JOB_URL?=$(JENKINS_SERVER_URL)/job/$(JENKINS_SEED_JOB)
JENKINS_SEED_BUILD_URL?=$(JENKINS_SEED_JOB_URL)/$(JENKINS_SEED_BUILD_NUMBER)

JENKINS_NEXT_BUILD_NUMBER=$(shell $(CURL) -X POST  $(__USER) "$(JENKINS_JOB_URL)/api/json" | jq -r '.nextBuildNumber' 2>/dev/null)
JENKINS_WAIT_BUILD_NUMBER?=$(JENKINS_NEXT_BUILD_NUMBER)

JENKINS_SEED_NEXT_BUILD_NUMBER=$(shell $(CURL) -X POST  $(__USER) "$(JENKINS_SEED_JOB_URL)/api/json" | jq -r '.nextBuildNumber' 2>/dev/null)
JENKINS_SEED_WAIT_BUILD_NUMBER?=$(JENKINS_SEED_NEXT_BUILD_NUMBER)

__USER= --user $(JENKINS_USER):$(JENKINS_API_KEY)

VIEW_BUILD_PARAMETERS_FIELDS=[.name, .description, .defaultParameterValue.value]

CURL?=curl -s -S

export JENKINS_BUILD_NUMBER
export JENKINS_CONSOLE_TAIL

#----------------------------------------------------------------------
# Usage
#

_view_makefile_macros :: _jenkins_view_makefile_macros
_jenkins_view_makefile_macros:

_view_makefile_targets :: _jenkins_view_makefile_targets
_jenkins_view_makefile_targets:
	@echo "Jenkins:: ($(_JENKINS_MK_VERSION)) targets:"
	@echo "     _jenkins_abort_job            - Abort a running job"
	@echo "     _jenkins_create_job           - Create a job using a seed job"
	@echo "     _jenkins_check_cli            - Check the CLI connection, jar, key"
	@echo "     _jenkins_delete_job           - Delete an existing Jenkins job"
	@echo "     _jenkins_execute_groovy       - Execute groovy script"
	@echo "     _jenkins_start_job            - Start a preconfigured job"
	@echo "     _jenkins_view_build_console   - Display the console output of a specific job"
	@echo "     _jenkins_view_config_xml      - View a job's XML configuration"
	@echo "     _jenkins_view_job_builds      - View a job's builds"
	@echo "     _jenkins_view_job_parameters  - View a job's parameters"
	@echo "     _jenkins_view_job_builds      - View the builds related to a job"
	@echo "     _jenkins_view_nodes           - View nodes on which jobs can run"
	@echo "     _jenkins_watch_build_console  - Watch the console of the current/last build"
	@echo

_view_makefile_variables :: _jenkins_view_makefile_variables
_jenkins_view_makefile_variables:
	@echo "Jenkins:: ($(_JENKINS_MK_VERSION)) variables:"
	@echo "    JENKINS_API_KEY=$(JENKINS_API_KEY)"
	@echo "    JENKINS_BUILD_NUMBER=$(JENKINS_BUILD_NUMBER)"
	@echo "    JENKINS_BUILD_PARAMETERS=$(JENKINS_BUILD_PARAMETERS)"
	@echo "    JENKINS_GROOVY_ARGUMENTS=$(JENKINS_GROOVY_ARGUMENTS)"
	@echo "    JENKINS_GROOVY_SCRIPT=$(JENKINS_GROOVY_SCRIPT)"
	@echo "    JENKINS_JOB_CONFIG_GRV=$(JENKINS_JOB_CONFIG_GRV)"
	@echo "    JENKINS_JOB_NAME=$(JENKINS_JOB_NAME)"
	@echo "    JENKINS_JOB_NAMES=$(JENKINS_JOB_NAMES)"
	@echo "    JENKINS_JOB_URL=$(JENKINS_JOB_URL)"
	@echo "    JENKINS_LOGROTATOR=$(JENKINS_LOGROTATOR)"
	@echo "    JENKINS_NEXT_BUILD_NUMBER=$(JENKINS_NEXT_BUILD_NUMBER)"
	@echo "    JENKINS_NODE_CONFIG_XML=$(JENKINS_CONFIG_XML)"
	@echo "    JENKINS_NODE_NAME=$(JENKINS_NODE_NAME)"
	@echo "    JENKINS_PROFILE=$(JENKINS_PROFILE)"
	@echo "    JENKINS_SEED_BUILD_NUMBER=$(JENKINS_SEED_BUILD_NUMBER)"
	@echo "    JENKINS_SEED_BUILD_PARAMETERS=$(JENKINS_SEED_BUILD_PARAMETERS)"
	@echo "    JENKINS_SEED_JOB=$(JENKINS_SEED_JOB)"
	@echo "    JENKINS_SEED_JOB_CONFIG_XML=$(JENKINS_SEED_JOB_CONFIG_XML)"
	@echo "    JENKINS_SEED_JOB_URL=$(JENKINS_SEED_JOB_URL)"
	@echo "    JENKINS_SEED_NEXT_BUILD_NUMBER=$(JENKINS_SEED_NEXT_BUILD_NUMBER)"
	@echo "    JENKINS_SERVER=$(JENKINS_SERVER)"
	@echo "    JENKINS_SERVER_URL=$(JENKINS_SERVER_URL)"
	@echo "    JENKINS_USER=$(JENKINS_USER)"
	@echo

#----------------------------------------------------------------------
# PRIVATE TARGETS
#

_jenkins_abort_build:
	@$(INFO) "$(JENKINS_LABEL)Aborting build for the job '$(JENKINS_JOB_NAME)' ..."; $(NORMAL)
	$(CURL) -X POST $(__USER) "$(JENKINS_JOB_URL)/$(JENKINS_BUILD_NUMBER)/stop"

_jenkins_create_job:
	@$(INFO) "$(JENKINS_LABEL)Creating the job '$(JENKINS_JOB_NAME)' ..."
	@$(WARN) "Seed job is '$(JENKINS_SEED_JOB)' ..."
	@$(WARN) "Seed build number is '$(JENKINS_SEED_NEXT_BUILD_NUMBER)' ..."
	@$(NORMAL)
	$(CURL) -X POST $(__USER) "$(JENKINS_SEED_JOB_URL)/buildWithParameters?$(subst $(SPACE),&,$(JENKINS_SEED_BUILD_PARAMETERS))"

_jenkins_create_seed_job:
	@$(INFO) "$(JENKINS_LABEL)Creating the seed job '$(JENKINS_SEED_JOB)' ..."; $(NORMAL)
	$(CURL) -X POST $(__USER) -H "Content-Type:application/xml" -d @$(JENKINS_SEED_JOB_CONFIG_XML) "$(JENKINS_SERVER_URL)/createItem?name=$(JENKINS_SEED_JOB)"

_jenkins_delete_job:
	@$(INFO) "$(JENKINS_LABEL)Deleting the job '$(JENKINS_JOB_NAME)' ..."; $(NORMAL)
	$(CURL) -X POST $(__USER) "$(JENKINS_JOB_URL)/doDelete"

_jenkins_check_cli:
	@$(INFO) "$(JENKINS_LABEL)Checking the jenkins cli configuration..."; $(NORMAL)
	$(JENKINS_CLI) help
	# $(JENKINS_CLI) help get-node

_jenkins_create_node:

_jenkins_execute_groovy_script:
	$(JENKINS_CLI) groovy $(JENKINS_GROOVY_SCRIPT) $(JENKINS_GROOVY_ARGUMENTS)

_jenkins_get_job_config_xml:
	@$(INFO) "$(JENKINS_LABEL)Fetching XML configuration for the job '$(JENKINS_JOB_NAME)' ..."; $(NORMAL)
	mkdir -p $(JENKINS_JOB_CONFIG_XML_DIR)
	$(CURL) $(__USER) "$(JENKINS_JOB_URL)/config.xml" | tee $(JENKINS_JOB_CONFIG_XML)

_jenkins_get_node_config_xml:
	@$(INFO) "$(JENKINS_LABEL)Fetching the node configuration of $(JENKINS_NODE_NAME)..."; $(NORMAL)
	mkdir -p $(JENKINS_NODE_CONFIG_XML_DIR)
	$(JENKINS_CLI) get-node '$(JENKINS_NODE_NAME)' | tee $(JENKINS_NODE_CONFIG_XML)

_jenkins_list_nodes:
	@$(INFO) "$(JENKINS_LABEL)List available computers..."; $(NORMAL)
	$(CURL) -X POST $(__USER) "$(JENKINS_COMPUTER_URL)/api/json" | jq -r '.computer[] | "\(.displayName)"'

_jenkins_list_plugins:
	@$(INFO) "$(JENKINS_LABEL)List installed plugins..."; $(NORMAL)
	$(JENKINS_CLI) list-plugins

_jenkins_update_node:
	cat $(JENKINS_NODE_CONFIG_XML) | $(JENKINS_CLI) update--node

_jenkins_start_build:
	@$(INFO) "$(JENKINS_LABEL)Starting build for the job '$(JENKINS_JOB_NAME)' ..."; $(NORMAL)
	@$(WARN) "Jenkins job URL: $(JENKINS_JOB_URL)"; $(NORMAL)
	$(CURL) -X POST $(__USER) "$(JENKINS_JOB_URL)/buildWithParameters?$(subst $(SPACE),&,$(JENKINS_BUILD_PARAMETERS))"

_jenkins_start_groovysh:
	$(JENKINS_CLI) groovysh

_jenkins_update_job: _jenkins_create_job

_jenkins_view_job_builds:
	@$(INFO) "$(JENKINS_LABEL)View builds of job '$(JENKINS_JOB_NAME)' ..."; $(NORMAL)
	$(CURL) -X POST $(__USER) "$(JENKINS_JOB_URL)/api/json" | jq -r '.builds[] | "\(.number) \t \(.url)"' | head -$(word 2,$(JENKINS_LOGROTATOR))

_jenkins_view_build_console:
	@$(INFO) "$(JENKINS_LABEL)View the tailed console output of build '$(JENKINS_BUILD_NUMBER)' of job '$(JENKINS_JOB_NAME)' ..."; $(NORMAL)
	@$(WARN) "URL is $(JENKINS_BUILD_URL)/console"; $(NORMAL)
	@echo
	@#$(CURL) -X POST  $(__USER) "$(JENKINS_BUILD_URL)/logText/progressiveText" | tail -$(JENKINS_CONSOLE_TAIL)
	@$(CURL) -X POST  $(__USER) "$(JENKINS_BUILD_URL)/consoleText" | tail -$(JENKINS_CONSOLE_TAIL)

_jenkins_view_build_metadata:
	@$(INFO) "$(JENKINS_LABEL)View the metadata of build '$(JENKINS_BUILD_NUMBER)' of job'$(JENKINS_JOB_NAME)' ..."; $(NORMAL)
	$(CURL) -X POST  $(__USER) "$(JENKINS_BUILD_URL)/api/json" | jq -r '. | .number, .displayName, .url, .result, .culprits'

_jenkins_view_build_parameters:
	# Not yet tested
	$(CURL) -X POST  $(__USER) "$(JENKINS_BUILD_URL)/api/json" | jq -r '.actions[] | select(._class == hudson.model.ParametersAction)'

_jenkins_view_job_metadata:
	@$(INFO) "$(JENKINS_LABEL)View the metadata of '$(JENKINS_JOB_NAME)' ..."; $(NORMAL)
	$(CURL) -X POST $(__USER) "$(JENKINS_JOB_URL)/api/json" | jq -r '.'

_jenkins_view_job_parameters:
	@$(INFO) "$(JENKINS_LABEL)View the parameters of '$(JENKINS_JOB_NAME)' ..."; $(NORMAL)
	$(CURL) -X POST $(__USER) "$(JENKINS_JOB_URL)/api/json" | jq '.actions[] | if (. | length) > 0 then .parameterDefinitions[] else empty end | {name:.name , description:.description, default_value:.defaultParameterValue.value}'

_jenkins_view_seed_build_console:
	@$(INFO) "$(JENKINS_LABEL)View the tailed console output of the last build seed job '$(JENKINS_SEED_JOB)' ..."; $(NORMAL)
	@$(CURL) -X POST  $(__USER) "$(JENKINS_SEED_BUILD_URL)/logText/progressiveText" | tail -$(JENKINS_CONSOLE_TAIL)

_jenkins_view_seed_build_metadata:
	@$(INFO) "$(JENKINS_LABEL)View the metadata of the last build of job '$(JENKINS_SEED_JOB)' ..."; $(NORMAL)
	$(CURL) -X POST  $(__USER) "$(JENKINS_SEED_BUILD_URL)/api/json" | jq -r '. | .number, .displayName, .url, .result, .culprits'

_jenkins_wait_for_job_completion:
	@$(INFO) -n "$(JENKINS_LABEL)Waiting for completion of build $(JENKINS_JOB_NAME)/$(JENKINS_WAIT_BUILD_NUMBER) ..."
	@while [ "$${_RESULT}" != "SUCCESS" ] && [ "$${_RESULT}" != "FAILURE" ] && [ "$${_RESULT}" != "UNSTABLE"] ; do \
		_RESULT=`$(CURL) -X POST $(__USER) "$(JENKINS_JOB_URL)/$(JENKINS_WAIT_BUILD_NUMBER)/api/json" | jq -r '.result' 2>/dev/null`; \
		echo -n '.'; sleep 1; \
		done; echo;  $(WARN) "Job completed with status: $${_RESULT}"; $(NORMAL)

_jenkins_wait_for_seed_build_completion:
	@$(INFO) -n "$(JENKINS_LABEL)Waiting for completion of seed build '$(JENKINS_SEED_JOB)/$(JENKINS_SEED_WAIT_BUILD_NUMBER)' ..."
	@while [ "$${_RESULT}" != "SUCCESS" ] && [ "$${_RESULT}" != "FAILURE" ] && [ "$${_RESULT}" != "UNSTABLE" ]; do \
		_RESULT=`$(CURL) -X POST $(__USER) "$(JENKINS_SEED_JOB_URL)/$(JENKINS_SEED_WAIT_BUILD_NUMBER)/api/json" | jq -r '.result' 2>/dev/null`; \
		echo -n '.'; sleep 1; \
		done; echo; $(WARN) "Job completed with status: $${_RESULT}"; $(NORMAL)

_jenkins_watch_build_console:
	sleep 2
	watch  -n $(JENKINS_WATCH_INTERVAL) --color "make -e --quiet _jenkins_view_build_console"
