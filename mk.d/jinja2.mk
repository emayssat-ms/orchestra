_JINJA2_MK_VERSION=0.99.1

JJ2_OUTPUT_BASENAME?=$(JJ2_TEMPLATE_BASENAME)
# JJ2_OUTPUT_DIR?=out
# JJ2_OUTPUT_EXTENSION?=
JJ2_OUTPUT_FILE?= $(subst $(SPACE),/,$(strip $(JJ2_OUTPUT_DIR) $(JJ2_OUTPUT_NAME)))
JJ2_OUTPUT_NAME?= $(subst $(SPACE),.,$(strip $(JJ2_OUTPUT_BASENAME) $(JJ2_OUTPUT_EXTENSION)))
JJ2_TEMPLATE_BASENAME?=myfile.json
JJ2_TEMPLATE_DIR?= $(realpath ./jj2)
JJ2_TEMPLATE_EXTENSION?=.jj2
JJ2_TEMPLATE_FILE?=$(JJ2_TEMPLATE_DIR)/$(JJ2_TEMPLATE_NAME)
JJ2_TEMPLATE_NAME?=$(JJ2_TEMPLATE_BASENAME)$(JJ2_TEMPLATE_EXTENSION)

__OUTPUT_FILE?= $(if $(JJ2_OUTPUT_FILE),--output-file $(JJ2_OUTPUT_FILE))
__TEMPLATE?= $(if $(JJ2_TEMPLATE_NAME),--template $(JJ2_TEMPLATE_FILE))

JJRENDER_BIN?= jjrender
JJRENDER?= $(__JJRENDER_ENVIRONMENT) $(JJRENDER_ENVIRONMENT) $(JJRENDER_BIN) $(__JJRENDER_OPTIONS) $(JJRENDER_OPTIONS)

#----------------------------------------------------------------------
# USAGE
#

_view_makefile_macros :: _jj2_view_makefile_macros
_jj2_view_makefile_macros:

_view_makefile_targets :: _jj2_view_makefile_targets
_j22_view_makefile_targets:
	@echo "JinJa2 ($(_JINJA2_MK_VERSION)) targets:"
	@echo "    jj2_render_template            - Render a given template"
	@echo

_view_makefile_variables :: _jj2_view_makefile_variables
_jj2_view_makefile_variables:
	@echo "JinJa2 ($(_JINJA2_MK_VERSION)) variables:"
	@echo "    JJ2_OUTPUT_DIR=$(JJ2_OUTPUT_DIR)"
	@echo "    JJ2_OUTPUT_NAME=$(JJ2_OUTPUT_NAME)"
	@echo "    JJ2_TEMPLATE_DIR=$(JJ2_TEMPLATE_DIR)"
	@echo "    JJ2_TEMPLATE_FILE=$(JJ2_TEMPLATE_FILE)"
	@echo "    JJ2_TEMPLATE_NAME=$(JJ2_TEMPLATE_NAME)"
	@echo "    JJRENDER=$(JJRENDER)"
	@echo

#----------------------------------------------------------------------
# PRIVATE TARGETS
#


#----------------------------------------------------------------------
# PUBLIC TARGETS
#


jj2_render_template:
	@$(INFO) "$(JJ2_LABEL)Rendering $(JJ2_OUTPUT_NAME) ..."; $(NORMAL)
	$(JJRENDER) $(__TEMPLATE) $(__OUTPUT_FILE) 
