YAML_CONFIG_MK_VERSION=0.99.0

CFG_INPUT_SEPARATOR?=/#
CFG_OUTPUT_SEPARATOR?= #
CFG_TOP_SECTION?=/#
CFG_CONFIGURATION_FILE?=$(realpath ./configs/default.yml)
CFG_CONFIGURATION_NAME?=default
# CFG_CONFIGURATION_NAMES?=default
CFG_CONFIGURATION_SECTION?=$(CFG_TOP_SECTION)$(CFG_INPUT_SEPARATOR)$(CFG_CONFIGURATION_NAME)

get_configuration_names?=$(shell yaml_walk $(CFG_CONFIGURATION_FILE) --input-separator $(CFG_INPUT_SEPARATOR) --section $(CFG_TOP_SECTION) --max-depth 1 --spaced)

yaml_get_SPD=$(shell yaml_get $(CFG_CONFIGURATION_FILE) --input-separator $(CFG_INPUT_SEPARATOR) --spaced --section $(1) --parameter $(2) --default $(3))

yaml_walk_SLM=$(shell yaml_walk $(CFG_CONFIGURATION_FILE) --input-separator $(CFG_INPUT_SEPARATOR) --spaced --section $(1) --min-depth $(2) --max-depth $(3))

configuration_get_PD=$(call yaml_get_SPD, $(CFG_CONFIGURATION_SECTION), $(1), $(2))

#----------------------------------------------------------------------
# USAGE
#

_view_makefile_macros :: _cfg_view_makefile_macros
_cfg_view_makefile_macros:
	@echo "Yaml:::ConFiG ($(YAML_CONFIG_MK_VERSION)) targets:"
	@echo "    get_configuration_names              - Get a list of available configurations"
	@echo "    yaml_get_SPD                         - Get the value of an entry in a yaml file"
	@echo

_view_makefile_targets :: _cfg_view_makefile_targets
_cfg_view_makefile_targets:
	@echo "Yaml::ConFiG ($(YAML_CONFIG_MK_VERSION)) targets:"
	@echo "    _cfg_validate_configuration_file     - Validates the syntax of a configuration file"
	@echo "    _cfg_view_active_configuration       - Displays the active configuration"
	@echo "    _cfg_view_configuration              - Displays the content of the configuration content"
	@echo "    _cfg_view_available_configurations   - List available configurations"
	@echo


_view_makefile_variables :: _cfg_view_makefile_variables
_cfg_view_makefile_variables:
	@echo "Yaml::ConFiG ($(YAML_CONFIG_MK_VERSION)) variables:"
	@echo "    CFG_CONFIGURATION_FILE=$(CFG_CONFIGURATION_FILE)"
	@echo "    CFG_CONFIGURATION_NAME=$(CFG_CONFIGURATION_NAME)"
	@echo "    CFG_CONFIGURATION_NAMES=$(CFG_CONFIGURATION_NAMES)"
	@echo "    CFG_CONFIGURATION_SECTION=$(CFG_CONFIGURATION_SECTION)"
	@echo "    CFG_INPUT_SEPARATOR=$(CFG_INPUT_SEPARATOR)"
	@echo "    CFG_OUTPUT_SEPARATOR=$(CFG_OUTPUT_SEPARATOR)"
	@echo "    CFG_TOP_SECTION=$(CFG_TOP_SECTION)"
	@echo

#-----------------------------------------------------------------------
# PRIVATE TARGETS
#

__cfg_view_configuration_name:
	@$(INFO) $(CFG_CONFIGURATION_NAME); $(NORMAL)
	@yaml_get -I $(CFG_INPUT_SEPARATOR) -S $(CFG_CONFIGURATION_SECTION) -P description $(CFG_CONFIGURATION_FILE) | cat

#-----------------------------------------------------------------------
# PUBLIC TARGETS
#

_cfg_validate_configuration_syntax:
	yaml_validate $(CFG_CONFIGURATION_FILE)

_cfg_view_active_configuration:
	@echo "---"
	@echo -n "Active configuration: "
	@$(INFO) "$(CFG_CONFIGURATION_NAME)"; $(NORMAL)
	@echo "---"

_cfg_view_configuration:
	yaml_extract -S $(CFG_CONFIGURATION_SECTION) -O /tmp/config.yml $(CFG_CONFIGURATION_FILE)
  ifeq ($(CMN_INTERACTIVE_MODE), true)
	less /tmp/config.yml
  else
	cat /tmp/config.yml
  endif

_cfg_view_configuration_file:
  ifeq ($(CMN_INTERACTIVE_MODE), true)
	less $(CFG_CONFIGURATION_FILE)
  else
	cat $(CFG_CONFIGURATION_FILE)
  endif

_cfg_view_configuration_names: CFG_CONFIGURATION_NAMES?=$(call get_configuration_names)
_cfg_view_configuration_names: _cfg_view_active_configuration
	@$(foreach N, $(sort $(CFG_CONFIGURATION_NAMES)), \
		make -s CFG_CONFIGURATION_NAME=$(N) __cfg_view_configuration_name; \
	)
