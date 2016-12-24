_MAKE_MK_VERSION=0.99.1

# MAKE_OPTIONS?= -e -n -p
# MAKE_VARIABLES?= TOTO=1

# MAKE is normally automatically set to 'make' that called!
MAKE?=/my/custom/make


#----------------------------------------------------------------------
# USAGE
#

_view_makefile_macros :: _make_view_makefile_macros
_make_view_makefile_macros:

_view_makefile_targets :: _make_view_makefile_targets
_make_view_makefile_targets:

_view_makefile_variables :: _make_view_makefile_variables
_make_view_makefile_variables :
	@echo "Make ($(_MAKE_MK_VERSION)) variables:"
	@echo "    MAKE=$(MAKE)"
	@echo "    MAKE_OPTIONS=$(MAKE_OPTIONS)"
	@echo "    MAKE_VARIABLES=$(MAKE_VARIABLES)"
	@echo

#----------------------------------------------------------------------
# PRIVATE TARGETS
#
