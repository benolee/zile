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

ZMACS_PATH = $(abs_srcdir)/zmacs/?.lua

zmacsdatadir = $(datadir)/zmacs

zmacs_install_edit =					\
	$(install_edit)					\
	-e 's|@zmacsdatadir[@]|$(zmacsdatadir)|g'

zmacs_inplace_edit =					\
	$(inplace_edit)					\
	-e 's|@zmacsdatadir[@]|$(abs_top_srcdir)/zmacs|g'

doc_DATA += zmacs/dotzmacs.sample

bin_SCRIPTS += zmacs/zmacs

man_MANS += zmacs/zmacs.1

dist_zmacsdata_DATA =					\
	zmacs/tbl_vars.lua

zmacs/zmacs: $(dist_pkgdata_DATA) $(dist_zmacsdata_DATA) Makefile
	@rm -f $@ $@.tmp
	$(AM_V_GEN)$(zmacs_inplace_edit) '$@.lua' >'$@.tmp'
	$(AM_V_at)mv $@.tmp $@
	$(AM_V_at)chmod +x $@
	$(AM_V_at)$@ --version >/dev/null || rm $@

zmacs/dotzmacs.sample: zmacs/tbl_vars.lua zmacs/mkdotzmacs.lua
	$(AM_V_GEN)PACKAGE='$(PACKAGE)'			\
	LUA_PATH='$(ZMACS_PATH);$(ZILE_PATH);$(LUA_PATH)' \
	  $(LUA) $(srcdir)/zmacs/mkdotzmacs.lua > '$@'

zmacs/zmacs.1: $(srcdir)/zmacs/zmacs.1.in zmacs/Makefile.am config.status
	@test -d zmacs || mkdir zmacs
	$(AM_V_at)rm -f $@ $@.tmp
	$(AM_V_GEN)$(zmacs_install_edit) '$(srcdir)/$@.in' >'$@.tmp'
	$(AM_V_at)mv '$@.tmp' '$@'

$(srcdir)/zmacs/zmacs.1.in: zmacs/man-extras zmacs/help2man-wrapper configure.ac
	@test -d zmacs || mkdir zmacs
## Exit gracefully if zmacs.1.in is not writeable, such as during distcheck!
	$(AM_V_GEN)if ( touch $@.w && rm -f $@.w; ) >/dev/null 2>&1; then \
	  builddir='$(builddir)' $(srcdir)/build-aux/missing --run $(HELP2MAN) --output='$@' --no-info --name="Zmacs" --include '$(srcdir)/zmacs/man-extras' '$(srcdir)/zmacs/help2man-wrapper'; \
	fi

install_exec_hooks += install-zmacs-hook
install-zmacs-hook:
	@$(zmacs_install_edit) zmacs/zmacs.lua >'$@.tmp'
	@echo $(INSTALL_SCRIPT) zmacs/zmacs $(DESTDIR)$(bindir)/zmacs
	@$(INSTALL_SCRIPT) $@.tmp $(DESTDIR)$(bindir)/zmacs
	@rm -f $@.tmp

EXTRA_DIST +=						\
	zmacs/dotzmacs.sample				\
	zmacs/help2man-wrapper				\
	zmacs/man-extras				\
	zmacs/mkdotzmacs.lua				\
	zmacs/zmacs.1.in

CLEANFILES +=						\
	zmacs/zmacs					\
	zmacs/zmacs.lua

DISTCLEANFILES +=					\
	zmacs/zmacs.1

MAINTAINERCLEANFILES +=					\
	$(srcdir)/zmacs/zmacs.1.in
