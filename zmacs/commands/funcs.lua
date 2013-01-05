-- Miscellaneous Emacs commands.
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


Defun ("keyboard-quit",
       {},
[[
Cancel current command.
]],
  true,
  function ()
    deactivate_mark ()
    return minibuf_error ("Quit")
  end
)


Defun ("suspend-emacs",
       {},
[[
Stop Zile and return to superior process.
]],
  true,
  function ()
    posix.raise (posix.SIGTSTP)
  end
)


Defun ("toggle-read-only",
       {},
[[
Change whether this buffer is visiting its file read-only.
]],
  true,
  function ()
    cur_bp.readonly = not cur_bp.readonly
  end
)


Defun ("auto-fill-mode",
       {},
[[
Toggle Auto Fill mode.
In Auto Fill mode, inserting a space at a column beyond `fill-column'
automatically breaks the line at a previous space.
]],
  true,
  function ()
    cur_bp.autofill = not cur_bp.autofill
  end
)


Defun ("exchange-point-and-mark",
       {},
[[
Put the mark where point is now, and point where the mark is now.
]],
  true,
  function ()
    if not cur_bp.mark then
      return minibuf_error ("No mark set in this buffer")
    end

    local tmp = get_buffer_pt (cur_bp)
    goto_offset (cur_bp.mark.o)
    cur_bp.mark.o = tmp
    activate_mark ()
    thisflag.need_resync = true
  end
)


Defun ("universal-argument",
       {},
[[
Begin a numeric argument for the following command.
Digits or minus sign following @kbd{C-u} make up the numeric argument.
@kbd{C-u} following the digits or minus sign ends the argument.
@kbd{C-u} without digits or minus sign provides 4 as argument.
Repeating @kbd{C-u} without digits or minus sign multiplies the argument
by 4 each time.
]],
  true,
  function ()
    local ok = true

    -- Need to process key used to invoke universal-argument.
    pushkey (lastkey ())

    thisflag.uniarg_empty = true

    local i = 0
    local arg = 1
    local sgn = 1
    local keys = {}
    while true do
      local as = ""
      local key = do_binding_completion (table.concat (keys, " "))

      -- Cancelled.
      if key == keycode "\\C-g" then
        ok = execute_function ("keyboard-quit")
        break
      -- Digit pressed.
      elseif string.match (string.char (key.key), "%d") then
        local digit = key.key - string.byte ('0')
        thisflag.uniarg_empty = false

        if key.META then
          as = "ESC "
        end

        as = as .. string.format ("%d", digit)

        if i == 0 then
          arg = digit
        else
          arg = arg * 10 + digit
        end

        i = i + 1
      elseif key == keycode "\\C-u" then
        as = as .. "C-u"
        if i == 0 then
          arg = arg * 4
        else
          break
        end
      elseif key == keycode "\\M--" and i == 0 then
        if sgn > 0 then
          sgn = -sgn
          as = as .. "-"
          -- The default negative arg is -1, not -4.
          arg = 1
          thisflag.uniarg_empty = false
        end
      else
        ungetkey (key)
        break
      end

      table.insert (keys, as)
    end

    if ok then
      prefix_arg = arg * sgn
      thisflag.set_uniarg = true
      minibuf_clear ()
    end

    return ok
  end
)

local function write_buffers_list (old_wp)
  -- FIXME: Underline next line properly.
  insert_string ("CRM Buffer                Size  Mode             File\n")
  insert_string ("--- ------                ----  ----             ----\n")

  -- Rotate buffer list to get current buffer at head.
  local bufs = table.clone (buffers)
  for i = #buffers, 1, -1 do
    if buffers[i] == old_wp.bp then
      break
    end
    table.insert (bufs, 1, table.remove (bufs))
  end

  -- Print buffers.
  for _, bp in ripairs (bufs) do
    -- Print all buffers whose names don't start with space except
    -- this one (the *Buffer List*).
    if cur_bp ~= bp and bp.name[1] ~= ' ' then
      insert_string (string.format ("%s%s%s %-19s %6u  %-17s",
                                    old_wp.bp == bp and '.' or ' ',
                                    bp.readonly and '%' or ' ',
                                    bp.modified and '*' or ' ',
                                    bp.name, get_buffer_size (bp), "Fundamental"))
      if bp.filename then
        insert_string (compact_path (bp.filename))
      end
      insert_newline ()
    end
  end
end


Defun ("list-buffers",
       {},
[[
Display a list of names of existing buffers.
The list is displayed in a buffer named `*Buffer List*'.

The C column has a `.' for the buffer from which you came.
The R column has a `%' if the buffer is read-only.
The M column has a `*' if it is modified.
After this come the buffer name, its size in characters,
its major mode, and the visited file name (if any).
]],
  true,
  function ()
    write_temp_buffer ("*Buffer List*", true, write_buffers_list, cur_wp)
  end
)


Defun ("set-mark",
       {},
[[
Set this buffer's mark to point.
]],
  false,
  function ()
    set_mark ()
    activate_mark ()
  end
)


Defun ("set-mark-command",
       {},
[[
Set the mark where point is.
]],
  true,
  function ()
    execute_function ("set-mark")
    minibuf_write ("Mark set")
  end
)


Defun ("set-fill-column",
       {"number"},
[[
Set `fill-column' to specified argument.
Use C-u followed by a number to specify a column.
Just C-u as argument means to use the current column.
]],
  true,
  function (n)
    if not n and _interactive then
      local o = get_buffer_pt (cur_bp) - get_buffer_line_o (cur_bp)
      if lastflag.set_uniarg then
        n = current_prefix_arg
      else
        n = minibuf_read_number (string.format ("Set fill-column to (default %d): ", o))
        if not n then -- cancelled
          return false
        elseif n == "" then
          n = o
        end
      end
    end

    if not n then
      return minibuf_error ("set-fill-column requires an explicit argument")
    end

    minibuf_write (string.format ("Fill column set to %d (was %d)", n, get_variable_number ("fill-column")))
    set_variable ("fill-column", tostring (n))
    return true
  end
)


Defun ("quoted-insert",
       {},
[[
Read next input character and insert it.
This is useful for inserting control characters.
]],
  true,
  function ()
    minibuf_write ("C-q-")
    insert_char (string.char (bit32.band (getkey_unfiltered (GETKEY_DEFAULT), 0xff)))
    minibuf_clear ()
  end
)


Defun ("fill-paragraph",
       {},
[[
Fill paragraph at or after point.
]],
  true,
  function ()
    local m = point_marker ()

    undo_start_sequence ()

    execute_function ("forward-paragraph")
    if is_empty_line () then
      previous_line ()
    end
    local m_end = point_marker ()

    execute_function ("backward-paragraph")
    if is_empty_line () then -- Move to next line if between two paragraphs.
      next_line ()
    end

    while buffer_end_of_line (cur_bp, get_buffer_pt (cur_bp)) < m_end.o do
      execute_function ("end-of-line")
      delete_char ()
      execute_function ("just-one-space")
    end
    unchain_marker (m_end)

    execute_function ("end-of-line")
    while get_goalc () > get_variable_number ("fill-column") + 1 and fill_break_line () do end

    goto_offset (m.o)
    unchain_marker (m)

    undo_end_sequence ()
  end
)


Defun ("shell-command",
       {"string", "boolean"},
[[
Execute string @i{command} in inferior shell; display output, if any.
With prefix argument, insert the command's output at point.

Command is executed synchronously.  The output appears in the buffer
`*Shell Command Output*'.  If the output is short enough to display
in the echo area, it is shown there, but it is nonetheless available
in buffer `*Shell Command Output*' even though that buffer is not
automatically displayed.

The optional second argument @i{output-buffer}, if non-nil,
says to insert the output in the current buffer.
]],
  true,
  function (cmd, insert)
    if not insert then
      insert = lastflag.set_uniarg
      -- Undo mangled interactive args when called from \C-u\M-!cmd\r.
      if insert and cmd == tostring(current_prefix_arg) then cmd = nil end
    end
    if not cmd then
      cmd = minibuf_read_shell_command ()
    end

    if cmd then
      return pipe_command (cmd, "/dev/null", insert, false)
    end
    return true
  end
)


-- The `start' and `end' arguments are fake, hence their string type,
-- so they can be ignored.
Defun ("shell-command-on-region",
       {"string", "string", "string", "boolean"},
[[
Execute string command in inferior shell with region as input.
Normally display output (if any) in temp buffer `*Shell Command Output*'
Prefix arg means replace the region with it.  Return the exit code of
command.

If the command generates output, the output may be displayed
in the echo area or in a buffer.
If the output is short enough to display in the echo area, it is shown
there.  Otherwise it is displayed in the buffer `*Shell Command Output*'.
The output is available in that buffer in both cases.
]],
  true,
  function (start, finish, cmd, insert)
    local ok = true

    if not cmd then
      cmd = minibuf_read_shell_command ()
    end
    if not insert then
      insert = lastflag.set_uniarg
    end

    if cmd then
      local rp = calculate_the_region ()

      if not rp then
        ok = false
      else
        local tempfile = os.tmpname ()
        local fd = io.open (tempfile, "w")

        if not fd then
          ok = minibuf_error ("Cannot open temporary file")
        else
          local written, err = fd:write (tostring (get_region ()))

          if not written then
            ok = minibuf_error ("Error writing to temporary file: " .. err)
          else
            ok = pipe_command (cmd, tempfile, insert, true)
          end

          fd:close ()
          os.remove (tempfile)
        end
      end
    end
    return ok
  end
)


Defun ("delete-region",
       {},
[[
Delete the text between point and mark.
]],
  true,
  function ()
    local rp = calculate_the_region ()

    if not rp or not delete_region (rp) then
      return false
    end
    deactivate_mark ()
    return true
  end
)


Defun ("delete-blank-lines",
       {},
[[
On blank line, delete all surrounding blank lines, leaving just one.
On isolated blank line, delete that one.
On nonblank line, delete any immediately following blank lines.
]],
  true,
  function ()
    local m = point_marker ()
    local r = region_new (get_buffer_line_o (cur_bp), get_buffer_line_o (cur_bp))

    undo_start_sequence ()

    -- Find following blank lines.
    if execute_function ("forward-line") and is_blank_line () then
      r.start = get_buffer_pt (cur_bp)
      repeat
        r.finish = buffer_next_line (cur_bp, get_buffer_pt (cur_bp))
      until not execute_function ("forward-line") or not is_blank_line ()
    end
    goto_offset (m.o)

    -- If this line is blank, find any preceding blank lines.
    local singleblank = true
    if is_blank_line () then
      r.finish = math.max (r.finish, buffer_next_line (cur_bp, get_buffer_pt (cur_bp) or math.huge))
      repeat
        r.start = get_buffer_line_o (cur_bp)
      until not execute_function ("forward-line", -1) or not is_blank_line ()

      goto_offset (m.o)
      if r.start ~= get_buffer_line_o (cur_bp) or r.finish > buffer_next_line (cur_bp, get_buffer_pt (cur_bp)) then
        singleblank = false
      end
      r.finish = math.min (r.finish, get_buffer_size (cur_bp))
    end

    -- If we are deleting to EOB, need to fudge extra line.
    local at_eob = r.finish == get_buffer_size (cur_bp) and r.start > 0
    if at_eob then
      r.start = r.start - #get_buffer_eol (cur_bp)
    end

    -- Delete any blank lines found.
    if r.start < r.finish then
      delete_region (r)
    end

    -- If we found more than one blank line, leave one.
    if not singleblank then
      if not at_eob then
        intercalate_newline ()
      else
        insert_newline ()
      end
    end

    undo_end_sequence ()

    unchain_marker (m)
    deactivate_mark ()
  end
)


Defun ("forward-line",
       {"number"},
[[
Move N lines forward (backward if N is negative).
Precisely, if point is on line I, move to the start of line I + N.
]],
  true,
  function (n)
    n = n or current_prefix_arg or 1
    if n ~= 0 then
      execute_function ("beginning-of-line")
      return move_line (n)
    end
    return false
  end
)


Defun ("backward-paragraph",
       {"number"},
[[
Move backward to start of paragraph.  With argument N, do it N times.
]],
  true,
  function (n)
    return move_paragraph (n or 1, previous_line, next_line, "beginning-of-line")
  end
)


Defun ("forward-paragraph",
       {"number"},
[[
Move forward to end of paragraph.  With argument N, do it N times.
]],
  true,
  function (n)
    return move_paragraph (n or 1, next_line, previous_line, "end-of-line")
  end
)


Defun ("forward-sexp",
       {"number"},
[[
Move forward across one balanced expression (sexp).
With argument, do it that many times.  Negative arg -N means
move backward across N balanced expressions.
]],
  true,
  function (n)
    return move_with_uniarg (n or 1, move_sexp)
  end
)


Defun ("backward-sexp",
       {"number"},
[[
Move backward across one balanced expression (sexp).
With argument, do it that many times.  Negative arg -N means
move forward across N balanced expressions.
]],
  true,
  function (n)
    return move_with_uniarg (-(n or 1), move_sexp)
  end
)

local function mark (uniarg, func)
  execute_function ("set-mark")
  local ret = execute_function (func, uniarg)
  if ret then
    execute_function ("exchange-point-and-mark")
  end
  return ret
end


Defun ("mark-word",
       {"number"},
[[
Set mark argument words away from point.
]],
  true,
  function (n)
    return mark (n, "forward-word")
  end
)


Defun ("mark-sexp",
       {"number"},
[[
Set mark @i{arg} sexps from point.
The place mark goes is the same place @kbd{C-M-f} would
move to with the same argument.
]],
  true,
  function (n)
    return mark (n, "forward-sexp")
  end
)


Defun ("mark-paragraph",
       {},
[[
Put point at beginning of this paragraph, mark at end.
The paragraph marked is the one that contains point or follows point.
]],
  true,
  function ()
    if _last_command == "mark-paragraph" then
      execute_function ("exchange-point-and-mark")
      execute_function ("forward-paragraph")
      execute_function ("exchange-point-and-mark")
    else
      execute_function ("forward-paragraph")
      execute_function ("set-mark")
      execute_function ("backward-paragraph")
    end
  end
)


Defun ("mark-whole-buffer",
       {},
[[
Put point at beginning and mark at end of buffer.
]],
  true,
  function ()
    execute_function ("end-of-buffer")
    execute_function ("set-mark-command")
    execute_function ("beginning-of-buffer")
  end
)


Defun ("back-to-indentation",
       {},
[[
Move point to the first non-whitespace character on this line.
]],
  true,
  function ()
    goto_offset (get_buffer_line_o (cur_bp))
    while not eolp () and following_char ():match ("%s") do
      move_char (1)
    end
  end
)


Defun ("forward-word",
       {"number"},
[[
Move point forward one word (backward if the argument is negative).
With argument, do this that many times.
]],
  true,
  function (n)
    return move_with_uniarg (n or 1, move_word)
  end
)


Defun ("backward-word",
       {"number"},
[[
Move backward until encountering the end of a word (forward if the
argument is negative).
With argument, do this that many times.
]],
  true,
  function (n)
    return move_with_uniarg (-(n or 1), move_word)
  end
)


Defun ("downcase-word",
       {"number"},
[[
Convert following word (or @i{arg} words) to lower case, moving over.
]],
  true,
  function (arg)
    return execute_with_uniarg (true, arg, function () return setcase_word ("lower") end)
  end
)


Defun ("upcase-word",
       {"number"},
[[
Convert following word (or @i{arg} words) to upper case, moving over.
]],
  true,
  function (arg)
    return execute_with_uniarg (true, arg, function () return setcase_word ("upper") end)
  end
)


Defun ("capitalize-word",
       {"number"},
[[
Capitalize the following word (or @i{arg} words), moving over.
This gives the word(s) a first character in upper case
and the rest lower case.
]],
  true,
  function (arg)
    return execute_with_uniarg (true, arg, function () return setcase_word ("capitalized") end)
  end
)


Defun ("upcase-region",
       {},
[[
Convert the region to upper case.
]],
  true,
  function ()
    return setcase_region (string.upper)
  end
)


Defun ("downcase-region",
       {},
[[
Convert the region to lower case.
]],
  true,
  function ()
    return setcase_region (string.lower)
  end
)


Defun ("transpose-chars",
       {"number"},
[[
Interchange characters around point, moving forward one character.
With prefix arg ARG, effect is to take character before point
and drag it forward past ARG other characters (backward if ARG negative).
If no argument and at end of line, the previous two chars are exchanged.
]],
  true,
  function (n)
    return transpose (n or 1, move_char)
  end
)


Defun ("transpose-words",
       {"number"},
[[
Interchange words around point, leaving point at end of them.
With prefix arg ARG, effect is to take word before or around point
and drag it forward past ARG other words (backward if ARG negative).
If ARG is zero, the words around or after point and around or after mark
are interchanged.
]],
  true,
  function (n)
    return transpose (n or 1, move_word)
  end
)


Defun ("transpose-sexps",
       {"number"},
[[
Like @kbd{M-x transpose-words} but applies to sexps.
]],
  true,
  function (n)
    return transpose (n or 1, move_sexp)
  end
)


Defun ("transpose-lines",
       {"number"},
[[
Exchange current line and previous line, leaving point after both.
With argument ARG, takes previous line and moves it past ARG lines.
With argument 0, interchanges line point is in with line mark is in.
]],
  true,
  function (n)
    return transpose (n or 1, move_line)
  end
)


