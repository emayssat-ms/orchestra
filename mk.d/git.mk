GIT_MK_VERSION=0.99.0

# GIT_ALL?=true
# GIT_EDIT?=false
GIT_LABEL?=[git] #
GIT_LOCAL_BRANCH?=$(shell git rev-parse --abbrev-ref HEAD)
GIT_LOCAL_TOP?=$(shell git rev-parse --show-toplevel)
GIT_REMOTE?=origin
# GIT_FORCE?=true
GIT_REMOTE_BRANCH?=$(GIT_LOCAL_BRANCH)

ifeq ($(GIT_ALL),true)
  __ALL?= --all
endif

ifeq ($(GIT_EDIT),false)
  __EDIT?= --no-edit
endif

ifeq ($(GIT_EDIT),true)
  __EDIT?= --edit
endif

ifeq ($(GIT_FORCE),true)
  __FORCE?= --force
endif

#----------------------------------------------------------------------
# USAGE
#

_view_makefile_macros :: _git_view_makefile_macros
_git_view_makefile_macros:
	@#echo "Git ($(GIT_MK_VERSION)) targets:"
	@#echo

_view_makefile_targets :: _git_view_makefile_targets
_git_view_makefile_targets:
	@echo "Git ($(GIT_MK_VERSION)) targets:"
	@echo "    _git_commit_amend         - Commit an amended version of the branch"
	@echo "    _git_push_branch          - Push a local branch to a remote server"
	@echo "    _git_show_config          - Show the configuration of this branch"
	@echo


_view_makefile_variables :: _git_view_makefile_variables
_git_view_makefile_variables:
	@echo "Git ($(GIT_MK_VERSION)) variables:"
	@echo "    GIT_FORCE=$(GIT_FORCE)"
	@echo "    GIT_LOCAL_BRANCH=$(GIT_LOCAL_BRANCH)"
	@echo "    GIT_LOCAL_TOP=$(GIT_LOCAL_TOP)"
	@echo "    GIT_REMOTE=$(GIT_REMOTE)"
	@echo "    GIT_REMOTE_BRANCH=$(GIT_REMOTE_BRANCH)"
	@echo

#-----------------------------------------------------------------------
# PRIVATE TARGETS
#

_git_commit_amend:
	@$(INFO) "$(GIT_LABEL)Amending changes in $(GIT_LOCAL_BRANCH)"; $(NORMAL)
	git commit --amend $(__EDIT) $(__ALL)

_git_push_branch:
	@$(INFO) "$(GIT_LABEL)Pushing $(GIT_LOCAL_BRANCH) --> $(GIT_REMOTE)/$(GIT_REMOTE_BRANCH)"; $(NORMAL)
	git push $(GIT_REMOTE) $(GIT_LOCAL_BRANCH):$(GIT_REMOTE_BRANCH) $(__FORCE)

_git_show_config:
	git config -l
