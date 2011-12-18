-- Minibuffer handling
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
      zi.delete_window ()
    elseif cp.old_bp then
      switch_to_buffer (cp.old_bp)
    end
    set_current_window (old_wp)
    term_redisplay ()
  end
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
    if c == nil or c == keycode "return" then
    elseif c == keycode "c-z" then
      zi.suspend_zi ()
    elseif c == keycode "c-g" then
      as = nil
      break
    elseif c == keycode "c-a" or c == keycode "home" then
      pos = 0
    elseif c == keycode "c-e" or c == keycode "end" then
      pos = #as
    elseif c == keycode "c-b" or c == keycode "left" then
      if pos > 0 then
        pos = pos - 1
      else
        ding ()
      end
    elseif c == keycode "c-f" or c == keycode "right" then
      if pos < #as then
        pos = pos + 1
      else
        ding ()
      end
    elseif c == keycode "c-k" then
      -- FIXME: do kill_register save.
      if pos < #as then
        as = string.sub (as, pos + 1)
      else
        ding ()
      end
    elseif c == keycode "backspace" then
      if pos > 0 then
        as = string.sub (as, 1, pos - 1) .. string.sub (as, pos + 1)
        pos = pos - 1
      else
        ding ()
      end
    elseif c == keycode "c-d" or c == keycode "delete" then
      if pos < #as then
        as = string.sub (as, 1, pos) .. string.sub (as, pos + 2)
      else
        ding ()
      end
    elseif c == keycode "a-v" or c == keycode "pgup" then
      if cp == nil then
        ding ()
      elseif cp.poppedup then
        completion_scroll_down ()
        thistab = lasttab
      end
    elseif c == keycode "c-v" or c == keycode "pgdn" then
      if cp == nil then
        ding ()
      elseif cp.poppedup then
        completion_scroll_up ()
        thistab = lasttab
      end
    elseif c == keycode "a-p" or c == keycode "up" then
      if hp then
        local elem = previous_history_element (hp)
        if elem then
          if not saved then
            saved = as
          end
          as = elem
        end
      end
    elseif c == keycode "a-n" or c == keycode "down" then
      if hp then
        local elem = next_history_element (hp)
        if elem then
          as = elem
        elseif saved then
          as = saved
          saved = nil
        end
      end
    elseif c == keycode "tab" or (c == keycode "space" and cp) then
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
      if c.ALT or c.CTRL or not posix.isprint (string.byte (c.key)) then
        ding ()
      else
        as = string.sub (as, 1, pos) .. string.char (term_keytobyte (c)) .. string.sub (as, pos + 1)
        pos = pos + 1
      end
    end

    lasttab = thistab
  until c == keycode "return" or c == keycode "c-g"

  minibuf_clear ()
  maybe_close_popup (cp)
  return as
end

function term_minibuf_write (s)
  term_move (term_height () - 1, 0)
  term_clrtoeol ()
  term_addstr (string.sub (s, 1, math.min (#s, term_width ())))
end
