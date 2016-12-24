TESTINFRA_MK_VERSION=0.99.3

# TESTINFRA_PARAMIKO_SUDO?=
# TESTINFRA_PARAMIKO_SSH_CONFIG?=
# TESTINFRA_TESTS?=test_suite
TESTINFRA_BACKEND?=paramiko
TESTINFRA_CAPTURE?=fd
# TESTINFRA_ENVIRONMENT?=
# TESTINFRA_EXTRA_SUMMARY?=fEsxXpP
# TESTINFRA_HOSTS?=root@localhost:22,root@127.0.0.1:22
# TESTINFRA_KEYWORDS?=
# TESTINFRA_FAILED_FIRST?=
# TESTINFRA_FAILED_ONLY?=
TESTINFRA_LABEL?=[testinfra] #
# TESTINFRA_MARKERS?=
# TESTINFRA_MAXFAIL?=
# TESTINFRA_NODE_ID?=
# TESTINFRA_NPROCESS?=

TESTINFRA_TRACEBACK?=long
# TESTINFRA_VERBOSE?=

ifeq ($(TESTINFRA_VERBOSE), true)
  __TESTINFRA_OPTIONS+= -v
  __TESTINFRA_OPTIONS+= --showlocals
  # __TESTINFRA_OPTIONS+= --pdb
endif

ifeq ($(TESTINFRA_BACKEND),local)
  __CONNECTION= --connection=local
  ifeq ($(TESTINFRA_LOCAL_SUDO),true)
    __CONNECTION+= --sudo
  endif
endif

ifeq ($(TESTINFRA_BACKEND),paramiko)
  __CONNECTION= --connection=paramiko
  ifeq ($(TESTINFRA_PARAMIKO_SUDO),true)
    __CONNECTION+= --sudo
  endif
  ifneq ($(TESTINFRA_PARAMIKO_SSH_CONFIG),)
    __CONNECTION+= --ssh-config $(SSH_CONFIG)
  endif
endif

ifeq ($(TESTINFRA_BACKEND),ssh)
  __CONNECTION= --connection=ssh
endif

ifeq ($(TESTINFRA_BACKEND),ansible)
  __CONNECTION= --connection=ansible
  ifeq ($(INVENTORY_TYPE),ec2)
    __CONNECTION+= --ansible-inventory=inventories/ec2_$(AWS_PROFILE)
  endif
endif

__CAPTURE= -s
ifneq ($(TESTINFRA_CAPTURE),)
  __CAPTURE= --capture=$(TESTINFRA_CAPTURE)
endif

ifneq ($(TESTINFRA_KEYWORDS),)
  __KEYWORDS= -k $(TESTINFRA_KEYWORDS)
endif

ifeq ($(TESTINFRA_FAILED_FIRST), true)
  __FAILED_FIRST= --ff
endif

ifeq ($(TESTINFRA_FAILED_ONLY), true)
  __FAILED_ONLY= --lf
endif

ifneq ($(TESTINFRA_MARKERS),)
	__MARKERS= -m "$(TESTINFRA_MARKERS)"
endif

ifneq ($(TESTINFRA_MAXFAIL),)
  __MAXFAIL= --maxfail $(TESTINFRA_MAXFAIL)
endif

ifneq ($(TESTINFRA_NPROCESS),)
ifneq ($(TESTINFRA_NPROCESS), 1)
  __NPROCESS= -n $(TESTINFRA_NPROCESS)
endif
endif

ifneq (,$(TESTINFRA_EXTRA_SUMMARY))
  __EXTRA_SUMMARY= -r $(TESTINFRA_EXTRA_SUMMARY)
endif

ifneq ($(TESTINFRA_TRACEBACK),)
  __TRACEBACK= --tb=$(TESTINFRA_TRACEBACK)
endif

ifneq ($(TESTINFRA_HOSTS),)
  __HOSTS= --hosts=$(TESTINFRA_HOSTS)
endif

__TESTINFRA_OPTIONS+= $(__CAPTURE)
__TESTINFRA_OPTIONS+= $(__CONNECTION)
__TESTINFRA_OPTIONS+= $(__FAILED_FIRST)
__TESTINFRA_OPTIONS+= $(__FAILED_ONLY)
__TESTINFRA_OPTIONS+= $(__HOSTS)
__TESTINFRA_OPTIONS+= $(__KEYWORDS)
__TESTINFRA_OPTIONS+= $(__MARKERS)
__TESTINFRA_OPTIONS+= $(__MAXFAIL)
__TESTINFRA_OPTIONS+= $(__NPROCESS)
__TESTINFRA_OPTIONS+= $(__EXTRA_SUMMARY)
__TESTINFRA_OPTIONS+= $(__TRACEBACK)
__TESTINFRA_OPTIONS+= $(TESTINFRA_OPTIONS)

__TESTINFRA_ENVIRONMENT+=$(TESTINFRA_ENVIRONMENT)
TESTINFRA=$(__TESTINFRA_ENVIRONMENT) testinfra $(__TESTINFRA_OPTIONS)

#----------------------------------------------------------------------
# USAGE
#

_view_makefile_macros :: _testinfra_view_makefile_macros
_testinfra_view_makefile_macros:

_view_makefile_targets :: _testinfra_view_makefile_targets
_testinfra_view_makefile_targets:
	@echo "Testinfra:: ($(TESTINFRA_MK_VERSION)) targets:"
	@echo "    _testinfra_execute_tests               - Run the tests on hosts"
	@echo "    _testinfra_view_test_markers           - Show the pytest markers attached to a test"
	@echo "    _testinfra_view_test_fixtures          - Show the default and custom fixtures"
	@echo

_view_makefile_variables :: _testinfra_view_makefile_variables
_testinfra_view_makefile_variables:
	@echo "Testinfra:: ($(TESTINFRA_MK_VERSION)) variables:"
	@echo "    TESTINFRA_BACKEND=$(TESTINFRA_BACKEND)"
	@echo "    TESTINFRA_CAPTURE=$(TESTINFRA_CAPTURE)"
	@echo "    TESTINFRA_ENVIRONMENT=$(TESTINFRA_ENVIRONMENT)"
	@echo "    TESTINFRA_EXTRA_SUMMARY=$(TESTINFRA_EXTRA_SUMMARY)"
	@echo "    TESTINFRA_FAILED_FIRST=$(TESTINFRA_FAILED_FIRST)"
	@echo "    TESTINFRA_FAILED_ONLY=$(TESTINFRA_FAILED_ONLY)"
	@echo "    TESTINFRA_HOSTS=$(TESTINFRA_HOSTS)"
	@echo "    TESTINFRA_LABEL=$(TESTINFRA_LABEL)"
	@echo "    TESTINFRA_MAXFAIL=$(TESTINFRA_MAXFAIL)"
	@echo "    TESTINFRA_KEYWORDS=$(TESTINFRA_KEYWORDS)"
	@echo "    TESTINFRA_MARKERS=$(TESTINFRA_MARKERS)"
	@echo "    TESTINFRA_NODE_ID=$(TESTINFRA_NODE_ID)"
	@echo "    TESTINFRA_NPROCESS=$(TESTINFRA_NPROCESS)"
	@echo "    TESTINFRA_OPTIONS=$(TESTINFRA_OPTIONS)"
	@echo "    TESTINFRA_PARAMIKO_SSH_CONFIG=$(TESTINFRA_PARAMIKO_SSH_CONFIG)"
	@echo "    TESTINFRA_PARAMIKO_SUDO=$(TESTINFRA_PARAMIKO_SUDO)"
	@echo "    TESTINFRA_TESTS=$(TESTINFRA_TESTS)"
	@echo


#----------------------------------------------------------------------
# PUBLIC KEYS
#

_testinfra_execute_tests: 
	@$(INFO) "$(TESTINFRA_LABEL)Executing tests in $(TESTINFRA_TESTS)$(TESTINFRA_NODE_ID)"; $(NORMAL)
	$(TESTINFRA) $(TESTINFRA_TESTS)$(TESTINFRA_NODE_ID)

_testinfra_view_test_markers:
	@$(INFO) "$(TESTINRFA_LABEL)List registered markers"; $(NORMAL)
	testinfra --markers

_testinfra_view_test_fixtures:
	@$(INFO) "$(TESTINFRA_LABEL)List available fixtures"; $(NORMAL)
	testinfra --fixtures
