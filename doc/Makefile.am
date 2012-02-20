# Source Makefile.am
#
# Copyright (c) 1997-2012 Free Software Foundation, Inc.
#
# This file is part of GNU Zi.
#
# This proram is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3, or (at your option)
# any later version.
#
# This proram is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

MAINTAINERCLEANFILES += $(srcdir)/doc/zi.1.in doc/zi.1
DISTCLEANFILES += doc/zi.1
EXTRA_DIST += doc/man-extras doc/zi.1.in
man_MANS = doc/zi.1

doc/zi.1: $(srcdir)/doc/zi.1.in doc/Makefile.am config.status
	@test -d doc || mkdir doc
	rm -f $@ $@.tmp
	$(install_edit) '$(srcdir)/$@.in' >$@.tmp
	mv $@.tmp $@

$(srcdir)/doc/zi.1.in: doc/man-extras build-aux/zi-help2man-wrapper configure.ac
	@test -d doc || mkdir doc
## Exit gracefully if zi.1.in is not writeable, such as during distcheck!
	$(AM_V_GEN)if ( touch $@.w && rm -f $@.w; ) >/dev/null 2>&1; then \
	  builddir=$(builddir) $(srcdir)/build-aux/missing --run $(HELP2MAN) --output=$@ --no-info --name="GNU Zi" --include $(srcdir)/doc/man-extras $(srcdir)/build-aux/zi-help2man-wrapper; \
	fi
