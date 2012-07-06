-- Zi Lua evaluator
--
-- Copyright (c) 2009-2012 Free Software Foundation, Inc.
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
-- Free Software Foundation, Fifth Floor, 51 Franklin Street, Boston,
-- MA 02111-1301, USA.


-- User commands
zi = {}

-- User command introspection.
local introspect = setmetatable ({}, {__mode = "k"})

-- Introspect table entry:
-- {
--   doc: command docstring.
--   interactive: if it can be called by `execute_extended_command'.
--   name: command name.
-- }

-- Initialise prefix arg
prefix_arg = false -- Not nil, so it is picked up in environment table
current_prefix_arg = false

function Defun (name, argtypes, doc, interactive, func)
  zi[name] = function (...)
             _this_command = zi[name]

             local args = {...}
             local i = 1
             for _, v in ipairs (args) do

               if argtypes and argtypes[i] and argtypes[i] ~= type (v) then
                 -- Undo mangled prefix_arg when called from mini-buffer
                 if i == 1 and args[1] == prefix_arg then
                   args[1] = nil
                 else
                   minibuf_error (string.format ("wrong type %s for argument #%d `%s', should be %s",
		     type (v), i, tostring (v), argtypes[i]))
		   return false
		 end
               end
               i = i + 1
             end
             current_prefix_arg = prefix_arg
             prefix_arg = false
             local ret = call_command (func, unpack (args))
             if ret == nil then
               ret = true
             end
             return ret
           end
  introspect[zi[name]] = {
    doc = texi (doc),
    interactive = interactive,
    name = name,
  }
end

-- Return function's interactive field, or nil if not found.
function get_function_interactive (name)
  if zi[name] and introspect[zi[name]] then
    return introspect[zi[name]].interactive
  end
end

function get_function_doc (name)
  if zi[name] and introspect[zi[name]] then
    return introspect[zi[name]].doc
  end
end

function get_function_name (func)
  if func and introspect[func] then
    local name = introspect[func].name

    -- Return the name if we found in already, and it wasn't rebound yet.
    if name and zi[name] == func then return name end

    -- Otherwise look it up the hard way, updating any others we find
    -- as we go.
    for n,f in pairs (zi) do
      if introspect[f] then
        introspect[f].name = n
	if f == func then return n end
      end
    end
  end
end

function evaluate_string (s)
  local f, errmsg = load (s, nil, 't', zi)
  if f == nil then
    return nil, errmsg
  end
  return f ()
end

function evaluate_file (file)
  local s = io.slurp (file)

  if s then
    local res, errmsg = evaluate_string (s)

    if res == nil and errmsg ~= nil then
      minibuf_error (string.format ("%s: %s", file, errmsg))
    end
    return true
  end

  return false
end

Defun ("load",
       {"string"},
[[
Execute a file of Lua code named FILE.
]],
  true,
  function (file)
    if file then
      return evaluate_file (file)
    end
  end
)

function function_exists (f)
  return zi[f] ~= nil
end

function execute_with_uniarg (undo, uniarg, forward, backward)
  uniarg = uniarg or 1

  if backward and uniarg < 0 then
    forward = backward
    uniarg = -uniarg
  end
  if undo then
    undo_start_sequence ()
  end
  local ret = true
  for _ = 1, uniarg do
    ret = forward ()
    if not ret then
      break
    end
  end
  if undo then
    undo_end_sequence ()
  end

  return ret
end

function move_with_uniarg (uniarg, move)
  local ret = true
  for uni = 1, math.abs (uniarg) do
    ret = move (uniarg < 0 and - 1 or 1)
    if not ret then
      break
    end
  end
  return ret
end


Defun ("execute_extended_command",
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
    msg = msg .. "A-x "

    local name = minibuf_read_function_name (msg)
    return name and zi[name] (n) or nil
  end
)

-- Read a function name from the minibuffer.
local functions_history = history_new ()
function minibuf_read_function_name (fmt)
  local cp = completion_new ()

  for name, func in pairs (zi) do
    if introspect[func] and introspect[func].interactive then
      table.insert (cp.completions, name)
    end
  end

  return minibuf_vread_completion (fmt, "", cp, functions_history,
                                   "No function name given",
                                   "Undefined function name `%s'")
end


Defun ("eval_buffer",
       {"string"},
[[
Execute the current buffer as Lua code.

When called from a Lua program (i.e., not interactively), this
function accepts an optional argument, the buffer to evaluate (nil
means use current buffer).
]],
  true,
  function (buffer)
    local bp = (buffer and buffer ~= "") and find_buffer (buffer) or cur_bp
    return evaluate_string (get_buffer_pre_point (bp) .. get_buffer_post_point (bp))
  end
)
