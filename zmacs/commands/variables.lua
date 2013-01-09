-- Variable facility commands.
--
-- Copyright (c) 2010-2013 Free Software Foundation, Inc.
--
-- This file is part of GNU Zile.
--
-- This program is free software; you can redistribute it and/or modify it
-- under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 3, or (at your option)
-- any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.


local lisp = require "eval"


local Defun = lisp.Defun


Defun ("set-variable",
       {"string", "string"},
[[
Set a variable value to the user-specified value.
]],
  true,
  function (var, val)
    local ok = true

    if not var then
      var = minibuf_read_variable_name ("Set variable: ")
    end
    if not var then
      return false
    end
    if not val then
      val = minibuf_read (string.format ("Set %s to value: ", var), "")
    end
    if not val then
      ok = keyboard_quit ()
    end

    if ok then
      set_variable (var, val)
    end

    return ok
  end
)
