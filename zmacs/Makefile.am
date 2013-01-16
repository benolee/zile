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
