_COMMON_MK_VERSION=0.99.1

YYMMDD:=$(shell date +%y%m%d)
TMP_DIR:=/tmp/$(YYMMDD)
SHELL:=/bin/sh

DATE=$(shell /bin/date)
DEBUG_MODE?=false
INTERACTIVE_MODE?=true

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

COMMA=,
SPACE=
SPACE+=

-include gmsl

_view_makefile_macros ::

_view_makefile_targets ::

_view_makefile_variables :: _common_view_makefile_variables
_common_view_makefile_variables : _view_makefile_variables_info
	@echo "Common ($(_COMMON_MK_VERSION)) variables:"
	@echo "    DATE=$(DATE)"
	@echo "    DEBUG_MODE=$(DEBUG_MODE)"
	@echo "    INTERACTIVE_MODE=$(INTERACTIVE_MODE)"
	@echo "    TERM=$(TERM)"
	@echo

_view_makefile_variables_info:
	@echo "Variable flags:"
	@echo "    - Input parameter"
	@echo "?   - Variable is avaible only under certain conditions"
	@echo " C  - Variable is computed based on the value of other variables"
	@echo "  A - Variable is fetched from the network (Fetch from AWS or other)"
	@$(WARN) "Internet access may be required for A variables"; $(NORMAL)
	@echo
