# Top-level Makefile.am
#
# Copyright (c) 1997-2013 Free Software Foundation, Inc.
#
# This file is part of GNU Zile.
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

ACLOCAL_AMFLAGS = -I m4

LUA_PATH ?= ;
LUA_ENV = LUA_PATH="$(abs_srcdir)/src/?.lua;$(LUA_PATH)"

CLEANFILES =
DISTCLEANFILES =
MAINTAINERCLEANFILES =

install_edit = sed \
	-e 's|@pkgdatadir[@]|$(pkgdatadir)|g' \
	-e 's|@pkgdocdir[@]|$(docdir)|g'

inplace_edit = sed \
	-e 's|@pkgdatadir[@]|$(abs_top_srcdir)/src|g' \
	-e 's|@pkgdocdir[@]|$(abs_top_srcdir)|g'

EXTRA_DIST =						\
	FAQ						\
	GNUmakefile					\
	maint.mk

doc_DATA = AUTHORS FAQ NEWS

include build-aux/Makefile.am
include doc/Makefile.am
include src/Makefile.am
include tests/Makefile.am


## ------------- ##
## Distribution. ##
## ------------- ##

gitlog_to_changelog	= $(srcdir)/build-aux/gitlog-to-changelog
git_log_fix		= $(srcdir)/build-aux/git-log-fix
changelog		= $(srcdir)/ChangeLog

# Changes before this date are from before Lua was used for any of Zile.
changelog_start_date = 2009-03-30
$(changelog): FORCE
	$(AM_V_GEN)if test -d '$(srcdir)/.git'; then \
	  $(gitlog_to_changelog) --amend=$(git_log_fix) \
	      --since=$(changelog_start_date) > '$@T'; \
	  rm -f '$@'; mv '$@T' '$@'; \
	fi

dist-hook: $(changelog)

distcheck-hook: syntax-check

## An empty target to depend on when a rule needs to always run
## whenever it is visited.
FORCE:
