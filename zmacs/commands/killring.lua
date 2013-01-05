-- Kill ring facility commands.
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


Defun ("kill-word",
       {"number"},
[[
Kill characters forward until encountering the end of a word.
With argument @i{arg}, do this that many times.
]],
  true,
  function (arg)
    return kill_text (arg, "mark-word")
  end
)


Defun ("backward-kill-word",
       {"number"},
[[
Kill characters backward until encountering the end of a word.
With argument @i{arg}, do this that many times.
]],
  true,
  function (arg)
    return kill_text (-(arg or 1), "mark-word")
  end
)


Defun ("kill-sexp",
       {"number"},
[[
Kill the sexp (balanced expression) following the cursor.
With @i{arg}, kill that many sexps after the cursor.
Negative arg -N means kill N sexps before the cursor.
]],
  true,
  function (arg)
    return kill_text (arg, "mark-sexp")
  end
)


Defun ("yank",
       {},
[[
Reinsert the last stretch of killed text.
More precisely, reinsert the stretch of killed text most recently
killed @i{or} yanked.  Put point at end, and set mark at beginning.
]],
  true,
  function ()
    if killring_empty () then
      minibuf_error ("Kill ring is empty")
      return false
    end

    if warn_if_readonly_buffer () then
      return false
    end

    execute_function ("set-mark-command")
    killring_yank ()
    deactivate_mark ()
  end
)


Defun ("kill-region",
       {},
[[
Kill between point and mark.
The text is deleted but saved in the kill ring.
The command @kbd{C-y} (yank) can retrieve it from there.
If the buffer is read-only, Zile will beep and refrain from deleting
the text, but put the text in the kill ring anyway.  This means that
you can use the killing commands to copy text from a read-only buffer.
If the previous command was also a kill command,
the text killed this time appends to the text killed last time
to make one entry in the kill ring.
]],
  true,
  function ()
    return copy_or_kill_the_region (true)
  end
)


Defun ("copy-region-as-kill",
       {},
[[
Save the region as if killed, but don't kill it.
]],
  true,
  function ()
    return copy_or_kill_the_region (false)
  end
)


Defun ("kill-line",
       {"number"},
[[
Kill the rest of the current line; if no nonblanks there, kill thru newline.
With prefix argument @i{arg}, kill that many lines from point.
Negative arguments kill lines backward.
With zero argument, kills the text before point on the current line.

If @samp{kill-whole-line} is non-nil, then this command kills the whole line
including its terminating newline, when used at the beginning of a line
with no argument.
]],
  true,
  function (arg)
    local ok = true

    maybe_free_kill_ring ()

    if not arg then
      ok = kill_line (bolp () and get_variable_bool ("kill-whole-line"))
    else
      undo_start_sequence ()
      if arg <= 0 then
        kill_to_bol ()
      end
      if arg ~= 0 and ok then
        ok = execute_with_uniarg (false, arg, kill_whole_line, kill_line_backward)
      end
      undo_end_sequence ()
    end

    deactivate_mark ()
    return ok
  end
)
