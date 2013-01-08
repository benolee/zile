# Source Makefile.am
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

doc_DATA += src/dotzile.sample

bin_SCRIPTS = src/zile

src_zile_LUA =						\
	src/lib.lua					\
	src/astr.lua					\
	src/estr.lua					\
	src/history.lua					\
	src/lisp.lua					\
	src/main.lua					\
	src/variables.lua				\
	src/basic.lua					\
	src/bind.lua					\
	src/buffer.lua					\
	src/completion.lua				\
	src/editfns.lua					\
	src/funcs.lua					\
	src/getkey.lua					\
	src/help.lua					\
	src/file.lua					\
	src/keycode.lua					\
	src/killring.lua				\
	src/line.lua					\
	src/macro.lua					\
	src/marker.lua					\
	src/minibuf.lua					\
	src/redisplay.lua				\
	src/registers.lua				\
	src/search.lua					\
	src/tbl_vars.lua				\
	src/undo.lua					\
	src/window.lua					\
	src/term_curses.lua				\
	src/term_minibuf.lua				\
	src/term_redisplay.lua

dist_pkgdata_DATA =					\
	$(src_zile_LUA)					\
	src/loadlua.lua					\
	src/default-bindings.el

src/loadlua.lua: src/Makefile.am src/loadlua.lua.in
	$(AM_V_at)cp src/loadlua.lua.in $@
	$(AM_V_GEN)for i in $(src_zile_LUA); do echo 'require "'`echo $$i | sed -e 's|^src/||;s|\\.lua$$||'`'"' >> $@; done

src/zile: $(dist_pkgdata_DATA) Makefile
	@rm -f $@ $@.tmp
	$(AM_V_GEN)$(inplace_edit) '$@.lua' >$@.tmp
	$(AM_V_at)mv $@.tmp $@
	$(AM_V_at)chmod +x $@
	$(AM_V_at)$@ --version >/dev/null || rm $@

src/dotzile.sample: src/tbl_vars.lua build-aux/mkdotzile.lua
	$(AM_V_GEN)PACKAGE="$(PACKAGE)" $(LUA_ENV)	\
	  $(LUA) $(srcdir)/build-aux/mkdotzile.lua $(srcdir)/src/tbl_vars.lua

install-exec-hook:
	@$(install_edit) 'src/zile.lua' >$@.tmp
	@echo $(INSTALL_SCRIPT) $@ $(DESTDIR)$(bindir)/zile
	@$(INSTALL_SCRIPT) $@.tmp $(DESTDIR)$(bindir)/zile
	@rm -f $@.tmp

EXTRA_DIST +=						\
	src/zile.lua.in					\
	src/loadlua.lua.in				\
	src/dotzile.sample

CLEANFILES +=						\
	src/zile					\
	src/zile.lua

DISTCLEANFILES +=					\
	$(BUILT_SOURCES)
