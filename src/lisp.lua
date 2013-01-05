-- Zile Lisp interpreter
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


-- User commands
usercmd = {}

-- Initialise prefix arg
prefix_arg = false -- Not nil, so it is picked up in environment table
current_prefix_arg = false

function Defun (name, argtypes, doc, interactive, func)
  usercmd[name] = {
    doc = texi (doc:chomp ()),
    interactive = interactive,
    func = function (arglist)
             local args = {}
             local i = 1
             while arglist and arglist.next do
               local val = arglist.next
               local ty = argtypes[i]
               if ty == "number" then
                 val = tonumber (val.data, 10)
               elseif ty == "boolean" then
                 val = val.data ~= "nil"
               elseif ty == "string" then
                 val = tostring (val.data)
               end
               table.insert (args, val)
               arglist = arglist.next
               i = i + 1
             end
             current_prefix_arg = prefix_arg
             prefix_arg = false
             local ret = func (unpack (args))
             if ret == nil then
               ret = true
             end
             return ret
           end
  }
end

-- Return function's interactive field, or nil if not found.
function get_function_interactive (name)
  return usercmd[name] and usercmd[name].interactive or nil
end

function get_function_doc (name)
  return usercmd[name] and usercmd[name].doc or nil
end

function read_char (s, pos)
  if pos <= #s then
    return s[pos], pos + 1
  end
  return -1, pos
end

function read_token (s, pos)
  local c
  local doublequotes = false
  local tok = ""

  -- Chew space to next token
  repeat
    c, pos = read_char (s, pos)

    -- Munch comments
    if c == ";" then
      repeat
        c, pos = read_char (s, pos)
      until c == -1 or c == "\n"
    end
  until c ~= " " and c ~= "\t"

  -- Snag token
  if c == "(" or c == ")" or c == "'" or c == "\n" or c == -1 then
    return tok, c, pos
  end

  -- It looks like a string. Snag to the next whitespace.
  if c == "\"" then
    doublequotes = true
    c, pos = read_char (s, pos)
  end

  repeat
    tok = tok .. c
    if not doublequotes then
      if c == ")" or c == "(" or c == ";" or c == " " or c == "\n"
        or c == "\r" or c == -1 then
        pos = pos - 1
        tok = string.sub (tok, 1, -2)
        return tok, "word", pos
      end
    else
      if c == "\n" or c == "\r" or c == -1 then
        pos = pos - 1
      end
      if c == "\"" then
        tok = string.sub (tok, 1, -2)
        return tok, "word", pos
      end
    end
    c, pos = read_char (s, pos)
  until false
end

function lisp_read (s)
  local pos = 1
  local function append (l, e)
    if l == nil then
      l = e
    else
      local l2 = l
      while l2.next ~= nil do
        l2 = l2.next
      end
      l2.next = e
    end
    return l
  end
  local function read ()
    local l = nil
    local quoted = false
    repeat
      local tok, tokenid
      tok, tokenid, pos = read_token (s, pos)
      if tokenid == "'" then
        quoted = true
      else
        if tokenid == "(" then
          l = append (l, {branch = read (), quoted = quoted})
        elseif tokenid == "word" then
          l = append (l, {data = tok, quoted = quoted})
        end
        quoted = false
      end
    until tokenid == ")" or tokenid == -1
    return l
  end

  return read ()
end

function evaluateBranch (branch)
  return branch and branch.data and call_command (branch.data, branch) or nil
end

function execute_function (name, uniarg)
  if uniarg ~= nil and type (uniarg) ~= "table" then
    uniarg = {next = {data = uniarg and tostring (uniarg) or nil}}
  end
  return usercmd[name] and usercmd[name].func and usercmd[name].func (uniarg)
end

function leEval (list)
  while list do
    evaluateBranch (list.branch)
    list = list.next
  end
end

function evaluateNode (node)
  if node == nil then
    return nil
  end
  local value
  if node.branch ~= nil then
    if node.quoted then
      value = node.branch
    else
      value = evaluateBranch (node.branch)
    end
  else
    value = {data = get_variable (node.data) or node.data}
  end
  return value
end

function lisp_loadstring (s)
  leEval (lisp_read (s))
end

function lisp_loadfile (file)
  local s = io.slurp (file)

  if s then
    lisp_loadstring (s)
    return true
  end

  return false
end

function function_exists (f)
  return usercmd[f] ~= nil
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
