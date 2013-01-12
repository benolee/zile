-- Zile Lisp commands.
--
-- Copyright (c) 2009-2013 Free Software Foundation, Inc.
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
-- along with this program; see the file COPYING.  If not, write to the
-- Free Software Foundation, Fifth Floor, 51 Franklin Street, Boston,
-- MA 02111-1301, USA.


local lisp = require "eval"


local Defun = lisp.Defun


Defun ("load",
       {"string"},
[[
Execute a file of Lisp code named FILE.
]],
  true,
  function (file)
    if file then
      return lisp.loadfile (file)
    end
  end
)


Defun ("setq",
       {},
[[
(setq [sym val]...)

Set each sym to the value of its val.
The symbols sym are variables; they are literal (not evaluated).
The values val are expressions; they are evaluated.
]],
  false,
  function (...)
    local ret
    local l = {...}
    for i = 1, #l/2 do
      ret = lisp.evaluateexpr (l[i + 1])
      set_variable (l[i].value, ret.value)
    end
    return ret
  end
)


Defun ("execute-extended-command",
       {"number"},
[[
Read function name, then read its arguments and call it.
]],
  true,
  function (n)
    local msg = ""

    if lastflag.set_uniarg then
      if lastflag.uniarg_empty then
        msg = "C-u "
      else
        msg = string.format ("%d ", current_prefix_arg)
      end
    end
    msg = msg .. "M-x "

    local name = minibuf_read_function_name (msg)
    return name and lisp.execute_function (name, n) or nil
  end
)

-- Read a function name from the minibuffer.
local functions_history = history_new ()
function minibuf_read_function_name (fmt)
  local cp = completion_new ()

  for name, func in lisp.commands () do
    if func.interactive then
      table.insert (cp.completions, name)
    end
  end

  return minibuf_vread_completion (fmt, "", cp, functions_history,
                                   "No function name given",
                                   "Undefined function name `%s'")
end


Defun ("eval-buffer",
       {"string"},
[[
Execute the current buffer as Lisp code.

When called from a Lisp program (i.e., not interactively), this
function accepts an optional argument, the buffer to evaluate (nil
means use current buffer).
]],
  true,
  function (buffer)
    local bp = (buffer and buffer ~= "") and find_buffer (buffer) or cur_bp
    return lisp.loadstring (get_buffer_pre_point (bp) .. get_buffer_post_point (bp))
  end
)


local exprs_history = history_new ()

Defun ("eval-expression",
       {"string"},
[[
Evaluate a lisp expression and print result in the minibuffer.
]],
  true,
  function (expr)
    if not expr then
      expr = minibuf_read ("Eval: ", "", nil, exprs_history)
    end

    lisp.loadstring (expr)

    if expr then
      add_history_element (exprs_history, expr)
    end
  end
)
