ANSIBLE_MK_VERSION=0.99.2

ANSIBLE_ENVIRONMENT?=$(ENVIRONMENT)
# ANSIBLE_OPTIONS?=
ANSIBLE_INVENTORY_GROUPS?=all
ANSIBLE_USER?=ubuntu
ANSIBLE_BECOME?=true
ANSIBLE_BECOME_USER?=root
ANSIBLE_BECOME_METHOD?=sudo
ANSIBLE_ASK_VAULT_PASS?=false
# ANSIBLE_EXTRA_VARS?=
ANSIBLE_FORK?=5
ANSIBLE_INVENTORY_DIR?=inventories
ANSIBLE_INVENTORY_HOSTS?=127.0.0.1 127.0.0.1
ANSIBLE_INVENTORY_TYPE?=static
# ANSIBLE_LIMIT?=
ANSIBLE_LABEL=[ansible] #
# ANSIBLE_MODULE?=
# ANSIBLE_MODULE_ARGUMENTS?=
# ANSIBLE_OPTIONS?=
ANSIBLE_PLAYBOOK_FILE?=playbook.yml
ANSIBLE_PLAYBOOK_NAME?=hello_world
ANSIBLE_PLAYBOOK_DIR?=$(shell readlink -f ./playbooks)
# ANSIBLE_PLAYBOOK_OPTIONS?=
# ANSIBLE_POOL_INTERVAL?=60
ANSIBLE_PRIVATE_KEY?=$(SSH_KEYPAIR_PEM)
# ANSIBLE_SECRET?=secret_vars.yml
# ANSIBLE_SKIP_TAGS?=
# ANSIBLE_STEP?=
ANSIBLE_TAGS?=all # untagged, tagged, always, and all (default) are reserved tags
# ANSIBLE_TIMEOUT?=3600
# ANSIBLE_VERBOSE?=

#--- Static parameters
# ANSIBLE_TEST_HOST_IP=$(shell dig $(ANSIBLE_TEST_HOST_NAME) +short | tail -1)

ifeq ($(ANSIBLE_INVENTORY_TYPE), list)
  ANSIBLE_INVENTORY?=$(subst $(SPACE),$(COMMA),$(ANSIBLE_INVENTORY_HOSTS)),
endif

ifeq ($(ANSIBLE_INVENTORY_TYPE), static)
  ANSIBLE_INVENTORY?=$(ANSIBLE_INVENTORY_DIR)/hosts.ini
endif


ifeq ($(ANSIBLE_INVENTORY_TYPE), external-ec2)
  # AWS_PROFILE is required to use different cache locations for different accounts
  ANSIBLE_INVENTORY?=$(ANSIBLE_INVENTORY_DIR)/ec2_$(AWS_PROFILE)
  ANSIBLE_INVENTORY_CACHE?=$(shell grep cache_path $(ANSIBLE_INVENTORY_DIR)/ec2.ini | cut -d ' ' -f 3)
endif

__PRIVATE_KEY= $(if $(ANSIBLE_PRIVATE_KEY),--private-key=$(ANSIBLE_PRIVATE_KEY))
__ANSIBLE_INVENTORY= $(if $(ANSIBLE_INVENTORY),-i $(ANSIBLE_INVENTORY))

__ANSIBLE_BECOME_METHOD= $(if $(ANSIBLE_BECOME_METHOD),--become-method=$(ANSIBLE_BECOME_METHOD))
__ANSIBLE_BECOME_USER= $(if $(ANSIBLE_BECOME_USER),--become-user=$(ANSIBLE_BECOME_USER))
__ANSIBLE_BECOME= $(if $(filter true,$(ANSIBLE_BECOME)), --become $(__ANSIBLE_BECOME_METHOD) $(__ANSIBLE_BECOME_USER))

__ANSIBLE_EXTRA_VARS= $(if $(ANSIBLE_EXTRA_VARS),--extra-vars "$(ANSIBLE_EXTRA_VARS)")
__ANSIBLE_FORKS= $(if $(ANSIBLE_FORKS),--forks=$(ANSIBLE_FORKS))
__ANSIBLE_LIMIT= $(if $(ANSIBLE_LIMIT),--limit $(ANSIBLE_LIMIT))
__ANSIBLE_POOL_INTERVAL= $(if $(ANSIBLE_POOL_INTERVAL),--poll=$(ANSIBLE_POOL_INTERVAL))
__ANSIBLE_SKIP_TAGS= $(if $(ANSIBLE_SKIP_TAGS),--skip-tags $(ANSIBLE_SKIP_TAGS))
__ANSIBLE_STEP= $(if $(filter true,$(ANSIBLE_STEP)),--step)
__ANSIBLE_TAGS= $(if $(ANSIBLE_TAGS),--tags $(ANSIBLE_TAGS))
__ANSIBLE_TIMEOUT= $(if $(ANSIBLE_TIMEOUT),--background=$(ANSIBLE_TIMEOUT))
__ANSIBLE_USER= $(if $(ANSIBLE_USER),-u $(ANSIBLE_USER))
__ANSIBLE_ASK_VAULT_PASS= $(if $(filter true,$(ANSIBLE_ASK_VAULT_PASS)),--ask-vault-pass)
__ANSIBLE_VERBOSE+= $(if $(filter true,$(ANSIBLE_VERBOSE)),-vvvv)

__ANSIBLE_COMMON_OPTIONS+=$(__ANSIBLE_VERBOSE) $(__ANSIBLE_USER) $(__ANSIBLE_INVENTORY)
__ANSIBLE_COMMON_OPTIONS+=$(__ANSIBLE_EXTRA_VARS) $(__ANSIBLE_LIMIT)

__ANSIBLE_OPTIONS+=$(__ANSIBLE_COMMON_OPTIONS)
__ANSIBLE_OPTIONS+=$(__ANSIBLE_BECOME) $(__ANSIBLE_FORKS) $(__ANSIBLE_TIMEOUT)

__ANSIBLE_PLAYBOOK_OPTIONS+=$(__ANSIBLE_COMMON_OPTIONS)
__ANSIBLE_PLAYBOOK_OPTIONS+=$(__ANSIBLE_ASK_VAULT_PASS) $(__ANSIBLE_TAGS)
__ANSIBLE_PLAYBOOK_OPTIONS+=$(__ANSIBLE_SKIP_TAGS) $(__ANSIBLE_STEP)

ANSIBLE=$(ANSIBLE_ENVIRONMENT) ansible $(__ANSIBLE_OPTIONS) $(ANSIBLE_OPTIONS)
ANSIBLE_PLAYBOOK=$(ANSIBLE_ENVIRONMENT) ansible-playbook $(__ANSIBLE_PLAYBOOK_OPTIONS)  $(ANSIBLE_PLAYBOOK_OPTIONS)
ANSIBLE_VAULT=$(ANSIBLE_ENVIRONMENT) ansible-vault

#----------------------------------------------------------------------
# USAGE
#

_view_makefile_macros :: _ansible_view_makefile_macros
_ansible_view_makefile_macros:

_view_makefile_targets :: _ansible_view_makefile_targets
_ansible_view_makefile_targets:
	@echo "Ansible ($(ANSIBLE_MK_VERSION)) targets:"
	@echo "    _ansible_change_pasword                - Change the password of a secret file"
	@echo "    _ansible_check_fact_gathering          - Check fact gathering"
	@echo "    _ansible_check_playbook_syntax         - Check the playbook syntax"
	@echo "    _ansible_check_ssh_key                 - Check connectivity with a given private ssh key"
	@echo "    _ansible_check_ssh_connectivity        - Check connectivity with target hosts"
	@echo "    _ansible_create_secret                 - Encrypt a secret file"
	@echo "    _ansible_delete_entire_cache           - Delete of whole local inventory cache"
	@echo "    _ansible_edit_secret                   - Edit a secret file"
	@echo "    _ansible_execute_playbook              - Run ansible playbook"
	@echo "    _ansible_inventory_help                - Command line help on external inventory script"
	@echo "    _ansible_read_playbook                 - Read the playbook"
	@echo "    _ansible_refresh_cache                 - Refresh local inventory cache"
	@echo "    _ansible_remove_key_from_managed_keys  - Remove ssh key from ssh agent"
	@echo "    _ansible_view_cache_profile            - View cache per AWS account"
	@echo "    _ansible_view_inventory                - View inventory however generated"
	@echo "    _ansible_view_secret                   - Display the content of a secret file"
	@echo

_view_makefile_variables :: _ansible_view_makefile_variables
_ansible_view_makefile_variables:
	@echo "Ansible ($(ANSIBLE_MK_VERSION)) variables:"
	@echo "    ANSIBLE=$(ANSIBLE)"
	@echo "    ANSIBLE_ASK_VAULT_PASS=$(ANSIBLE_ASK_VAULT_PASS)"
	@echo "    ANSIBLE_BECOME=$(ANSIBLE_BECOME)"
	@echo "    ANSIBLE_BECOME_METHOD=$(ANSIBLE_BECOME_METHOD)"
	@echo "    ANSIBLE_BECOME_USER=$(ANSIBLE_BECOME_USER)"
	@echo "    ANSIBLE_ENVIRONMENT=$(ANSIBLE_ENVIRONMENT)"
	@echo "    ANSIBLE_EXTRA_VARS=$(ANSIBLE_EXTRA_VARS)"
	@echo "    ANSIBLE_FORKS=$(ANSIBLE_FORKS)"
	@echo "    ANSIBLE_INVENTORY=$(ANSIBLE_INVENTORY)"
	@echo "    ANSIBLE_INVENTORY_GROUPS=$(ANSIBLE_INVENTORY_GROUPS)"
	@echo "    ANSIBLE_INVENTORY_HOSTS=$(ANSIBLE_INVENTORY_HOSTS)"
	@echo "    ANSIBLE_INVENTORY_TYPE=$(ANSIBLE_INVENTORY_TYPE)"
	@echo "    ANSIBLE_LIMIT=$(ANSIBLE_LIMIT)"
	@echo "    ANSIBLE_MODULE=$(ANSIBLE_MODULE)"
	@echo "    ANSIBLE_MODULE_ARGUMENTS=$(ANSIBLE_MODULE_ARGUMENTS)"
	@echo "    ANSIBLE_OPTIONS=$(ANSIBLE_OPTIONS)"
	@echo "    ANSIBLE_PLAYBOOK=$(ANSIBLE_PLAYBOOK)"
	@echo "    ANSIBLE_PLAYBOOK_FILE=$(ANSIBLE_PLAYBOOK_FILE)"
	@echo "    ANSIBLE_PLAYBOOK_NAME=$(ANSIBLE_PLAYBOOK_NAME)"
	@echo "    ANSIBLE_PLAYBOOK_DIR=$(ANSIBLE_PLAYBOOK_DIR)"
	@echo "    ANSIBLE_PLAYBOOK_OPTIONS=$(ANSIBLE_PLAYBOOK_OPTIONS)"
	@echo "    ANSIBLE_POOL_INTERVAL=$(ANSIBLE_POOL_INTERVAL)"
	@echo "    ANSIBLE_PRIVATE_KEY=$(ANSIBLE_PRIVATE_KEY)"
	@echo "    ANSIBLE_SKIP_TAGS=$(ANSIBLE_SKIP_TAGS)"
	@echo "    ANSIBLE_SECRET=$(ANSIBLE_SECRET)"
	@echo "    ANSIBLE_STEP=$(ANSIBLE_STEP)"
	@echo "    ANSIBLE_TAGS=$(ANSIBLE_TAGS)"
	@echo "    ANSIBLE_TEST_HOST_NAME=$(ANSIBLE_TEST_HOST_NAME)"
	@echo "    ANSIBLE_TEST_HOST_IP=$(ANSIBLE_TEST_HOST_IP)"
	@echo "    ANSIBLE_USER=$(ANSIBLE_USER)"
	@echo "    ANSIBLE_VAULT=$(ANSIBLE_VAULT)"
	@echo "    ANSIBLE_VERBOSE=$(ANSIBLE_VERBOSE)"
	@echo


#----------------------------------------------------------------------
# PUBLIC TARGETS
#

_ansible_activate_playbook:
	@$(INFO) "$(ANSIBLE_LABEL)Activating playbook '$(ANSIBLE_PLAYBOOK_NAME) ..."; $(NORMAL)
	rm $(ANSIBLE_PLAYBOOK_FILE)
	ln -s $(ANSIBLE_PLAYBOOK_DIR)/$(ANSIBLE_PLAYBOOK_NAME).yml $(ANSIBLE_PLAYBOOK_FILE)
	ls -al $(ANSIBLE_PLAYBOOK_FILE)


#--- CONNECTIVITY
_ansible_check_ssh_key:
	@$(INFO) "$(ANSIBLE_LABEL)Checking ssh connectivity ..."; $(NORMAL)
	$(ANSIBLE) $(ANSIBLE_INVENTORY_GROUPS) $(__PRIVATE_KEY) -m ping

_ansible_check_ssh_connectivity:
	@$(INFO) "$(ANSIBLE_LABEL)Checking ssh agent configuration ..."; $(NORMAL)
	$(ANSIBLE) $(ANSIBLE_INVENTORY_GROUPS) -m ping

_ansible_check_fact_gathering:
	@$(INFO) "$(ANSIBLE_LABEL)Checking ssh agent configuration and fact gathering..."; $(NORMAL)
	$(ANSIBLE) $(ANSIBLE_INVENTORY_GROUPS) -m setup
	$(ANSIBLE) $(ANSIBLE_INVENTORY_GROUPS) -m ec2_facts

_ansible_create_secret:
	$(ANSIBLE_VAULT) create $(ANSIBLE_SECRET)

_ansible_edit_secret:
	$(ANSIBLE_VAULT) edit $(ANSIBLE_SECRET)

_ansible_list_available_playbooks:
	@ls $(ANSIBLE_PLAYBOOK_DIR)/

_ansible_view_secret:
	$(ANSIBLE_VAULT) view $(ANSIBLE_SECRET)

_ansible_change_password:
	$(ANSIBLE_VAULT) rekey $(ANSIBLE_SECRET)

#--- COMMAND LINE
_ansible_execute_command:
	@$(INFO) "$(INFO_MESSAGE)"; $(NORMAL)
	$(ANSIBLE) $(ANSIBLE_INVENTORY_GROUPS) -m $(ANSIBLE_MODULE) -a "$(ANSIBLE_MODULE_ARGUMENTS)"

#--- INTERACTIONS WITH PLAYBOOK
_ansible_check_playbook_syntax:
	@$(INFO) "$(ANSIBLE_LABEL)Checking playbook syntax ..."; $(NORMAL)
	$(ANSIBLE_PLAYBOOK) --check $(ANSIBLE_PLAYBOOK_FILE)

_ansible_execute_playbook:
	@$(INFO) "$(ANSIBLE_LABEL)Executing the playbook ..."; $(NORMAL)
	$(ANSIBLE_PLAYBOOK) $(ANSIBLE_PLAYBOOK_FILE)

_ansible_read_playbook:
	less $(ANSIBLE_PLAYBOOK_FILE)

_ansible_refresh_cache:
	$(ANSIBLE_INVENTORY) --refresh-cache

_ansible_ping_hosts: _ansible_check_ssh_connectivity

#--- INTERACTIONS WITH INVENTORY
ifeq ($(ANSIBLE_INVENTORY_TYPE),external-ec2)
_ansible_delete_entire_cache:
	rm -rf $(INVENTORY_CACHE)
	mkdir -p $(INVENTORY_CACHE)

_ansible_view_cache_profile:
	ls -al $(INVENTORY_CACHE)

_ansible_view_inventory:
	@# Create a cache inventory
	$(ANSIBLE_INVENTORY) --list | tee $(ANSIBLE_INVENTORY_DIR)/list.out

_ansible_view_inventory_host_properties:
	$(ANSIBLE_INVENTORY) --host $(HOST)

_ansible_inventory_help:
	$(ANSIBLE_INVENTORY) --help

endif

ifeq ($(ANSIBLE_INVENTORY_TYPE),static)
_ansible_view_inventory:
	less $(ANSIBLE_INVENTORY)
endif

ifeq ($(ANSIBLE_INVENTORY_TYPE),dynamic)
endif
