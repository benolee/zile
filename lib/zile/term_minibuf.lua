-- Minibuffer handling
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

local function draw_minibuf_read (prompt, value, match, pointo)
  term_minibuf_write (prompt)

  local w, h = term_width (), term_height ()
  local margin = 1
  local n = 0

  if #prompt + pointo + 1 >= w then
    margin = margin + 1
    term_addstr ('$')
    n = pointo - pointo % (w - #prompt - 2)
  end

  term_addstr (string.sub (value, n + 1, math.min (w - #prompt - margin, #value - n)))
  term_addstr (match)

  if #value - n >= w - #prompt - margin then
    term_move (h - 1, w - 1)
    term_addstr ('$')
  end

  term_move (h - 1, #prompt + margin - 1 + pointo % (w - #prompt - margin))

  term_refresh ()
end

function maybe_close_popup (cp)
  local old_wp = cur_wp
  local wp = find_window ("*Completions*")
  if cp and cp.poppedup and wp then
    set_current_window (wp)
    if cp.close then
      delete_window (cur_wp)
    elseif cp.old_bp then
      switch_to_buffer (cp.old_bp)
    end
    set_current_window (old_wp)
    term_redisplay ()
  end
end

function suspend ()
  posix.raise (posix.SIGTSTP)
end

function term_minibuf_read (prompt, value, pos, cp, hp)
  if hp then
    history_prepare (hp)
  end

  local thistab, saved
  local lasttab = -1
  local as = value

  if pos == -1 then
    pos = #as
  end

  repeat
    local s
    if lasttab == "matches" then
      s = " [Complete, but not unique]"
    elseif lasttab == "no match" then
      s = " [No match]"
    elseif lasttab == "match" then
      s = " [Sole completion]"
    else
      s = ""
    end

    draw_minibuf_read (prompt, as, s, pos)

    thistab = -1

    local c = getkeystroke (GETKEY_DEFAULT)
    if c == nil or c == keycode "\\RET" then
    elseif c == keycode "\\C-z" then
      suspend ()
    elseif c == keycode "\\C-g" then
      as = nil
      break
    elseif keyset {"\\C-a", "\\HOME"}:member (c) then
      pos = 0
    elseif keyset {"\\C-e", "\\END"}:member (c) then
      pos = #as
    elseif keyset {"\\C-b", "\\LEFT"}:member (c) then
      if pos > 0 then
        pos = pos - 1
      else
        ding ()
      end
    elseif keyset {"\\C-f", "\\RIGHT"}:member (c) then
      if pos < #as then
        pos = pos + 1
      else
        ding ()
      end
    elseif c == keycode "\\C-k" then
      -- FIXME: do kill-register save.
      if pos < #as then
        as = string.sub (as, pos + 1)
      else
        ding ()
      end
    elseif c == keycode "\\BACKSPACE" then
      if pos > 0 then
        as = string.sub (as, 1, pos - 1) .. string.sub (as, pos + 1)
        pos = pos - 1
      else
        ding ()
      end
    elseif keyset {"\\C-d", "\\DELETE"}:member (c) then
      if pos < #as then
        as = string.sub (as, 1, pos) .. string.sub (as, pos + 2)
      else
        ding ()
      end
    elseif keyset {"\\M-v", "\\PAGEUP"}:member (c) then
      if cp == nil then
        ding ()
      elseif cp.poppedup then
        completion_scroll_down ()
        thistab = lasttab
      end
    elseif keyset {"\\C-v", "\\PAGEDOWN"}:member (c) then
      if cp == nil then
        ding ()
      elseif cp.poppedup then
        completion_scroll_up ()
        thistab = lasttab
      end
    elseif keyset {"\\M-p", "\\UP"}:member (c) then
      if hp then
        local elem = previous_history_element (hp)
        if elem then
          if not saved then
            saved = as
          end
          as = elem
        end
      end
    elseif keyset {"\\M-n", "\\DOWN"}:member (c) then
      if hp then
        local elem = next_history_element (hp)
        if elem then
          as = elem
        elseif saved then
          as = saved
          saved = nil
        end
      end
    elseif c == keycode "\\TAB" or (c == keycode " " and cp) then
      if not cp then
        ding ()
      else
        if lasttab ~= -1 and lasttab ~= "no match" and cp.poppedup then
          completion_scroll_up ()
          thistab = lasttab
        else
          thistab = completion_try (cp, as)
          if thistab == "incomplete" or thistab == "matches" then
            popup_completion (cp)
          end
          if thistab == "match" then
            maybe_close_popup (cp)
            cp.poppedup = false
          end
          if thistab == "incomplete" or thistab == "matches" or thistab == "match" then
            local bs = cp.filename and cp.path or ""
            bs = bs .. cp.match
            if string.sub (as, 1, #bs) ~= bs then
              thistab = -1
            end
            as = bs
            pos = #as
          elseif thistab == "no match" then
            ding ()
          end
        end
      end
    else
      if c.key > 255 or c.META or c.CTRL or not posix.isprint (string.char (c.key)) then
        ding ()
      else
        as = string.sub (as, 1, pos) .. string.char (c.key) .. string.sub (as, pos + 1)
        pos = pos + 1
      end
    end

    lasttab = thistab
  until keyset {"\\RET", "\\C-g"}:member (c)

  minibuf_clear ()
  maybe_close_popup (cp)
  return as
end

function term_minibuf_write (s)
  if bflag then
    io.write (s .. "\n")
  else
    term_move (term_height () - 1, 0)
    term_clrtoeol ()
    term_addstr (string.sub (s, 1, math.min (#s, term_width ())))
  end
end
