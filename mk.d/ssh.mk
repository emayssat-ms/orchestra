_SSH_MK_VERSION=0.99.4

# SSH_REMOTE_COMMAND?=/bin/ls
SSH_REMOTE_HOST?=localhost
SSH_REMOTE_PORT?=22
# SSH_REMOTE_USER?=ubuntu
SSH_REMOTE_USER_HOST?= $(if $(SSH_REMOTE_USER),$(SSH_REMOTE_USER)@$(SSH_REMOTE_HOST),$(SSH_REMOTE_HOST))
# SSH_KEYPAIR_COMMENT?=
SSH_KEY_NAME?=$(KEY_NAME)
SSH_KEYPAIR_DIR?=$(KEYPAIR_DIR)
SSH_KEYPAIR_PEM?= $(if $(SSH_KEY_NAME),$(SSH_KEYPAIR_DIR)/$(SSH_KEY_NAME).pem)
SSH_KEYPAIR_PUB?= $(if $(SSH_KEY_NAME),$(SSH_KEYPAIR_DIR)/$(SSH_KEY_NAME).pem.pub)
SSH_KNOWN_HOSTS?=localhost 127.0.0.1
# SSH_HOST_KEY_CHECKING?=true
SSH_LABEL?=[ssh] #
# SSH_OPTIONS?= -v

__SSH_HOST_KEY_CHECKING?= $(if $(filter false,$(SSH_HOST_KEY_CHECKING)),-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no)
__SSH_IDENTITY= $(if $(SSH_KEYPAIR_PEM), -i $(SSH_KEYPAIR_PEM))

__SSH_OPTIONS+= $(__SSH_HOST_KEY_CHECKING)
__SSH_OPTIONS+= $(__SSH_IDENTITY)

SSH?=$(__SSH_ENVIRONMENT) $(SSH_ENVIRONMENT) ssh $(__SSH_OPTIONS) $(SSH_OPTIONS)

__SCP_OPTIONS?= $(__SSH_OPTIONS)

SCP?=$(__SCP_ENVIRONMENT) $(SCP_ENVIRONMENT) scp $(__SCP_OPTIONS) $(SCP_OPTIONS)

#----------------------------------------------------------------------
# INTERFACE
#

_view_makefile_macros :: _ssh_view_makefile_macros
_ssh_view_makefile_macros ::

_view_makefile_targets :: _ssh_makefile_targets
_ssh_makefile_targets:
	@echo "SSH ($(_SSH_MK_VERSION)) targets:"
	@echo "    _ssh_add_key_to_managed_keys         - Add ssh key to ssh agent"
	@echo "    _ssh_create_keypair                  - Create a ssh key pair"
	@echo "    _ssh_delete_hosts_from_known_hosts   - Delete hosts from known host"
	@echo "    _ssh_delete_keypair                  - Delete a ssh key pair"
	@echo "    _ssh_execute                         - Execute commands on a remote host"
	@echo "    _ssh_list_keypair                    - List a ssh key pair"
	@echo "    _ssh_protect_private_key             - Enforce the access right of the private key"
	@echo "    _ssh_remove_key_from_managed_keys    - Remove ssh key from ssh agent"
	@echo "    _ssh_update_keypair                  - Delete and recreate keypair"
	@echo "    _ssh_view_managed_keys               - View keys managed by ssh agent"
	@echo

_view_makefile_variables :: _ssh_view_makefile_variables
_ssh_view_makefile_variables:
	@echo "SSH ($(_SSH_MK_VERSION)) variables:"
	@echo "    SCP=$(SCP)"
	@echo "    SSH=$(SSH)"
	@echo "    SSH_EXECUTE_COMMAND=$(SSH_EXECUTE_COMMAND)"
	@echo "    SSH_KEY_NAME=$(SSH_KEY_NAME)"
	@echo "    SSH_KEYPAIR_COMMENT=$(SSH_KEYPAIR_COMMENT)"
	@echo "    SSH_KEYPAIR_DIR=$(SSH_KEYPAIR_DIR)"
	@echo "    SSH_KEYPAIR_PEM=$(SSH_KEYPAIR_PEM)"
	@echo "    SSH_KEYPAIR_PUB=$(SSH_KEYPAIR_PUB)"
	@echo "    SSH_KNOWN_HOSTS=$(SSH_KNOWN_HOSTS)"
	@echo "    SSH_HOST_KEY_CHECKING=$(SSH_HOST_KEY_CHECKING)"
	@echo "    SSH_OPTIONS=$(SSH_OPTIONS)"
	@echo "    SSH_REMOTE_HOST=$(SSH_REMOTE_HOST)"
	@echo "    SSH_REMOTE_USER=$(SSH_REMOTE_USER)"
	@echo "    SSH_REMOTE_USER_HOST=$(SSH_REMOTE_USER_HOST)"
	@echo


#----------------------------------------------------------------------
# SSH KEY MANAGEMENT
#

#--- Add SSH key in local agent
_ssh_add_key_to_managed_keys: _ssh_protect_private_key
	ssh-add $(SSH_KEYPAIR_PEM)
	ssh-add -l

_ssh_create_keypair: 
	@$(INFO) "$(SSH_LABEL)Creating keypair '$(SSH_KEY_NAME)' ..."; $(NORMAL)
	mkdir -p $(dir $(SSH_KEYPAIR_PEM))
	[ -e $(SSH_KEYPAIR_PEM) ] || ( \
		ssh-keygen -t rsa -f $(SSH_KEYPAIR_PEM) -b 4096 -N '' -v -C "$(SSH_KEYPAIR_COMMENT)" \
		)

_ssh_delete_hosts_from_known_hosts:
	@$(foreach H,$(SSH_KNOWN_HOSTS), \
		$(INFO) "Removing '$(H)' from known hosts file."; $(NORMAL); \
		ssh-keygen -R $(H);	\
	)

_ssh_delete_keypair:
	@$(INFO) "$(SSH_LABEL)Deleting keypair '$(SSH_KEY_NAME)' ..."; $(NORMAL)
	rm -f $(SSH_KEYPAIR_PEM)
	rm -f $(SSH_KEYPAIR_PUB)

_ssh_execute:
	@$(INFO) "$(SSH_LABEL)SSH'ing to $(SSH_REMOTE_HOST) ..."; $(NORMAL)
	$(SSH) $(SSH_REMOTE_USER_HOST) $(SSH_REMOTE_COMMAND)

_ssh_list_keypair:
	@$(INFO) "$(SSH_LABEL)List the keypair '$(SSH_KEY_NAME)' ..."; $(NORMAL)
	@ls -al $(SSH_KEYPAIR_PEM)
	@ls -al $(SSH_KEYPAIR_PUB)

_ssh_protect_private_key:
	@$(INFO) "$(SSH_LABEL)Checking rights on '$(SSH_KEYPAIR_PEM)' ..."; $(NORMAL)
	chmod 600 $(SSH_KEYPAIR_PEM)

_ssh_remove_key_from_managed_keys:
	@$(INFO) "$(SSH_LABEL)Removing from ssh-agent the keypair '$(SSH_KEY_NAME)' ..."; $(NORMAL)
	ssh-add -d $(SSH_KEYPAIR_PEM)
	ssh-add -l

_ssh_update_keypair: _ssh_delete_keypair _ssh_create_keypair

_ssh_view_managed_keys:
	@$(INFO) "$(SSH_LABEL)List keys managed by ssh-agent ..."; $(NORMAL)
	ssh-add -l
