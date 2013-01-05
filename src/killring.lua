-- Kill ring facility functions
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

local kill_ring_text

function killring_empty ()
  return not kill_ring_text
end

function killring_yank ()
  insert_estr (kill_ring_text)
end


function maybe_free_kill_ring ()
  if _last_command ~= "kill-region" then
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

  _this_command = "kill-region"
  deactivate_mark ()

  return true
end

function copy_or_kill_the_region (kill)
  local rp = calculate_the_region ()

  if rp then
    maybe_free_kill_ring ()
    copy_or_kill_region (kill, rp)
    return true
  end

  return false
end

function kill_text (uniarg, mark_func)
  maybe_free_kill_ring ()

  if warn_if_readonly_buffer () then
    return false
  end

  push_mark ()
  undo_start_sequence ()
  execute_function (mark_func, uniarg)
  execute_function ("kill-region")
  undo_end_sequence ()
  pop_mark ()

  _this_command = "kill-region"
  minibuf_write ("") -- Erase "Set mark" message.
  return true
end

function kill_to_bol ()
  return bolp () or
    copy_or_kill_region (true, region_new (get_buffer_line_o (cur_bp), get_buffer_pt (cur_bp)))
end

function kill_line (whole_line)
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
    if not execute_function ("delete-char") then
      return false
    end

    kill_ring_push (EStr ("\n"))
    _this_command = "kill-region"
  end

  undo_end_sequence ()

  return ok
end

function kill_whole_line ()
  return kill_line (true)
end

function kill_line_backward ()
  return previous_line () and kill_whole_line ()
end
