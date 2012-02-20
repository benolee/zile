-- Kill ring facility functions
--
-- Copyright (c) 2010-2012 Free Software Foundation, Inc.
--
-- This file is part of GNU Zi.
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

local kill_ring_text

local function maybe_free_kill_ring ()
  if _last_command ~= zi.kill_region then
    kill_ring_text = nil
  end
end

local function kill_ring_push (es)
  kill_ring_text = (kill_ring_text or EStr ("")):cat (es)
end

local function copy_or_kill_region (kill, rp)
  kill_ring_push (get_buffer_region (cur_bp, rp))

  if kill then
    if cur_bp.readonly then
      minibuf_error ("Read only text copied to kill ring")
    else
      assert (delete_region (rp))
    end
  end

  _this_command = zi.kill_region
  deactivate_mark ()

  return true
end

local function copy_or_kill_the_region (kill)
  local rp = calculate_the_region ()

  if rp then
    maybe_free_kill_ring ()
    copy_or_kill_region (kill, rp)
    return true
  end

  return false
end

local function kill_text (uniarg, mark_func)
  maybe_free_kill_ring ()

  if warn_if_readonly_buffer () then
    return false
  end

  push_mark ()
  undo_start_sequence ()
  zi[mark_func] (uniarg)
  zi.kill_region ()
  undo_end_sequence ()
  pop_mark ()

  _this_command = zi.kill_region
  minibuf_write ("") -- Erase "Set mark" message.
  return true
end

Defun ("kill_word",
       {"number"},
[[
Kill characters forward until encountering the end of a word.
With argument @i{arg}, do this that many times.
]],
  true,
  function (arg)
    return kill_text (arg, "mark_word")
  end
)

Defun ("backward_kill_word",
       {"number"},
[[
Kill characters backward until encountering the end of a word.
With argument @i{arg}, do this that many times.
]],
  true,
  function (arg)
    return kill_text (-(arg or 1), "mark_word")
  end
)

Defun ("kill_sexp",
       {"number"},
[[
Kill the sexp (balanced expression) following the cursor.
With @i{arg}, kill that many sexps after the cursor.
Negative arg -N means kill N sexps before the cursor.
]],
  true,
  function (arg)
    return kill_text (arg, "mark_sexp")
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
    if not kill_ring_text then
      minibuf_error ("Kill ring is empty")
      return false
    end

    if warn_if_readonly_buffer () then
      return false
    end

    zi.set_mark_command ()
    insert_estr (kill_ring_text)
    deactivate_mark ()
  end
)

Defun ("kill_region",
       {},
[[
Kill between point and mark.
The text is deleted but saved in the kill ring.
The command @kbd{C-y} (yank) can retrieve it from there.
If the buffer is read-only, Zi will beep and refrain from deleting
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

Defun ("copy_region_as_kill",
       {},
[[
Save the region as if killed, but don't kill it.
]],
  true,
  function ()
    return copy_or_kill_the_region (false)
  end
)

local function kill_to_bol ()
  return bolp () or
    copy_or_kill_region (true, region_new (get_buffer_line_o (cur_bp), get_buffer_pt (cur_bp)))
end

local function kill_line (whole_line)
  local ok = true
  local only_blanks_to_end_of_line = true

  if not whole_line then
    for i = get_buffer_pt (cur_bp) - get_buffer_line_o (cur_bp), buffer_line_len (cur_bp) - 1 do
      local c = get_buffer_char (cur_bp, get_buffer_line_o (cur_bp) + i)
      if not (c == ' ' or c == '\t') then
        only_blanks_to_end_of_line = false
        break
      end
    end
  end

  if eobp () then
    minibuf_error ("End of buffer")
    return false
  end

  undo_start_sequence ()

  if not eolp () then
    ok = copy_or_kill_region (true, region_new (get_buffer_pt (cur_bp), get_buffer_line_o (cur_bp) + buffer_line_len (cur_bp)))
  end

  if ok and (whole_line or only_blanks_to_end_of_line) and not eobp () then
    if not zi.delete_char () then
      return false
    end

    kill_ring_push (EStr ("\n"))
    _this_command = zi.kill_region
  end

  undo_end_sequence ()

  return ok
end

local function kill_whole_line ()
  return kill_line (true)
end

local function kill_line_backward ()
  return previous_line () and kill_whole_line ()
end

Defun ("kill_line",
       {"number"},
[[
Kill the rest of the current line; if no nonblanks there, kill thru newline.
With prefix argument @i{arg}, kill that many lines from point.
Negative arguments kill lines backward.
With zero argument, kills the text before point on the current line.

If @samp{kill_whole_line} is non-nil, then this command kills the whole line
including its terminating newline, when used at the beginning of a line
with no argument.
]],
  true,
  function (arg)
    local ok = true

    maybe_free_kill_ring ()

    if not arg then
      ok = kill_line (bolp () and get_variable_bool ("kill_whole_line"))
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
