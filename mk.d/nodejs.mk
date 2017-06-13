_NODEJS_MK_VERSION=0.99.0

NJS_LABEL?=[nodejs] #
# NJS_MODULE?=
# NJS_MODULES?=
# NJS_MODULES_PREFIX?=
NJS_NODE_VERSION?= 4.3

__PREFIX?= $(if $(NJS_MODULES_PREFIX),--prefix $(NJS_MODULES_PREFIX))

#----------------------------------------------------------------------
# USAGE
#

_install_framework_dependencies :: _njs_install_framework_dependencies

_view_makefile_macros ::

_view_makefile_targets :: _njs_view_makefile_targets
_njs_view_makefile_targets ::
	@echo "NodeJS ($(_NODEJS_MK_VERSION)) targets:"
	@echo "    _njs_install_modules         - Install nodejs modules with npm"
	@echo "    _njs_uninstall_modules       - Uninstall nodejs modules with npm"
	@echo

_view_makefile_variables :: _njs_view_makefile_variables
_njs_view_makefile_variables:
	@echo "NodeJS ($(NODE_MK_VERSION)) variables:"
	@echo "    NJS_MODULES=$(NJS_MODULES)"
	@echo "    NJS_MODULES_PREFIX=$(NJS_MODULE_PREFIX)"
	@echo

#----------------------------------------------------------------------
# PRIVATE TARGETS
#

#----------------------------------------------------------------------
# PUBLIC TARGETS
#

_njs_install_modules:
  ifneq ($(NJS_MODULES),)
	@$(INFO) "$(NJS_LABEL)Installing nodejs modules ..."; $(NORMAL)
	@$(WARN) "Modules: $(NJS_MODULES)"; $(NORMAL)
	npm install $(NJS_MODULES) $(__PREFIX)
  endif

_njs_uninstall_modules:
  ifneq ($(NJS_MODULES),)
	@$(INFO) "$(NJS_LABEL)Removing nodejs modules ..."; $(NORMAL)
	@$(WARN) "Modules: $(NJS_MODULES)"; $(NORMAL)
	npm uninstall -g $(NJS_MODULES) $(NJS_MODULE_DIR)
  endif

#----------------------------------------------------------------------
# CONDITIONAL PUBLIC TARGETS
#

ifeq ($(MAKELEVEL),0)
  _njs_install_framework_dependencies:
	@$(INFO) "$(NJS_LABEL)Installing framework dependencies ..."; $(NORMAL)
	@$(WARN) "Procedure @ http://www.hostingadvice.com/how-to/install-nodejs-ubuntu-14-04/#node-version-manager"; $(NORMAL)
	curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh | bash
	bash -c "$(MAKE) _njs_install_framework_dependencies"
else
  _njs_install_framework_dependencies:
	@# Source @ http://stackoverflow.com/questions/25175546/source-shell-script-into-makefile
	@$(WARN) "You will have to resource your environment for changes to take effect."; $(NORMAL)
	@$(WARN) "Reopening a terminal should do the trick!"; $(NORMAL)
	bash -c "source ~/.bashrc; command -v nvm; nvm ls-remote; nvm install $(NJS_NODE_VERSION); nvm use $(NJS_NODE_VERSION); nvm alias default node"
endif
