# zmacs Makefile.am
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


## ------------ ##
## Environment. ##
## ------------ ##

ZMACS_PATH = $(abs_buiddir)/zmacs/?.lua;$(abs_srcdir)/zmacs/?.lua


## ------------- ##
## Declarations. ##
## ------------- ##

zmacsdatadir = $(datadir)/zmacs
zmacscmdsdir = $(zmacsdatadir)/commands

zmacs_install_edit =					\
	$(install_edit)					\
	-e 's|@zmacsdatadir[@]|$(zmacsdatadir)|g'	\
	-e 's|@builddir[@]/?.lua;||'			\
	$(NOTHING_ELSE)

zmacs_inplace_edit =					\
	$(inplace_edit)					\
	-e 's|@zmacsdatadir[@]|$(abs_srcdir)/zmacs|g'	\
	-e 's|@builddir[@]|$(abs_builddir)/zmacs|g'	\
	$(NOTHING_ELSE)


## ------ ##
## Build. ##
## ------ ##

doc_DATA += zmacs/dotzmacs.sample

bin_SCRIPTS += zmacs/zmacs

man_MANS += zmacs/zmacs.1

## $(srcdir) prefixes are required when passing $(dist_zmacscmds_DATA)
## to zlc in the build tree with a VPATH build, otherwise it fails to
## find them in $(builddir)/zmacs/commands/*.
dist_zmacscmds_DATA =					\
	$(srcdir)/zmacs/commands/bind.zl		\
	$(srcdir)/zmacs/commands/buffer.zl		\
	$(srcdir)/zmacs/commands/edit.zl		\
	$(srcdir)/zmacs/commands/file.zl		\
	$(srcdir)/zmacs/commands/killring.zl		\
	$(srcdir)/zmacs/commands/help.zl		\
	$(srcdir)/zmacs/commands/line.zl		\
	$(srcdir)/zmacs/commands/lisp.zl		\
	$(srcdir)/zmacs/commands/macro.zl		\
	$(srcdir)/zmacs/commands/marker.zl		\
	$(srcdir)/zmacs/commands/minibuf.zl		\
	$(srcdir)/zmacs/commands/move.zl		\
	$(srcdir)/zmacs/commands/registers.zl		\
	$(srcdir)/zmacs/commands/search.zl		\
	$(srcdir)/zmacs/commands/undo.zl		\
	$(srcdir)/zmacs/commands/variables.zl		\
	$(srcdir)/zmacs/commands/window.zl		\
	$(NOTHING_ELSE)

nodist_zmacsdata_DATA =					\
	zmacs/commands.lua				\
	$(NOTHING_ELSE)

dist_zmacsdata_DATA =					\
	zmacs/default-bindings.el			\
	zmacs/callbacks.lua				\
	zmacs/keymaps.lua				\
	zmacs/eval.lua					\
	zmacs/main.lua					\
	zmacs/tbl_vars.lua				\
	zmacs/zlisp.lua					\
	$(dist_zmacscmds_DATA)				\
	$(NOTHING_ELSE)

zmacs_zmacs_DEPS =					\
	Makefile					\
	zmacs/zmacs.in					\
	$(nodist_zmacsdata_DATA)			\
	$(dist_zmacsdata_DATA)				\
	$(NOTHING_ELSE)


# AM_SILENT_RULES pretty printing.
ZM_V_ZLC    = $(zm__v_ZLC_@AM_V@)
zm__v_ZLC_  = $(zm__v_ZLC_@AM_DEFAULT_V@)
zm__v_ZLC_0 = @echo "  ZLC     " $@;
zm__v_ZLC_1 =

zmacs/commands.lua: $(dist_zmacscmds_DATA)
	$(AM_V_at)test -d zmacs || mkdir zmacs
	$(ZM_V_ZLC)LUA_PATH='$(ZMACS_PATH);$(ZILE_PATH);$(LUA_PATH)' \
	  $(LUA) $(srcdir)/zmacs/zlc $(dist_zmacscmds_DATA) > $@

zmacs/zmacs: $(zmacs_zmacs_DEPS)
	@rm -f $@ $@.tmp
	$(AM_V_GEN)$(zmacs_inplace_edit) '$(srcdir)/$@.in' >'$@.tmp'
	$(AM_V_at)mv $@.tmp $@
	$(AM_V_at)chmod +x $@
	$(AM_V_at)$@ --version >/dev/null || rm $@

zmacs/dotzmacs.sample: zmacs/tbl_vars.lua zmacs/mkdotzmacs.lua
	$(AM_V_GEN)PACKAGE='$(PACKAGE)'			\
	LUA_PATH='$(ZMACS_PATH);$(ZILE_PATH);$(LUA_PATH)' \
	  $(LUA) $(srcdir)/zmacs/mkdotzmacs.lua > '$@'

zmacs/zmacs.1: $(srcdir)/zmacs/zmacs.1.in Makefile config.status
	@test -d zmacs || mkdir zmacs
	$(AM_V_at)rm -f $@ $@.tmp
	$(AM_V_GEN)$(zmacs_install_edit) '$(srcdir)/$@.in' >'$@.tmp'
	$(AM_V_at)mv '$@.tmp' '$@'

$(srcdir)/zmacs/zmacs.1.in: zmacs/man-extras zmacs/help2man-wrapper configure.ac
	@test -d zmacs || mkdir zmacs
## Exit gracefully if zmacs.1.in is not writeable, such as during distcheck!
	$(AM_V_GEN)if ( touch $@.w && rm -f $@.w; ) >/dev/null 2>&1; \
	then						\
	  builddir='$(builddir)'			\
	  $(srcdir)/build-aux/missing --run		\
	    $(HELP2MAN)					\
	      '--output=$@'				\
	      '--no-info'				\
	      '--name=Zmacs'				\
	      --include '$(srcdir)/zmacs/man-extras'	\
	      '$(srcdir)/zmacs/help2man-wrapper';	\
	fi



## ----------- ##
## Test suite. ##
## ----------- ##


CD_TESTDIR	= abs_srcdir=`$(am__cd) $(srcdir) && pwd`; cd $(tests_dir)

tests_dir	= $(srcdir)/zmacs/tests
package_m4	= $(tests_dir)/package.m4
testsuite	= $(tests_dir)/testsuite

TESTSUITE	= zmacs/tests/testsuite
TESTSUITE_AT	= $(tests_dir)/testsuite.at \
		  $(tests_dir)/message.at \
		  $(tests_dir)/write-file.at \
		  $(NOTHING_ELSE)

EXTRA_DIST	+= $(testsuite) $(TESTSUITE_AT) $(package_m4)

TESTS_ENVIRONMENT = ZMACS="$(abs_builddir)/zmacs/zmacs"

$(testsuite): $(package_m4) $(TESTSUITE_AT) Makefile.am
	$(AM_V_GEN)$(AUTOTEST) -I '$(srcdir)' -I '$(tests_dir)' \
	  $(TESTSUITE_AT) -o '$@'

$(package_m4): $(dotversion) zmacs/Makefile.am
	$(AM_V_GEN){ \
	  echo '# Signature of the current package.'; \
	  echo 'm4_define([AT_PACKAGE_NAME],      [$(PACKAGE_NAME)])'; \
	  echo 'm4_define([AT_PACKAGE_TARNAME],   [$(PACKAGE_TARNAME)])'; \
	  echo 'm4_define([AT_PACKAGE_VERSION],   [$(PACKAGE_VERSION)])'; \
	  echo 'm4_define([AT_PACKAGE_STRING],    [$(PACKAGE_STRING)])'; \
	  echo 'm4_define([AT_PACKAGE_BUGREPORT], [$(PACKAGE_BUGREPORT)])'; \
	  echo 'm4_define([AT_PACKAGE_URL],       [$(PACKAGE_URL)])'; \
	} > '$@'

$(tests_dir)/atconfig: config.status
	$(AM_V_GEN)$(SHELL) config.status '$@'

DISTCLEANFILES	+= $(tests_dir)/atconfig

# Hook the test suite into the check rule
check_local += zmacs-check-local
zmacs-check-local: $(tests_dir)/atconfig $(testsuite)
	$(AM_V_at)$(CD_TESTDIR); \
	CONFIG_SHELL='$(SHELL)' '$(SHELL)' "$$abs_srcdir/$(TESTSUITE)" \
	  $(TESTS_ENVIRONMENT) $(BUILDCHECK_ENVIRONMENT) $(TESTSUITEFLAGS)

# Remove any file droppings left behind by testsuite.
clean-local:
	-$(CD_TESTDIR); \
	test -f "$$abs_srcdir/$(TESTSUITE)" && \
	  '$(SHELL)' "$$abs_srcdir/$(TESTSUITE)" --clean


## ------------- ##
## Installation. ##
## ------------- ##

install_exec_hooks += install-zmacs-hook
install-zmacs-hook:
	@$(zmacs_install_edit) $(srcdir)/zmacs/zmacs.in >'$@.tmp'
	@echo $(INSTALL_SCRIPT) zmacs/zmacs $(DESTDIR)$(bindir)/zmacs
	@$(INSTALL_SCRIPT) $@.tmp $(DESTDIR)$(bindir)/zmacs
	@rm -f $@.tmp


## ------------- ##
## Distribution. ##
## ------------- ##

EXTRA_DIST +=						\
	zmacs/dotzmacs.sample				\
	zmacs/help2man-wrapper				\
	zmacs/man-extras				\
	zmacs/mkdotzmacs.lua				\
	zmacs/zlc					\
	zmacs/zmacs.1.in				\
	zmacs/zmacs.in					\
	$(NOTHING_ELSE)


## ------------ ##
## Maintenance. ##
## ------------ ##

CLEANFILES +=						\
	zmacs/zmacs					\
	zmacs/zmacs.1					\
	$(NOTHING_ELSE)

DISTCLEANFILES +=					\
	zmacs/commands.lua				\
	$(NOTHING_ELSE)

MAINTAINERCLEANFILES +=					\
	$(srcdir)/zmacs/zmacs.1.in			\
	$(NOTHING_ELSE)
