_NETCAT_MK_VERSION=0.99.0

NCT_LABEL?=[nc] #
# NCT_OPTIONS?=
NCT_REMOTE_HOST?=localhost
NCT_REMOTE_PORT?=4321
NCT_SCAN_ONLY?=false
NCT_TIMEOUT?=1
NCT_WAIT_TIMEOUT?=300

__NCT_OPTIONS+= $(if $(NCT_TIMETOUT),-w $(NCT_TIMEOUT))
__NCT_OPTIONS+= $(if $(filter true,$(NCT_SCAN_ONLY)),-z)

NCT_WAIT_TIMEOUT_LOOP_IDX?=$(call divide, $(NCT_WAIT_TIMEOUT), $(NCT_TIMEOUT))

NETCAT?=/bin/nc $(__NCT_OPTIONS) $(NCT_OPTIONS)

#----------------------------------------------------------------------
# INTERFACE
#

_view_makefile_macros :: _nct_view_makefile_macros
_nct_view_makefile_macros:

_view_makefile_targets :: _nct_view_makefile_targets
_nct_view_makefile_targets:
	@echo "NetCaT ($(_NETCAT_MK_VERSION)) targets:"
	@echo "    _nct_wait_for_remote_port              - Wait until the remote port is open"
	@echo

_view_makefile_variables :: _nct_view_makefile_variables
_nct_view_makefile_variables:
	@echo "NetCaT ($(_NETCAT_MK_VERSION)) variables:"
	@echo "    NETCAT=$(NETCAT)"
	@echo "    NCT_REMOTE_HOST=$(NCT_REMOTE_HOST)"
	@echo "    NCT_REMOTE_PORT=$(NCT_REMOTE_PORT)"
	@echo "    NCT_SCAN_ONLY=$(NCT_SCAN_ONLY)"
	@echo "    NCT_TIMEOUT=$(NCT_TIMEOUT)"
	@echo "    NCT_WAIT_TIMEOUT=$(NCT_WAIT_TIMEOUT)"
	@echo "    NCT_WAIT_TIMEOUT_LOOP_IDX=$(NCT_WAIT_TIMEOUT_LOOP_IDX)"
	@echo

#----------------------------------------------------------------------
#  PRIVATE TARGETS
#

_nct_wait_for_remote_port:
	@$(INFO) "$(NCT_LABEL)Waiting for open socket '$(NCT_REMOTE_HOST):$(NCT_REMOTE_PORT)' ..."; $(NORMAL)
	@$(WARN) "Timeout set at $(NCT_WAIT_TIMEOUT)"; $(NORMAL)
	@_C=0; until [ $$_C -gt $(NCT_WAIT_TIMEOUT_LOOP_IDX) ] || $(NETCAT) $(NCT_REMOTE_HOST) $(NCT_REMOTE_PORT); do \
		echo -n '.'; _C=$$(($$_C+1)); sleep 1; done; \
		if [ $$_C -gt $(NCT_WAIT_TIMEOUT_LOOP_IDX) ]; then echo 'TIMED OUT!'; exit 1; fi; \
		echo;
