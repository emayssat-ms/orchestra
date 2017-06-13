TESTINFRA_MK_VERSION=0.99.3

# TESTINFRA_ANSIBLE_INVENTORY?=inventories/ec2_$(AWS_PROFILE)
TESTINFRA_BACKEND?=paramiko
TESTINFRA_CAPTURE?=fd
# TESTINFRA_ENFORCE_PEP8?=false
# TESTINFRA_ENVIRONMENT?=FOO=1
# TESTINFRA_EXTRA_SUMMARY?=fEsxXpP
# TESTINFRA_HOSTS?=root@localhost:22,root@127.0.0.1:22
# TESTINFRA_KEYWORDS?=
TESTINFRA_FAILED_FIRST?=false
TESTINFRA_FAILED_ONLY?=false
TESTINFRA_LABEL?=[testinfra] #
# TESTINFRA_MARKERS?=
# TESTINFRA_MAXFAIL?=3
# TESTINFRA_NODE_ID?=
# TESTINFRA_NPROCESS?=3
# TESTINFRA_SSH_CONFIG?=
TESTINFRA_SUDO?=false
# TESTINFRA_TEST_SUITE?=./test_suites
TESTINFRA_TRACEBACK?=long
TESTINFRA_VERBOSE?=false

__ANSIBLE_INVENTORY= $(if $(TESTINFRA_ANSIBLE_INVENTORY), --ansible-inventory=$(TESTINFRA_ANSIBLE_INVENTORY))
__BACKEND= $(if $(filter ansible local paramiko ssh, $(TESTINFRA_BACKEND)), --connection=$(TESTINFRA_BACKEND))
__CAPTURE= $(if $(TESTINFRA_CAPTURE), --capture=$(TESTINFRA_CAPTURE), -s)
__EXTRA_SUMMARY= $(if $(TESTINFRA_EXTRA_SUMMARY), -r $(TESTINFRA_EXTRA_SUMMARY))
__FAILED_FIRST= $(if $(filter true, $(TESTINFRA_FAILED_FIRST)), --ff)
__FAILED_ONLY= $(if $(filter true, $(TESTINFRA_FAILED_ONLY)), --lf)
__HOSTS= $(if $(TESTINFRA_HOSTS), --hosts=$(TESTINFRA_HOSTS))
__KEYWORDS= $(if $(TESTINFRA_KEYWAORDS), -k $(TESTINFRA_KEYWORDS))
__MARKERS= $(if $(TESTINFRA_MARKERS), -m "$(TESTINFRA_MARKERS)")
__MAXFAIL= $(if $(TESTINFRA_MAXFAIL), --maxfail $(TESTINFRA_MAXFAIL))
__NPROCESS= $(if $(TESTINFRA_NPROCESS), -n $(TESTINFRA_NPROCESS))
__SSH_CONFIG= $(if $(TESTINFRA_SSH_CONFIG), --ssh-config $(TESTINFRA_SSH_CONFIG))
__SUDO= $(if $(filter true,$(TESTINFRA_SUDO)), --sudo)
__TRACEBACK= $(if $(TESTINFRA_TRACEBACK), --tb=$(TESTINFRA_TRACEBACK))
__VERBOSE= $(if $(filter true,$(TESTINFRA_VERBOSE)), -v --showlocals)

__TESTINFRA_OPTIONS+= $(__ANSIBLE_INVENTORY)
__TESTINFRA_OPTIONS+= $(__BACKEND)
__TESTINFRA_OPTIONS+= $(__CAPTURE)
__TESTINFRA_OPTIONS+= $(__CONNECTION)
__TESTINFRA_OPTIONS+= $(__EXTRA_SUMMARY)
__TESTINFRA_OPTIONS+= $(__FAILED_FIRST)
__TESTINFRA_OPTIONS+= $(__FAILED_ONLY)
__TESTINFRA_OPTIONS+= $(__HOSTS)
__TESTINFRA_OPTIONS+= $(__KEYWORDS)
__TESTINFRA_OPTIONS+= $(__MARKERS)
__TESTINFRA_OPTIONS+= $(__MAXFAIL)
__TESTINFRA_OPTIONS+= $(__NPROCESS)
__TESTINFRA_OPTIONS+= $(__SUDO)
__TESTINFRA_OPTIONS+= $(__TRACEBACK)
__TESTINFRA_OPTIONS+= $(__VERBOSE)

TESTINFRA=$(TESTINFRA_ENVIRONMENT) $(__TESTINFRA_ENVIRONMENT) testinfra $(__TESTINFRA_OPTIONS) $(TESTINFRA_OPTIONS)

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
	@echo "    TESTINFRA_ANSIBLE_INVENTORY=$(TESTINFRA_ANSIBLE_INVENTORY)"
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
	@echo "    TESTINFRA_SSH_CONFIG=$(TESTINFRA_SSH_CONFIG)"
	@echo "    TESTINFRA_SUDO=$(TESTINFRA_SUDO)"
	@echo "    TESTINFRA_TEST_SUITE=$(TESTINFRA_TEST_SUITE)"
	@echo "    TESTINFRA_VERBOSE=$(TESTINFRA_VERBOSE)"
	@echo

_install_framework_dependencies :: _testinfra_install_framework_dependencies
_testinfra_install_framework_dependencies:
	pip install --upgrade testinfra
	# pip install 'git+https://github.com/philpep/testinfra@master#egg=testinfra'
	# PYTEST Plugins @ http://plugincompat.herokuapp.com/
	pip install --upgrade pytest-colordots
	pip install --upgrade pytest-xdist

#----------------------------------------------------------------------
# PUBLIC KEYS
#

_testinfra_execute_tests: 
	@$(INFO) "$(TESTINFRA_LABEL)Executing tests in $(TESTINFRA_TEST_SUITE)$(TESTINFRA_NODE_ID)"; $(NORMAL)
	$(TESTINFRA) $(TESTINFRA_TEST_SUITE)$(TESTINFRA_NODE_ID)

_testinfra_view_test_markers:
	@$(INFO) "$(TESTINRFA_LABEL)List registered markers"; $(NORMAL)
	testinfra --markers

_testinfra_view_test_fixtures:
	@$(INFO) "$(TESTINFRA_LABEL)List available fixtures"; $(NORMAL)
	testinfra --fixtures
