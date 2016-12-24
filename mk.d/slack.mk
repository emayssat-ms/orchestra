_SLACK_MK_VERSION=0.99.0

SLACK_AS_USER?=true
# SLACK_CHANNEL?=slack-channel
# SLACK_FILE?=/path/to/file.png
# SLACK_ICON_EMOJI?=:cloud:
SLACK_LABEL?=[slack] #
SLACK_MESSAGE?=''
# SLACK_NAME?=firstname.lastname
# SLACK_TEAM?=myteam
# SLACK_TOKEN?=xoxp-3136629106-xxxxxxxxxx-xxxxxxxxxx-xxxxxxxxxx
# SLACK_USER?=bob.smith

__CHANNEL?= --channel $(SLACK_CHANNEL)

ifeq ($(SLACK_AS_USER),true)
	__AS?= --as-user
endif

ifneq ($(SLACK_FILE),)
  __FILE?= --file $(SLACK_FILE)
endif

ifneq ($(SLACK_TEAM),)
  __TEAM?= --team $(SLACK_TEAM)
endif

ifneq ($(SLACK_TOKEN),)
  __TOKEN?= --token $(SLACK_TOKEN)
endif

__USER?= --user $(SLACK_USER)

SLACK?=/usr/local/bin/slacker $(__TOKEN) $(__AS) $(__FILE)

#----------------------------------------------------------------------
# INTERFACE
#

_view_makefile_macros :: _slack_view_makefile_macros
_slack_view_makefile_macros :

_view_makefile_targets :: _slack_view_makefile_targets
_slack_view_makefile_targets:
	@echo "SLACK ($(_SLACK_MK_VERSION)) targets:"
	@echo "    _slack_notify_channel       - Send notification to a channel"
	@echo "    _slack_notify_user          - Send notification to a user"
	@echo

_view_makefile_variables :: _slack_view_makefile_variables
_slack_view_makefile_variables:
	@echo "SLACK ($(_SLACK_MK_VERSION)) variables:"
	@echo "    SLACK_AS_USER=$(SLACK_AS_USER)"
	@echo "    SLACK_CHANNEL=$(SLACK_CHANNEL)"
	@echo "    SLACK_ICON_EMOJI=$(SLACK_ICON_EMOJI)"
	@echo "    SLACK_NAME=$(SLACK_NAME)"
	@echo "    SLACK_TEAM=$(SLACK_TEAM)"
	@echo "    SLACK_TOKEN=$(SLACK_TOKEN)"
	@echo "    SLACK_USER=$(SLACK_USER)"
	@echo


#----------------------------------------------------------------------
# 
#

_slack_notify_channel:
	@$(INFO) "$(SLACK_LABEL)Sending notification to slack channel '$(SLACK_CHANNEL)' ..."; $(NORMAL)
	echo "$(SLACK_MESSAGE)" | $(SLACK) $(__CHANNEL) 

_slack_notify_user:
	@$(INFO) "$(SLACK_LABEL)Sending notification to slack user '$(SLACK_USER)' ..."; $(NORMAL)
	echo "$(SLACK_MESSAGE)" | $(SLACK) $(__USER) 
