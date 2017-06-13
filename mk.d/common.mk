_COMMON_MK_VERSION=0.99.1

CMN_ASYNC_MODE?=false
CMN_DATE?=$(shell /bin/date)
CMN_DATE_YYYYMMDD:=$(shell date +%Y%m%d)
CMN_DEBUG_MODE?=false
CMN_INTERACTIVE_MODE?=false
CMN_LABEL?=[common] #
CMN_TMP_DIR:=/tmp/$(CMN_DATE_YYYYMMDD)
COMMA=,#
LABEL?=[local] #
# MAKE_ENVIRONMENT?=FOO=1
# MAKE_OPTIONS?= -e -n -p --silent FOO=1
SHELL:=/bin/sh
SPACE=
SPACE+=

INFO?= $(if $(TERM),tput setaf 2;) echo
WARN?= $(if $(TERM),tput setaf 3;) echo -n "<!> "; echo
WARN?= $(if $(TERM),tput setaf 1;) echo -n "[ERROR] "; echo

ifneq (,$(TERM))
  # NORMAL?=tput sgr0
  NORMAL?=echo -n "\033[0m"
  INFO?=tput setaf 2; echo 
  WARN?=tput setaf 3; echo -n "<!> "; echo
  ERROR?=tput setaf 1; echo -n "[ERROR] "; echo
  MK_DIR?=mk.d
else
  NORMAL?=echo -n ''
  INFO?=echo
  WARN?=echo -n "<!> "; echo
  ERROR?=echo -n "[ERROR] "; echo
endif

# MAKE is normally automatically set to 'make' that called!
MAKE=$(__MAKE_ENVIRONMENT) $(MAKE_ENVIRONMENT) make $(__MAKE_OPTIONS) $(MAKE_OPTIONS)

#----------------------------------------------------------------------
# USAGE
#

_install_framework_dependencies :: _cmn_install_framework_dependencies
_cmn_install_framework_dependencies:
	@$(INFO) "$(CMN_LABEL)Installing framework dependencies ..."; $(NORMAL)
	sudo apt-get install --upgrade gmsl

_view_makefile_macros ::

_view_makefile_targets ::

_view_makefile_variables :: _cmn_view_makefile_variables
_cmn_view_makefile_variables : 
	@echo "CoMmoN ($(_COMMON_MK_VERSION)) variables:"
	@echo "    CMN_DATE=$(CMN_DATE)"
	@echo "    CMN_DATE_YYYYMMDD=$(CMN_DATE_YYYYMMDD)"
	@echo "    CMN_DEBUG_MODE=$(CMN_DEBUG_MODE)"
	@echo "    CMN_INTERACTIVE_MODE=$(CMN_INTERACTIVE_MODE)"
	@echo "    CMN_TMP_DIR=$(CMN_TMP_DIR)"
	@echo "    MAKE=$(MAKE)"
	@echo "    MK_DIR=$(MK_DIR)"
	@echo "    SHELL=$(SHELL)"
	@echo "    TERM=$(TERM)"
	@echo

#----------------------------------------------------------------------
# PRIVATE TARGETS
#

-include gmsl

#----------------------------------------------------------------------
# PUBLIC TARGETS
#
