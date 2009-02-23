/* Table of command-line options

   Copyright (c) 2009 Free Software Foundation, Inc.

   This file is part of GNU Zile.

   GNU Zile is free software; you can redistribute it and/or modify it
   under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3, or (at your option)
   any later version.

   GNU Zile is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with GNU Zile; see the file COPYING.  If not, write to the
   Free Software Foundation, Fifth Floor, 51 Franklin Street, Boston,
   MA 02111-1301, USA.  */

/*
 * D: documentation line
 * O: Option
 * A: Action
 *
 * D(text)
 * I(long name, short name, argument, argument docstring, docstring)
 * A(argument, docstring)
 */

/* Options which take no argument have optional_argument, so that no
   arguments are signalled as extraneous, as in Emacs. */

D ("Initialization options:")
D ("")
/* FIXME: Generate "zile" in next line from PACKAGE */
O ("no-init-file", 'q', optional_argument, "", "do not load ~/.zile")
/* FIXME: Generate "Zile" in next line from PACKAGE_NAME */
O ("load", 'l', required_argument, "FILE", "load Zile Lisp FILE using the load function")
O ("help", 'h', optional_argument, "", "display this help message and exit")
O ("version", 'v', optional_argument, "", "display version information and exit")
D ("")
D ("Action options:")
D ("")
A ("FILE", "visit FILE using find-file")
A ("+LINE FILE", "visit FILE using find-file, then go to line LINE")
