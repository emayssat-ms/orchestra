_TMUXINATOR_MK_VERSION=0.99.0

# TMUXINATOR_ENVIRONMENT?=ENVAR=VALUE
# TMUXINATOR_OPTIONS?=--debug
TMX_LABEL?=[tmux] #
# TMX_PROJECT?=project
TMX_PROJECT_DIR?=$(HOME)/.tmuxinator
TMX_SERVER_SOCKET?=$(TMX_PROJECT)
# TMX_SETTINGS?=

TMX_PROJECT_FILE?=$(TMX_PROJECT_DIR)/$(TMX_PROJECT:=.yml)

TMUXINATOR_BIN?=tmuxinator
TMUXINATOR?=$(__TMUXINATOR_ENVIRONMENT) $(TMUXINATOR_ENVIRONMENT) $(TMUXINATOR_BIN) $(__TMUXINATOR_OPTIONS) $(TMUXINATOR_OPTIONS)

#----------------------------------------------------------------------
# INTERFACE
#

_view_makefile_macros :: _tmx_view_makefile_macros
_tmx_view_makefile_macros ::

_view_makefile_targets :: _tmx_makefile_targets
_tmx_makefile_targets:
	@echo "TMuXinator ($(_TMUXINATOR_MK_VERSION)) targets:"
	@echo "    _tmx_create_local                 - Create a local project"
	@echo "    _tmx_debug_project                - Convert YAML file into a tmux config for a given project"
	@echo "    _tmx_import_projects  			 - Import all project in local project dir"
	@echo "    _tmx_link_local                   - Link local config to local file"
	@echo "    _tmx_list_projects                - List all available projects"
	@echo "    _tmx_start_local                  - Start a local project"
	@echo "    _tmx_start_project                - Start a given project"
	@echo

_view_makefile_variables :: _tmux_view_makefile_variables
_tmux_view_makefile_variables:
	@echo "TMuXinator ($(_TMUXINATOR_MK_VERSION)) variables:"
	@echo "    TMUXINATOR=$(TMUXINATOR)"
	@echo "    TMX_PROJECT_FILE=$(TMX_PROJECT_FILE)"
	@echo "    TMX_PROJECT=$(TMX_PROJECT)"
	@echo "    TMX_SERVER_SOCKET=$(TMX_SERVER_SOCKET)"
	@echo "    TMX_SETTINGS=$(TMX_SETTINGS)"
	@echo


#----------------------------------------------------------------------
# 
#

_tmx_create_local:
	@$(INFO) "$(TMX_LABEL)Create a new local project ..."; $(NORMAL)
	$(TMUXINATOR) new --local

_tmx_debug_project:
	@$(INFO) "$(TMX_LABEL)Debugging project '$(TMX_PROJECT) ..."; $(NORMAL)
	$(TMUXINATOR) debug $(TMX_PROJECT) 

_tmx_list_projects:
	@$(INFO) "$(TMX_LABEL)List all available projects ..."; $(NORMAL)
	$(TMUXINATOR) list

_tmx_import_projects:
	cd $(TMX_PROJECT_DIR); cp *.yml ~/.tmuxinator

_tmx_link_local:
	$(if $(TMX_PROJECT), rm .tmuxinator.yml; ln -s $(TMX_PROJECT_FILE) .tmuxinator.yml,)

_tmx_start_local:
	@$(INFO) "$(TMX_LABEL)Starting local project $(TMX_PROJECT) ..."; $(NORMAL)
	$(TMUXINATOR) local

_tmx_start_project:
	@$(INFO) "$(TMX_LABEL)Starting project $(TMX_PROJECT) ..."; $(NORMAL)
	$(TMUXINATOR) start $(TMX_PROJECT) $(TMX_SETTINGS)
