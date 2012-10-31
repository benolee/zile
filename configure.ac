dnl configure.ac
dnl
dnl Copyright (c) 1997-2012 Free Software Foundation, Inc.
dnl
dnl This file is part of GNU Zile.
dnl
dnl This program is free software; you can redistribute it and/or modify
dnl it under the terms of the GNU General Public License as published
dnl by the Free Software Foundation; either version 3, or (at your
dnl option) any later version.
dnl
dnl This program is distributed in the hope that it will be useful, but
dnl WITHOUT ANY WARRANTY; without even the implied warranty of
dnl MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
dnl General Public License for more details.
dnl
dnl You should have received a copy of the GNU General Public License
dnl along with this program.  If not, see <http://www.gnu.org/licenses/>.

AC_PREREQ([2.61])

dnl Initialise autoconf and automake
AC_INIT([Zile], [2.5.0.50], [bug-zile@gnu.org])
AC_CONFIG_AUX_DIR([build-aux])
AM_INIT_AUTOMAKE([-Wall -Werror std-options])
m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])

dnl Set up gnulib
gl_EARLY
gl_INIT

dnl Lua
AC_SUBST([LUA_VERSION], [5.2])
AX_PROG_LUA([$LUA_VERSION])

dnl help2man
AX_WITH_PROG([HELP2MAN], [help2man], [false])

dnl md5sum
AX_WITH_PROG([MD5SUM], [md5sum], [false])

dnl Emacs >= 23.1 (optional)
AX_WITH_PROG([EMACSPROG], [emacs])
if test -n "$EMACSPROG"; then
  emacs_min_version=23.1
  emacs_version=$($EMACSPROG --version 2>&1 | head -n 1 | cut -d' ' -f3)
  AC_MSG_CHECKING([Emacs version $emacs_version >= $emacs_min_version])
  AX_COMPARE_VERSION([$emacs_version], [ge], [$emacs_min_version],
    [AC_MSG_RESULT([yes])],
    [AC_MSG_RESULT([no])
    unset EMACSPROG])
fi

dnl ------------------------------- RELOCATABILITY ------------

# Check we can make the installation relocatable

AC_LIB_PREPARE_PREFIX

# First of all, compute the final paths for the various components.

acl_final_bindir=`echo "${bindir}" | sed \
        -e "s,\\\${exec_prefix},$acl_final_exec_prefix," \
        -e "s,\\\${prefix},$acl_final_prefix," `
acl_final_datadir=`echo "${datadir}" | sed \
        -e "s,\\\${datarootdir},$datarootdir," \
        -e "s,\\\${exec_prefix},$acl_final_exec_prefix," \
        -e "s,\\\${prefix},$acl_final_prefix," `
acl_final_docdir=`echo "${docdir}" | sed \
        -e "s,\\\${exec_prefix},$acl_final_exec_prefix," \
        -e "s,\\\${prefix},$acl_final_prefix," `
acl_final_pkgdatadir="$acl_final_datadir/$PACKAGE"
acl_final_pkgdocdir="$acl_final_docdir/$PACKAGE"

# Further OS-independent tests ensure that we can make relative
# paths from the executable's location.

relocatable_reason='yes'
case "${acl_final_bindir}" in
  "${acl_final_exec_prefix}") ;;
  "${acl_final_exec_prefix}"/*) ;;
  /*) relocatable_reason='no, bindir outside exec_prefix' ;;
  *) relocatable_reason='no, relative bindir' ;;
esac
case "${acl_final_datadir}" in
  ${acl_final_prefix}) ;;
  ${acl_final_prefix}/*) ;;
  /*) relocatable_reason='no, datadir outside prefix' ;;
  *) relocatable_reason='no, relative datadir' ;;
esac
case "${acl_final_docdir}" in
  ${acl_final_prefix}) ;;
  ${acl_final_prefix}/*) ;;
  /*) relocatable_reason='no, docdir outside prefix' ;;
  *) relocatable_reason='no, relative docdir' ;;
esac

test "$acl_final_prefix" != "$acl_final_exec_prefix" && \
  relocatable_reason='no, prefix does not match exec prefix'

if test $relocatable_reason != "yes"; then
  AC_MSG_FAILURE("Cannot make package relocatable: $relocatable_reason")
fi

# echo the relative path from ${acl_final_bindir} to $1
# (Works only if both are absolute.)
[func_make_relpath ()
{
  dir=$1
  idir=${acl_final_bindir}

  while true; do
    dfirst=`echo "$dir" | sed -n -e 's,^//*\([^/]*\).*$,/\1,p'`
    ifirst=`echo "$idir" | sed -n -e 's,^//*\([^/]*\).*$,/\1,p'`
    test x"$dfirst" = x && break
    test x"$ifirst" = x && break
    test "$dfirst" != "$ifirst" && break

    dir=`echo "$dir" | sed -e 's,^//*[^/]*,,'`
    idir=`echo "$idir" | sed -e 's,^//*[^/]*,,'`
  done
  idir=`echo "$idir" | sed -e 's,//*[^/]*,/..,g' -e 's,^/,,' `
  echo "${idir:-.}$dir"
}]

PKGDATA_PATH=`func_make_relpath "${acl_final_pkgdatadir}"`
PKGDOC_PATH=`func_make_relpath "${acl_final_pkgdocdir}"`
AC_DEFINE_UNQUOTED([PKGDATA_PATH], "$PKGDATA_PATH",
      [The relative path from the program to the per-package
       data path.  Defined only for relocatable installs.])
AC_DEFINE_UNQUOTED([PKGDOC_PATH], "$PKGDOC_PATH",
      [The relative path from the program to the per-package
       doc path.  Defined only for relocatable installs.])
AC_SUBST(PKGDATA_PATH)
AC_SUBST(PKGDOC_PATH)


dnl Generate output
AC_CONFIG_FILES([Makefile src/zile.lua $PACKAGE.rockspec luarocks-config.lua])
AC_OUTPUT
